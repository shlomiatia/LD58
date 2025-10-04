class_name Building extends Node2D

@export var building_name: String:
    set(value):
        building_name = value
        _update_building()

var building_data: BuildingData

@onready var label = $Label
@onready var conversion = $Conversion
@onready var resource_price = $ResourcePrice
@onready var sprite = $Sprite2D

var is_hovering: bool = false

func _ready() -> void:
    _update_building()

func _process(_delta: float) -> void:
    if building_data and building_data.input:
        var mouse_pos = get_global_mouse_position()
        var sprite_rect = Rect2(sprite.global_position - sprite.texture.get_size() / 2, sprite.texture.get_size())
        is_hovering = sprite_rect.has_point(mouse_pos)
        conversion.visible = is_hovering

func _update_building() -> void:
    if building_name && is_node_ready():
        building_data = BuildingData.get_building(building_name)
        if building_data:
            label.text = building_data.building_name

            if building_data.input:
                conversion.input_resource_name = building_data.input.resource_name
                conversion.output_resource_name = building_data.output.resource_name

            if building_data.output:
                resource_price.resource_name = building_data.output.resource_name
                resource_price.value = building_data.output.cost
