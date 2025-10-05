class_name Taxes extends VBoxContainer

signal taxes_set

var is_enabled: bool

func set_controls_enabled() -> void:
    is_enabled = true

func are_controls_enabled() -> bool:
    return is_enabled
