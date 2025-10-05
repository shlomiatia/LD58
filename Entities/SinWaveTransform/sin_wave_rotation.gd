class_name SineWaveRotation extends Node

var original_rotation_degrees
@export var magnitude_degrees: float
@export var speed: float = 1.0
@export var time_offset: float = 0.0

func _ready() -> void:
    original_rotation_degrees = get_parent().rotation_degrees

func _process(_delta: float) -> void:
    var sine = (sin(Time.get_ticks_msec() * 0.001 * speed + time_offset) * 0.5) + 0.5
    get_parent().rotation_degrees = original_rotation_degrees + sine * magnitude_degrees
