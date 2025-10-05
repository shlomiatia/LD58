class_name MoneyLabel extends Node2D

@export var is_tax: bool = false
@export var value: int = 0:
    set(v):
        value = v
        _update_label()

@onready var label = $Label

func _ready() -> void:
    _update_label()
    if is_tax:
        $Money.texture = load("res://Textures/Tax.png")

func _update_label() -> void:
    if is_node_ready():
        label.text = str(value)
