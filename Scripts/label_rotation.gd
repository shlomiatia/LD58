extends Node

const LABEL_SWITCH_TIME: float = 2.5

var label_timer: float = 0.0
var current_label_index: int = 0

func _process(delta: float) -> void:
	label_timer += delta
	if label_timer >= LABEL_SWITCH_TIME:
		label_timer = 0.0
		current_label_index = (current_label_index + 1) % 4
