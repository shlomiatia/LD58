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
        _place_building(selected_buildings[i], i)

    taxes.taxes_set.connect(_on_taxes_set)

func _place_building(building_data: BuildingData, slot_index: int) -> void:
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

    var sheep_producers = _get_producers_of(buildings, "Sheep")
    if sheep_producers.size() > 0:
        for producer in sheep_producers:
            producer.set_supply(total_demand["Sheep"])
            prints("_handle_resources_production", producer.building_data.building_name, total_demand["Sheep"])

        await get_tree().create_timer(1.0).timeout

    await _handle_resources_production(buildings, total_demand, ["Meat", "Milk", "Wool"])
    await _handle_resources_production(buildings, total_demand, ["Food", "Drink", "Clothes"])

    
    for building in buildings:
        prints("_handle_needs", building.building_data.building_name)
        for need in ["Food", "Drink", "Clothes"]:
            var result = await _buy(buildings, need, 1)
            building.update_money(-result["total_cost"])

    print("_export")
    for resource_name in ["Sheep", "Wool", "Milk", "Meat", "Food", "Clothes", "Drink"]:
        var result = await _buy_from_buildings(buildings, resource_name, market.get_demand(resource_name))
        market.update_demand(resource_name, result["total_amount"])

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
            var input_resource = producer.building_data.input.resource_name
            var input_needed = allocation
            var result = await _buy(buildings, input_resource, input_needed)
            producer.update_supply(result["total_amount"])
            producer.update_money(-result["total_cost"])
            prints("_handle_resources_production", producer.building_data.building_name, result["total_amount"])
            await get_tree().create_timer(1.0).timeout
    

func _buy(buildings: Array[Node], resource_name: String, amount: int) -> Dictionary:
    var producers = _get_producers_of(buildings, resource_name)
    var market_price = market.get_price_with_tariff(resource_name)
    var internal_price = 0
    var total_cost = 0
    var total_amount = 0
    if producers.size() > 0:
        internal_price = producers[0].get_price_with_vat()

    if producers.size() > 0 && internal_price <= market_price:
        var result = await _buy_from_buildings(buildings, resource_name, amount)
        total_cost = result["total_cost"]
        total_amount = result["total_amount"]
        amount -= total_amount
        
    if amount > 0:
        var cost = market.buy(resource_name, amount)
        total_cost += cost
        total_amount += amount
        await get_tree().create_timer(1.0).timeout

    return {
        "total_cost": total_cost,
        "total_amount": total_amount
    }

func _buy_from_buildings(buildings: Array[Node], resource_name: String, amount: int) -> Dictionary:
    var producers = _get_producers_of(buildings, resource_name)
    var total_cost = 0
    var total_amount = 0
    for producer in producers:
        var amount_to_buy = min(amount, producer.supply)

        if amount_to_buy > 0:
            var cost = producer.buy(amount_to_buy)
            amount -= amount_to_buy
            total_cost += cost
            total_amount += amount_to_buy
            await get_tree().create_timer(1.0).timeout

    return {
        "total_cost": total_cost,
        "total_amount": total_amount
    }
                

func _get_producers_of(buildings: Array[Node], resource_name: String) -> Array[Building]:
    var producers: Array[Building] = []
    for building in buildings:
        if building is Building and building.building_data and building.building_data.output:
            if building.building_data.output.resource_name == resource_name:
                producers.append(building)
    return producers
