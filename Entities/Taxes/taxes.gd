class_name Taxes extends VBoxContainer

signal taxes_set

var is_enabled: bool

func _on_set_button_pressed() -> void:
    taxes_set.emit()

func are_controls_enabled() -> bool:
    return is_enabled
