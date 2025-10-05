class_name Building extends Node2D

@export var building_name: String:
    set(value):
        building_name = value
        _initialize_building()

var building_data: BuildingData
var money: int = 0
var supply: int = 0

@onready var label = $Label
@onready var conversion = $Conversion
@onready var price_label = $PriceLabel
@onready var supply_label = $SupplyLabel
@onready var sprite = $Sprite2D
@onready var money_label = $MoneyLabel
@onready var taxes = $/root/Main/CanvasLayer/Taxes
@onready var worker = $Worker

func _ready() -> void:
    _initialize_building()

func _process(_delta: float) -> void:
    if building_data:
        var mouse_pos = get_global_mouse_position()
        var sprite_rect = Rect2(sprite.global_position - sprite.texture.get_size() / 2, sprite.texture.get_size())
        var is_hovered = sprite_rect.has_point(mouse_pos)
        label.visible = is_hovered
        if building_data.input:
            conversion.visible = is_hovered

        _update()

func _initialize_building() -> void:
    if building_name && is_node_ready():
        building_data = BuildingData.get_building(building_name)
        if building_data:
            label.text = building_data.building_name
            worker.set_worker_name(building_data.building_name)
            worker.parent_building = self

            if building_data.input:
                conversion.input_resource_name = building_data.input.resource_name
                conversion.output_resource_name = building_data.output.resource_name

            price_label.resource_name = building_data.output.resource_name
            supply_label.resource_name = building_data.output.resource_name

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


func buy(amount: int) -> Dictionary:
    var resource_data = ResourceData.get_resource(building_data.output.resource_name)
    var base_price = resource_data.cost
    var total_amount = min(amount, supply)
    update_supply(-total_amount)
    var base_cost = total_amount * base_price
    update_money(base_cost)

    var vat_tax = TaxData.get_tax("VAT")
    var vat_amount = int((base_price * vat_tax.value / 100.0) * total_amount)
    #taxes.add_money(vat_amount)
    return {
        "total_amount": total_amount,
        "total_cost": base_cost + vat_amount,
        "total_tax": vat_amount
    }


func _update() -> void:
    var price = get_price_with_vat()
    price_label.value_text = "%d" % price
    supply_label.value_text = "%d" % supply
    money_label.value = money
