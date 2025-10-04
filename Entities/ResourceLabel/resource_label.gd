class_name ResourceLabel extends Node2D

@export var resource_name: String:
	set(v):
		resource_name = v
		_update_resource()

@export var value: int = 0:
	set(v):
		value = v
		_update_label()

@export var value_text: String = "":
	set(v):
		value_text = v
		_update_label_text()

var resource_data: ResourceData

@onready var resource_icon = $ResourceIcon
@onready var label = $Label

func _ready() -> void:
	_update_resource()
	_update_label()

func _update_resource() -> void:
	if resource_name && is_node_ready():
		resource_data = ResourceData.get_resource(resource_name)
		resource_icon.resource_name = resource_name

func _update_label() -> void:
	if is_node_ready():
		label.text = str(value)

func _update_label_text() -> void:
	if is_node_ready():
		label.text = value_text
