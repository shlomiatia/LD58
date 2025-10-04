class_name Building extends Node2D

@export var building: BuildingData:
    set(value):
        building = value
        _update_label()

@onready var label = $Label

func _ready() -> void:
    _update_label()

func _update_label() -> void:
    if building and is_node_ready():
        label.text = building.building_name
