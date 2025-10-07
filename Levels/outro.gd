class_name Outro extends Node2D

const QUOTA = 2500

@onready var label: Label = $CanvasLayer/Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
    var total_taxes = GlobalData.total_taxes_collected if GlobalData else 0

    var win_sound = preload("res://Sounds/win.wav")
    var lose_sound = preload("res://Sounds/lose.wav")

    if total_taxes >= QUOTA:
        audio_player.stream = win_sound
    else:
        audio_player.stream = lose_sound

    audio_player.play()

    await get_tree().create_timer(2.0).timeout

    if total_taxes >= QUOTA:
        label.text = "We collected %s taxes, well over the %s quota\n\nHis majesty will be very pleased\n\n\nThanks for playing!" % [_format_number(total_taxes), _format_number(QUOTA)]
    else:
        label.text = "We collected %s taxes but failed to reach the %s quota\n\nHis majesty will not be pleased...\n\n\nThanks for playing!" % [_format_number(total_taxes), _format_number(QUOTA)]

func _format_number(num: int) -> String:
    var num_str = str(num)
    var result = ""
    var count = 0

    for i in range(num_str.length() - 1, -1, -1):
        if count > 0 and count % 3 == 0:
            result = "," + result
        result = num_str[i] + result
        count += 1

    return result
