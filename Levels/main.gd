class_name Main extends Node2D

const BUILDING_SCENE := preload("res://Entities/Building/Building.tscn")
const SLOT_POSITIONS := [
    Vector2(80, 160), Vector2(176, 160), Vector2(272, 160), Vector2(368, 160), Vector2(464, 160),
    Vector2(80, 336), Vector2(176, 336), Vector2(272, 336), Vector2(368, 336), Vector2(464, 336)
]

@onready var taxes = $CanvasLayer/Taxes

func _ready() -> void:
    var all_buildings = BuildingData.get_all_buildings()
    all_buildings.shuffle()

    var selected_buildings = all_buildings.slice(0, 2)

    for i in range(selected_buildings.size()):
        place_building(selected_buildings[i], i)

    taxes.taxes_set.connect(_on_taxes_set)

func _on_taxes_set() -> void:
    prints("taxes", TaxData.get_all_taxes()[0].value, TaxData.get_all_taxes()[1].value, TaxData.get_all_taxes()[2].value)
    pass

func place_building(building_data: BuildingData, slot_index: int) -> void:
    var building_instance = BUILDING_SCENE.instantiate()
    building_instance.building_name = building_data.building_name
    building_instance.position = SLOT_POSITIONS[slot_index]
    add_child(building_instance)
