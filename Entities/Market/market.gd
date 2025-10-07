class_name Market extends Node2D

@onready var sheep_label: ResourceLabel = $UI/Sheep
@onready var wool_label: ResourceLabel = $UI/Wool
@onready var milk_label: ResourceLabel = $UI/Milk
@onready var meat_label: ResourceLabel = $UI/Meat
@onready var food_label: ResourceLabel = $UI/Food
@onready var clothes_label: ResourceLabel = $UI/Clothes
@onready var drink_label: ResourceLabel = $UI/Drink
@onready var taxes = $/root/Main/CanvasLayer/Taxes
@onready var ui = $UI
@onready var market_label: Label = $UI/Label
@onready var market_label2: Label = $Label2

var demand_values: Dictionary = {}

func _ready() -> void:
    _setup_resource_labels()
    _initialize_demand()

func _process(_delta: float) -> void:
    _update()

func _setup_resource_labels() -> void:
    sheep_label.resource_name = "Sheep"
    wool_label.resource_name = "Wool"
    milk_label.resource_name = "Milk"
    meat_label.resource_name = "Meat"
    food_label.resource_name = "Food"
    clothes_label.resource_name = "Clothes"
    drink_label.resource_name = "Drink"

func _initialize_demand() -> void:
    var all_resources = ResourceData.get_all_resources()
    for resource in all_resources:
        var demand = randi_range(resource.min_external_demand, resource.max_external_demand)
        demand_values[resource.resource_name] = demand


func get_demand(resource_name: String) -> int:
    return demand_values.get(resource_name, 0)

func get_price_with_tariff(resource_name: String) -> int:
    var resource = ResourceData.get_resource(resource_name)
    if resource:
        var tariff_tax = TaxData.get_tax("Tariff")
        var base_price = resource.cost
        return int(base_price * (1.0 + tariff_tax.value / 100.0))
    return 0

func _update() -> void:
    if not taxes.are_controls_enabled():
        ui.visible = false
        market_label2.visible = true
        return

    ui.visible = true
    market_label2.visible = false
    var all_resources = ResourceData.get_all_resources()

    var index = LabelRotation.current_label_index % 3
    match index:
        0:
            market_label.text = "Market\nDemand"
            for resource in all_resources:
                var demand = get_demand(resource.resource_name)
                _set_price_for_resource(resource.resource_name, demand)
        1:
            market_label.text = "Market\nExport price"
            for resource in all_resources:
                var base_price = resource.cost
                _set_price_for_resource(resource.resource_name, base_price)
        2:
            market_label.text = "Market\nImport price"
            for resource in all_resources:
                var buy_price = get_price_with_tariff(resource.resource_name)
                _set_price_for_resource(resource.resource_name, buy_price)
            

func _set_price_for_resource(resource_name: String, buy_price: int) -> void:
    var label_text = "%d" % buy_price
    match resource_name:
        "Sheep":
            sheep_label.value_text = label_text
        "Wool":
            wool_label.value_text = label_text
        "Milk":
            milk_label.value_text = label_text
        "Meat":
            meat_label.value_text = label_text
        "Food":
            food_label.value_text = label_text
        "Clothes":
            clothes_label.value_text = label_text
        "Drink":
            drink_label.value_text = label_text

func buy(resource_name: String, amount: int) -> Dictionary:
    var resource = ResourceData.get_resource(resource_name)
    var base_price = resource.cost
    
    var tariff_tax = TaxData.get_tax("Tariff")
    var tariff_amount = int((base_price * tariff_tax.value / 100.0) * amount)

    return {
        "total_cost": get_price_with_tariff(resource_name) * amount,
        "total_tax": tariff_amount
    }

func sell(resource_name: String, amount: int) -> Dictionary:
    var resource = ResourceData.get_resource(resource_name)
    var base_price = resource.cost
    var actual_amount = min(amount, demand_values.get(resource_name, 0))
    demand_values[resource_name] -= actual_amount
    
    return {
        "total_amount": actual_amount,
        "total_cost": actual_amount * base_price
    }
