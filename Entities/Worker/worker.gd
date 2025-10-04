class_name Worker extends CharacterBody2D

var resource_name: String = ""
var resource_amount: int = 0
var money: int = 0
var worker_name: String = ""

@onready var label = $Label
@onready var money_label = $MoneyLabel
@onready var resource_label = $ResourceLabel

func set_worker_name(new_name: String) -> void:
    worker_name = new_name
    if is_node_ready() and label:
        label.text = worker_name

func update_money(amount: int) -> void:
    money += amount
    if is_node_ready() and money_label:
        money_label.value = money
