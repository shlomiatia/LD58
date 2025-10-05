class_name SineWavePosition extends Node

var original_position
@export var magnitude: Vector2
@export var speed: float = 1.0
@export var time_offset: float = 0.0

func _ready() -> void:
    original_position = get_parent().position

func _process(_delta: float) -> void:
    var sine = (sin(Time.get_ticks_msec() * 0.001 * speed + time_offset) * 0.5) + 0.5
    get_parent().position = Vector2(original_position.x + sine * magnitude.x, original_position.y + sine * magnitude.y)
