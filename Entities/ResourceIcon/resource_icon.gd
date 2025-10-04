class_name ResourceIcon extends Sprite2D

@export var resource_name: String:
	set(value):
		resource_name = value
		_update_resource()

var resource_data: ResourceData

func _ready() -> void:
	_update_resource()

func _update_resource() -> void:
	if resource_name && is_node_ready():
		resource_data = ResourceData.get_resource(resource_name)
		texture = load("res://Textures/" + resource_data.resource_name.to_lower() + ".png")
