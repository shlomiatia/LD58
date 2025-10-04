class_name Market extends Node2D

@onready var sheep_label: ResourceLabel = $Sheep
@onready var wool_label: ResourceLabel = $Wool
@onready var milk_label: ResourceLabel = $Milk
@onready var meat_label: ResourceLabel = $Meat
@onready var food_label: ResourceLabel = $Food
@onready var clothes_label: ResourceLabel = $Clothes
@onready var drink_label: ResourceLabel = $Drink
@onready var taxes = $/root/Main/CanvasLayer/Taxes

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

func update_demand(resource_name: String, demand: int) -> void:
    demand_values[resource_name] += demand
    _update()

func get_price_with_tariff(resource_name: String) -> int:
    var resource = ResourceData.get_resource(resource_name)
    if resource:
        var tariff_tax = TaxData.get_tax("Tariff")
        var base_price = resource.cost
        return int(base_price * (1.0 + tariff_tax.value / 100.0))
    return 0

func _update() -> void:
    var all_resources = ResourceData.get_all_resources()

    for resource in all_resources:
        var buy_price = get_price_with_tariff(resource.resource_name)
        var sell_price = resource.cost
        var demand = demand_values.get(resource.resource_name, 0)
        _set_price_for_resource(resource.resource_name, buy_price, sell_price, demand)

func _set_price_for_resource(resource_name: String, buy_price: int, sell_price: int, demand: int) -> void:
    var label_text = "%d - %d - %d" % [buy_price, sell_price, demand]
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

func buy(resource_name: String, amount: int) -> int:
    var resource = ResourceData.get_resource(resource_name)
    var base_price = resource.cost
    
    var tariff_tax = TaxData.get_tax("Tariff")
    var tariff_amount = int((base_price * tariff_tax.value / 100.0) * amount)
    taxes.add_money(tariff_amount)

    prints("market.buy", resource_name, amount)

    return get_price_with_tariff(resource_name) * amount
