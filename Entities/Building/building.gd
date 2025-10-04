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
@onready var money_label = $MoneyLabel
@onready var taxes = $/root/Main/CanvasLayer/Taxes
@onready var worker = $Worker

func _ready() -> void:
    _update_building()

func _process(_delta: float) -> void:
    if building_data:
        var mouse_pos = get_global_mouse_position()
        var sprite_rect = Rect2(sprite.global_position - sprite.texture.get_size() / 2, sprite.texture.get_size())
        var is_hovered = sprite_rect.has_point(mouse_pos)
        label.visible = is_hovered
        if building_data.input:
            conversion.visible = is_hovered

        if building_data.output:
            _update()

func _update_building() -> void:
    if building_name && is_node_ready():
        building_data = BuildingData.get_building(building_name)
        if building_data:
            label.text = building_data.building_name
            worker.set_worker_name(building_data.building_name)

            if building_data.input:
                conversion.input_resource_name = building_data.input.resource_name
                conversion.output_resource_name = building_data.output.resource_name

            if building_data.output:
                resource_label.resource_name = building_data.output.resource_name

func get_price_with_vat() -> int:
    var vat_tax = TaxData.get_tax("VAT")
    var base_price = building_data.output.cost
    return int(base_price * (1.0 + vat_tax.value / 100.0))

func set_supply(new_supply: int) -> void:
    supply = new_supply
    _update()

func update_supply(new_supply: int) -> void:
    supply += new_supply
    _update()

func update_money(amount: int) -> void:
    money += amount
    _update()


func buy(amount: int) -> int:
    var resource_data = ResourceData.get_resource(building_data.output.resource_name)
    var base_price = resource_data.cost
    update_supply(-amount)
    update_money(amount * base_price)

    var vat_tax = TaxData.get_tax("VAT")
    var vat_amount = int((base_price * vat_tax.value / 100.0) * amount)
    taxes.add_money(vat_amount)
    return get_price_with_vat() * amount


func _update() -> void:
    var price = get_price_with_vat()
    resource_label.value_text = "%d" % price
    money_label.value = money
