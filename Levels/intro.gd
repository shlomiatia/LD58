class_name Intro extends Node2D

var is_input_disabled: bool = false

func _process(delta: float) -> void:
    if !is_input_disabled && Input.is_anything_pressed():
        is_input_disabled = true
        await $CanvasLayer/Fade.fade_out()
        get_tree().change_scene_to_file("res://Levels/main.tscn")
