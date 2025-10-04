class_name Market extends Node2D

@onready var sheep_label: ResourceLabel = $Sheep
@onready var wool_label: ResourceLabel = $Wool
@onready var milk_label: ResourceLabel = $Milk
@onready var meat_label: ResourceLabel = $Meat
@onready var food_label: ResourceLabel = $Food
@onready var clothes_label: ResourceLabel = $Clothes
@onready var drink_label: ResourceLabel = $Drink

var demand_values: Dictionary = {}

func _ready() -> void:
    _setup_resource_labels()
    _initialize_demand()

func _process(_delta: float) -> void:
    _update_prices()

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
        update_demand(resource.resource_name)

func update_demand(resource_name: String) -> void:
    var resource = ResourceData.get_resource(resource_name)
    if resource:
        var demand = randi_range(resource.min_external_demand, resource.max_external_demand)
        demand_values[resource_name] = demand

func _update_prices() -> void:
    var tariff_tax = TaxData.get_tax("Tariff")
    var all_resources = ResourceData.get_all_resources()

    for resource in all_resources:
        var base_price = resource.cost
        var buy_price = base_price * (1.0 + tariff_tax.value / 100.0)
        var sell_price = base_price
        var demand = demand_values.get(resource.resource_name, 0)
        _set_price_for_resource(resource.resource_name, int(buy_price), sell_price, demand)

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
