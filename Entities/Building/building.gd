class_name Building extends Node2D

@export var building_name: String:
    set(value):
        building_name = value
        _update_building()

var building_data: BuildingData
var money: int = 0
var supply: int = 0

@onready var label = $Label
@onready var conversion = $Conversion
@onready var resource_label = $ResourceLabel
@onready var sprite = $Sprite2D

func _ready() -> void:
    _update_building()

func _process(_delta: float) -> void:
    if building_data:
        if building_data.input:
            var mouse_pos = get_global_mouse_position()
            var sprite_rect = Rect2(sprite.global_position - sprite.texture.get_size() / 2, sprite.texture.get_size())
            conversion.visible = sprite_rect.has_point(mouse_pos)

        if building_data.output:
            _update_price()

func _update_building() -> void:
    if building_name && is_node_ready():
        building_data = BuildingData.get_building(building_name)
        if building_data:
            label.text = building_data.building_name

            if building_data.input:
                conversion.input_resource_name = building_data.input.resource_name
                conversion.output_resource_name = building_data.output.resource_name

            if building_data.output:
                resource_label.resource_name = building_data.output.resource_name

func get_price_with_vat() -> int:
    var vat_tax = TaxData.get_tax("VAT")
    var base_price = building_data.output.cost
    return int(base_price * (1.0 + vat_tax.value / 100.0))

func _update_price() -> void:
    var price = get_price_with_vat()
    resource_label.value_text = "%3d - %3d" % [price, supply]

func update_supply(new_supply: int) -> void:
    supply = new_supply
    if building_data and building_data.output:
        _update_price()
