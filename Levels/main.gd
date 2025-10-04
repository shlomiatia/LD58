class_name Main extends Node2D

const BUILDING_SCENE := preload("res://Entities/Building/Building.tscn")
const SLOT_POSITIONS := [
    Vector2(80, 160), Vector2(176, 160), Vector2(272, 160), Vector2(368, 160), Vector2(464, 160),
    Vector2(80, 336), Vector2(176, 336), Vector2(272, 336), Vector2(368, 336), Vector2(464, 336)
]

@onready var taxes = $CanvasLayer/Taxes
@onready var market = $Market

func _ready() -> void:
    var all_buildings = BuildingData.get_all_buildings()
    all_buildings.shuffle()

    var selected_buildings = all_buildings.slice(0, 2)

    for i in range(selected_buildings.size()):
        place_building(selected_buildings[i], i)

    taxes.taxes_set.connect(_on_taxes_set)

func place_building(building_data: BuildingData, slot_index: int) -> void:
    var building_instance = BUILDING_SCENE.instantiate()
    building_instance.building_name = building_data.building_name
    building_instance.position = SLOT_POSITIONS[slot_index]
    add_child(building_instance)

func _on_taxes_set() -> void:
    var buildings = get_tree().get_nodes_in_group("buildings")
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

    set_demand(internal_demand, buildings, "Food")
    set_demand(internal_demand, buildings, "Clothes")
    set_demand(internal_demand, buildings, "Drink")
    set_demand(internal_demand, buildings, "Meat")
    set_demand(internal_demand, buildings, "Milk")
    set_demand(internal_demand, buildings, "Wool")

    var total_demand := {}
    for resource_name in ["Sheep", "Wool", "Milk", "Meat", "Food", "Clothes", "Drink"]:
        var external_demand = market.demand_values.get(resource_name, 0)
        total_demand[resource_name] = int(internal_demand[resource_name] + external_demand)

    var sheep_producers = _get_producers_of(buildings, "Sheep")
    for producer in sheep_producers:
        producer.set_supply(total_demand["Sheep"])

    await get_tree().create_timer(1.0).timeout

    await _handle_buy(buildings, total_demand, ["Meat", "Milk", "Wool"])
    await _handle_buy(buildings, total_demand, ["Food", "Drink", "Clothes"])

func set_demand(internal_demand: Dictionary, buildings: Array[Node], resource_name: String) -> void:
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

func _get_producers_of(buildings: Array[Node], resource_name: String) -> Array[Building]:
    var producers: Array[Building] = []
    for building in buildings:
        if building is Building and building.building_data and building.building_data.output:
            if building.building_data.output.resource_name == resource_name:
                producers.append(building)
    return producers

func _handle_buy(buildings: Array[Node], total_demand: Dictionary, resources: Array[String]) -> void:
    for intermediate in resources:
        var producers = _get_producers_of(buildings, intermediate)
        if producers.size() == 0:
            continue

        var allocation = total_demand[intermediate] / producers.size()

        for producer in producers:
            await _buy(producer, allocation, buildings)

func _buy(producer: Building, allocation: int, buildings: Array[Node]) -> void:
    var input = producer.building_data.input.resource_name
    var market_price = market.get_price_with_tariff(input)
    var internal_price = 0
    var input_producers = _get_producers_of(buildings, input)

    if input_producers.size() > 0:
        internal_price = input_producers[0].get_price_with_vat()

    if input_producers.size() > 0 && internal_price <= market_price:
        var producer_allocation = allocation / input_producers.size()

        for input_producer in input_producers:
            var available_supply = input_producer.supply
            var bought_from_building = min(producer_allocation, available_supply)

            if bought_from_building > 0:
                await _buy_from(producer, input_producer, bought_from_building)
                allocation = allocation - bought_from_building

    if allocation > 0:
        producer.update_supply(allocation)
        var sheep_resource = ResourceData.get_resource(input)
        var base_price = sheep_resource.cost
        var total_cost = market_price * allocation

        producer.money -= total_cost

        var tariff_tax = TaxData.get_tax("Tariff")
        var tariff_amount = int((base_price * tariff_tax.value / 100.0) * allocation)
        taxes.add_money(tariff_amount)

        await get_tree().create_timer(1.0).timeout

func _buy_from(producer: Building, input_producer: Building, bought_from_building: int) -> void:
    input_producer.update_supply(-bought_from_building)
    producer.update_supply(bought_from_building)

    var total_cost = input_producer.get_price_with_vat() * bought_from_building
    producer.money -= total_cost

    var input_resource_data = ResourceData.get_resource(producer.building_data.input.resource_name)
    var base_price = input_resource_data.cost
    input_producer.update_money(base_price * bought_from_building)

    var vat_tax = TaxData.get_tax("VAT")
    var vat_amount = int((base_price * vat_tax.value / 100.0) * bought_from_building)
    taxes.add_money(vat_amount)

    
    await get_tree().create_timer(1.0).timeout