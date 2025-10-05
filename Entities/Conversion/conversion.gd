class_name Conversion extends Node2D

@export var input_resource_name: String:
    set(value):
        input_resource_name = value
        _update_input()

@export var output_resource_name: String:
    set(value):
        output_resource_name = value
        _update_output()

var input_resource: ResourceData
var output_resource: ResourceData

@onready var input_icon = $Input
@onready var output_icon = $Output
@onready var label = $Label
@onready var label2 = $Label2

func _ready() -> void:
    _update_input()
    _update_output()

func _update_input() -> void:
    if input_resource_name && is_node_ready():
        input_resource = ResourceData.get_resource(input_resource_name)
        input_icon.resource_name = input_resource_name
        label.visible = true
        input_icon.visible = true
        label2.text = "Convert"
        output_icon.position.x = 15

func _update_output() -> void:
    if output_resource_name && is_node_ready():
        output_resource = ResourceData.get_resource(output_resource_name)
        output_icon.resource_name = output_resource_name
