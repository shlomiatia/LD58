class_name Building extends Node2D

@export var building_name: String:
    set(value):
        building_name = value
        _initialize_building()

var building_data: BuildingData
var money: int = 0
var supply: int = 0

@onready var label = $UI/Label
@onready var conversion = $UI/Conversion
@onready var price_label = $UI/PriceLabel
@onready var money_label = $UI/MoneyLabel
@onready var resource_icon = $ResourceIcon

@onready var taxes = $/root/Main/CanvasLayer/Taxes
@onready var sprite = $Sprite2D
@onready var worker = $Worker

func _ready() -> void:
    _initialize_building()

func _process(_delta: float) -> void:
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
            resource_icon.resource_name = building_data.output.resource_name

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

    return {
        "total_amount": total_amount,
        "total_cost": base_cost + vat_amount,
        "total_tax": vat_amount
    }


func _update() -> void:
    var price = get_price_with_vat()
    price_label.value_text = "%d" % price
    money_label.value = money
    resource_icon.visible = supply > 0

    if taxes.are_controls_enabled():
        label.visible = LabelRotation.current_label_index == 0
        conversion.visible = LabelRotation.current_label_index == 1
        price_label.visible = LabelRotation.current_label_index == 2
        money_label.visible = LabelRotation.current_label_index == 3
    else:
        label.visible = false
        conversion.visible = false
        price_label.visible = false
        money_label.visible = false
