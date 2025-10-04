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
   
    for resource_name in ["Sheep", "Wool", "Milk", "Meat", "Food", "Clothes", "Drink"]:
        var external_demand = market.demand_values.get(resource_name, 0)
        var total_demand = int(internal_demand[resource_name] + external_demand)
        prints(resource_name, " - Internal:", internal_demand[resource_name], " External:", external_demand, " Total:", total_demand)

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

    prints(resource_name, internal_demand)