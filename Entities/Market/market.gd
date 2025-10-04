class_name Market extends Node2D

@onready var sheep_label: ResourceLabel = $Sheep
@onready var wool_label: ResourceLabel = $Wool
@onready var milk_label: ResourceLabel = $Milk
@onready var meat_label: ResourceLabel = $Meat
@onready var food_label: ResourceLabel = $Food
@onready var clothes_label: ResourceLabel = $Clothes
@onready var drink_label: ResourceLabel = $Drink

func _ready() -> void:
    _setup_resource_labels()

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

func _update_prices() -> void:
    var tariff_tax = TaxData.get_tax("Tariff")
    var all_resources = ResourceData.get_all_resources()

    for resource in all_resources:
        var base_price = resource.cost
        var final_price = base_price * (1.0 + tariff_tax.value / 100.0)
        _set_price_for_resource(resource.resource_name, int(final_price))

func _set_price_for_resource(resource_name: String, price: int) -> void:
    match resource_name:
        "Sheep":
            sheep_label.value = price
        "Wool":
            wool_label.value = price
        "Milk":
            milk_label.value = price
        "Meat":
            meat_label.value = price
        "Food":
            food_label.value = price
        "Clothes":
            clothes_label.value = price
        "Drink":
            drink_label.value = price
