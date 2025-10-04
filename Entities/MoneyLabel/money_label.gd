class_name MoneyLabel extends Node2D

@export var value: int = 0:
	set(v):
		value = v
		_update_label()

@onready var label = $Label

func _ready() -> void:
	_update_label()

func _update_label() -> void:
	if is_node_ready():
		label.text = str(value)
