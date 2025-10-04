class_name Building extends Node2D

@export var building_name: String:
    set(value):
        building_name = value
        _update_building()

var building_data: BuildingData

@onready var label = $Label
@onready var conversion = $Conversion
@onready var resource_price = $ResourcePrice

func _ready() -> void:
    _update_building()

func _update_building() -> void:
    if building_name && is_node_ready():
        building_data = BuildingData.get_building(building_name)
        if building_data:
            label.text = building_data.building_name

            if building_data.input:
                conversion.input_resource_name = building_data.input.resource_name
                conversion.output_resource_name = building_data.output.resource_name
                conversion.visible = true
            else:
                conversion.visible = false

            if building_data.output:
                resource_price.resource_name = building_data.output.resource_name
                resource_price.value = building_data.output.cost
