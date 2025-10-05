class_name Outro extends Node2D

const QUOTA = 2500

@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
    var total_taxes = GlobalData.total_taxes_collected if GlobalData else 0

    if total_taxes >= QUOTA:
        label.text = "We collected %d taxes, well over the %d quota\n\nHis majesty will be pleased\n\nThanks for playing!" % [total_taxes, QUOTA]
    else:
        label.text = "We collected %d taxes but failed to reach the %d quota\n\nHis majesty will not be pleased...\n\nThanks for playing!" % [total_taxes, QUOTA]

    await $CanvasLayer/Fade.fade_in()
