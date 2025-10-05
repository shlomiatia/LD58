class_name SineWaveScale extends Node

var original_scale
@export var magnitude: Vector2
@export var speed: float = 1.0
@export var time_offset: float = 0.0
var disabled: bool = false

func _ready() -> void:
    original_scale = get_parent().scale

func _process(_delta: float) -> void:
    if disabled:
        return
    var sine = sin(Time.get_ticks_msec() * 0.001 * speed + time_offset) * 0.5 + 0.5
    get_parent().scale = Vector2(original_scale.x + sine * magnitude.x, original_scale.y + sine * magnitude.y)
