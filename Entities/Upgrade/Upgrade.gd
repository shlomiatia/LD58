class_name Upgrade extends ColorRect

enum UpgradeType {
    TARIFF,
    VAT,
    SPEED,
    AURA,
    TAX_RATE
}

signal upgrade_selected(upgrade: Upgrade)

var upgrade_type: UpgradeType
var level: int = 1

@onready var title_label: Label = $MarginContainer/VBoxContainer/Label
@onready var description_label: Label = $MarginContainer/VBoxContainer/Label2

var default_color := Color(0.670588, 0.686275, 0.72549, 0.501961)
var hover_color := Color(0x75/255.0, 0x62/255.0, 0x76/255.0, 0.8)

func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    gui_input.connect(_on_gui_input)

func setup(type: UpgradeType, upgrade_level: int) -> void:
    upgrade_type = type
    level = upgrade_level
    _update_labels()

func _update_labels() -> void:
    var tax_percentage = level * 5
    var player_percentage = level * 10

    match upgrade_type:
        UpgradeType.TARIFF:
            title_label.text = "Tariff - Level %d" % level
            description_label.text = "Tax %d%% from market imports" % tax_percentage
        UpgradeType.VAT:
            title_label.text = "VAT - Level %d" % level
            description_label.text = "Tax %d%% from village trades" % tax_percentage
        UpgradeType.SPEED:
            title_label.text = "Speed - Level %d" % level
            description_label.text = "Move %d%% faster" % player_percentage
        UpgradeType.AURA:
            title_label.text = "Aura - Level %d" % level
            description_label.text = "Tax collection aura radius %d%% larger" % player_percentage
        UpgradeType.TAX_RATE:
            title_label.text = "Tax Rate - Level %d" % level
            description_label.text = "Collect taxes %d%% faster" % player_percentage

func _on_mouse_entered() -> void:
    color = hover_color

func _on_mouse_exited() -> void:
    color = default_color

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            upgrade_selected.emit(self)
