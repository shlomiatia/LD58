class_name Main extends Node2D

const BUILDING_SCENE := preload("res://Entities/Building/Building.tscn")
const SLOT_POSITIONS := [
    Vector2(80, 160), Vector2(176, 160), Vector2(272, 160), Vector2(368, 160), Vector2(464, 160),
    Vector2(80, 336), Vector2(176, 336), Vector2(272, 336), Vector2(368, 336), Vector2(464, 336)
]

@onready var taxes = $CanvasLayer/Taxes
@onready var market = $Market

func _wait_for_all_workers_to_finish() -> void:
    var buildings = get_tree().get_nodes_in_group("buildings")
    while true:
        var all_finished = true
        for building in buildings:
            if building.worker.is_navigating():
                all_finished = false
                break
        if all_finished:
            break
        await get_tree().process_frame

func _ready() -> void:
    var all_buildings = BuildingData.get_all_buildings()
    #all_buildings.shuffle()

    var selected_buildings = all_buildings.slice(0, 2)

    for i in range(selected_buildings.size()):
        _place_building(selected_buildings[i], i)

    taxes.taxes_set.connect(_on_taxes_set)

func _place_building(building_data: BuildingData, slot_index: int) -> void:
    var building_instance = BUILDING_SCENE.instantiate()
    building_instance.building_name = building_data.building_name
    building_instance.position = SLOT_POSITIONS[slot_index]
    add_child(building_instance)

func _on_taxes_set() -> void:
    var buildings = get_tree().get_nodes_in_group("buildings")
    var total_demand = _calculate_total_demand(buildings)
    await _handle_production(buildings, total_demand)

    await get_tree().create_timer(0.1).timeout

    await _handle_export(buildings)
    
    await get_tree().create_timer(0.1).timeout
    
    await _handle_needs(buildings)
    
    await get_tree().create_timer(0.1).timeout
    
    _place_new_building(buildings)

    for building in buildings:
        if building is Building:
            building.supply = 0

    market._initialize_demand()
    taxes.set_controls_enabled(true)

func _calculate_total_demand(buildings: Array[Node]) -> Dictionary:
    var num_buildings = buildings.size()
    var internal_demand := {
        "Food": num_buildings,
        "Clothes": num_buildings,
        "Drink": num_buildings,
        "Milk": 0,
        "Meat": 0,
        "Wool": 0,
        "Sheep": 0
    }

    _set_internal_demand(internal_demand, buildings, "Food")
    _set_internal_demand(internal_demand, buildings, "Clothes")
    _set_internal_demand(internal_demand, buildings, "Drink")
    _set_internal_demand(internal_demand, buildings, "Meat")
    _set_internal_demand(internal_demand, buildings, "Milk")
    _set_internal_demand(internal_demand, buildings, "Wool")

    var total_demand := {}
    for resource_name in ["Sheep", "Wool", "Milk", "Meat", "Food", "Clothes", "Drink"]:
        var external_demand = market.get_demand(resource_name)
        total_demand[resource_name] = int(internal_demand[resource_name] + external_demand)

    return total_demand

func _handle_production(buildings: Array[Node], total_demand: Dictionary) -> void:
    var sheep_producers = _get_producers_of(buildings, "Sheep")
    if sheep_producers.size() > 0:
        for producer in sheep_producers:
            var target_position = producer.position + Vector2(0, 8)
            producer.worker.navigate_to(target_position)

        await _wait_for_all_workers_to_finish()

        for producer in sheep_producers:
            producer.set_supply(total_demand["Sheep"])

    await _handle_resources_production(buildings, total_demand, ["Meat", "Milk", "Wool"])
    await _handle_resources_production(buildings, total_demand, ["Food", "Drink", "Clothes"])

func _get_producers_of(buildings: Array[Node], resource_name: String) -> Array[Building]:
    var producers: Array[Building] = []
    for building in buildings:
        if building.building_data and building.building_data.output:
            if building.building_data.output.resource_name == resource_name:
                producers.append(building)
    return producers

func _handle_needs(buildings: Array[Node]) -> void:
    for need in ["Food", "Drink", "Clothes"]:
        for building in buildings:
            building.worker.buy(need, 1)
        
        await _wait_for_all_workers_to_finish()

        for building in buildings:
            building.worker.current_amount = 0
            building.worker.navigate_to(building.position + Vector2(0, 8))

func _handle_export(buildings: Array[Node]) -> void:
    for building in buildings:
        building.worker.export_to_market(market.get_demand(building.building_data.output.resource_name))

    await _wait_for_all_workers_to_finish()

    for building in buildings:
        building.worker.navigate_to(building.position + Vector2(0, 8))

func _set_internal_demand(internal_demand: Dictionary, buildings: Array[Node], resource_name: String) -> void:
    var producers: Array[BuildingData] = []
    for building in buildings:
        if building.building_data.output.resource_name == resource_name:
            producers.append(building.building_data)

    var demand = internal_demand[resource_name]
    if producers.size() == 1:
        internal_demand[producers[0].input.resource_name] += demand
    elif producers.size() == 2:
        var split_demand = demand / 2
        internal_demand[producers[0].input.resource_name] += split_demand
        internal_demand[producers[1].input.resource_name] += split_demand

func _handle_resources_production(buildings: Array[Node], total_demand: Dictionary, resources: Array[String]) -> void:
    for intermediate in resources:
        var producers = _get_producers_of(buildings, intermediate)
        if producers.size() == 0:
            continue

        var allocation = total_demand[intermediate] / producers.size()

        for producer in producers:
            var input_needed = allocation
            producer.worker.produce(input_needed)

    await _wait_for_all_workers_to_finish()


func _place_new_building(buildings: Array[Node]) -> void:
    var tariff = TaxData.get_tax("Tariff").value
    var vat = TaxData.get_tax("VAT").value

    var existing_building_names: Array[String] = []
    for building in buildings:
        existing_building_names.append(building.building_data.building_name)

    var all_buildings = BuildingData.get_all_buildings()
    var available_buildings: Array[BuildingData] = []
    for building_data in all_buildings:
        if not existing_building_names.has(building_data.building_name):
            available_buildings.append(building_data)

    if available_buildings.is_empty():
        return

    var selected_building: BuildingData = null

    if tariff < vat:
        var importers = _get_importers(available_buildings, buildings)
        if importers.size() > 0:
            selected_building = importers[randi() % importers.size()]
    elif vat < tariff:
        var non_importers = _get_non_importers(available_buildings, buildings)
        if non_importers.size() > 0:
            selected_building = non_importers[randi() % non_importers.size()]

    if selected_building == null:
        selected_building = available_buildings[randi() % available_buildings.size()]

    var next_slot = buildings.size()
    if next_slot < SLOT_POSITIONS.size():
        _place_building(selected_building, next_slot)

func _get_importers(available_buildings: Array[BuildingData], existing_buildings: Array[Node]) -> Array[BuildingData]:
    var importers: Array[BuildingData] = []
    for building_data in available_buildings:
        if building_data.input == null:
            continue
        var input_produced = false
        for building in existing_buildings:
            if building is Building and building.building_data and building.building_data.output:
                if building.building_data.output.resource_name == building_data.input.resource_name:
                    input_produced = true
                    break
        if not input_produced:
            importers.append(building_data)
    return importers

func _get_non_importers(available_buildings: Array[BuildingData], existing_buildings: Array[Node]) -> Array[BuildingData]:
    var importers = _get_importers(available_buildings, existing_buildings)
    var non_importers: Array[BuildingData] = []
    for building_data in available_buildings:
        if not importers.has(building_data):
            non_importers.append(building_data)
    return non_importers
