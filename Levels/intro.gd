class_name Intro extends Node2D

var is_input_disabled: bool = false

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _process(_delta: float) -> void:
    if !is_input_disabled && Input.is_anything_pressed():
        is_input_disabled = true
        audio_player.stream = preload("res://Sounds/confirm_big.wav")
        audio_player.play()
        await $CanvasLayer/Fade.fade_out()
        get_tree().change_scene_to_file("res://Levels/Main.tscn")
