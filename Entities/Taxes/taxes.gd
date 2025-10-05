class_name Taxes extends VBoxContainer

signal taxes_set

const UPGRADE_SCENE := preload("res://Entities/Upgrade/Upgrade.tscn")

var upgrade_levels: Dictionary = {
    "tariff": 0,
    "vat": 0,
    "speed": 0,
    "aura": 0,
    "tax_rate": 0
}
var is_first_upgrade: bool = true
var current_upgrades: Array[Upgrade] = []
var selected_index: int = 0

@onready var player: Player = $/root/Main/Player
@onready var center_container: VBoxContainer = $VBoxContainer

func set_controls_enabled() -> void:
    _generate_upgrades()
    selected_index = 0
    _update_selection_highlight()
    visible = true

func are_controls_enabled() -> bool:
    return visible

func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return

    if event.is_action_pressed("up"):
        selected_index = max(0, selected_index - 1)
        _update_selection_highlight()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("down"):
        selected_index = min(current_upgrades.size() - 1, selected_index + 1)
        _update_selection_highlight()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("confirm"):
        if selected_index >= 0 and selected_index < current_upgrades.size():
            _on_upgrade_selected(current_upgrades[selected_index])
        get_viewport().set_input_as_handled()

func _update_selection_highlight() -> void:
    for i in range(current_upgrades.size()):
        if i == selected_index:
            current_upgrades[i].color = current_upgrades[i].hover_color
        else:
            current_upgrades[i].color = current_upgrades[i].default_color

func _generate_upgrades() -> void:
    _clear_upgrades()

    if is_first_upgrade:
        _create_upgrade(Upgrade.UpgradeType.TARIFF)
        is_first_upgrade = false
    else:
        var available_types = [
            Upgrade.UpgradeType.TARIFF,
            Upgrade.UpgradeType.VAT,
            Upgrade.UpgradeType.SPEED,
            Upgrade.UpgradeType.AURA,
            Upgrade.UpgradeType.TAX_RATE
        ]
        available_types.shuffle()

        for i in range(3):
            _create_upgrade(available_types[i])

func _create_upgrade(type: Upgrade.UpgradeType) -> void:
    var upgrade_instance: Upgrade = UPGRADE_SCENE.instantiate()

    var type_key: String
    match type:
        Upgrade.UpgradeType.TARIFF:
            type_key = "tariff"
        Upgrade.UpgradeType.VAT:
            type_key = "vat"
        Upgrade.UpgradeType.SPEED:
            type_key = "speed"
        Upgrade.UpgradeType.AURA:
            type_key = "aura"
        Upgrade.UpgradeType.TAX_RATE:
            type_key = "tax_rate"

    var level = upgrade_levels[type_key] + 1
    upgrade_instance.upgrade_selected.connect(_on_upgrade_selected)

    center_container.add_child(upgrade_instance)
    upgrade_instance.setup(type, level)
    current_upgrades.append(upgrade_instance)

func _clear_upgrades() -> void:
    for upgrade in current_upgrades:
        upgrade.queue_free()
    current_upgrades.clear()

func _on_upgrade_selected(upgrade: Upgrade) -> void:
    var tax_percentage_increase = upgrade.level * 5
    var player_percentage_increase = upgrade.level * 0.1

    match upgrade.upgrade_type:
        Upgrade.UpgradeType.TARIFF:
            upgrade_levels["tariff"] = upgrade.level
            TaxData.get_tax("Tariff").value = tax_percentage_increase
        Upgrade.UpgradeType.VAT:
            upgrade_levels["vat"] = upgrade.level
            TaxData.get_tax("VAT").value = tax_percentage_increase
        Upgrade.UpgradeType.SPEED:
            upgrade_levels["speed"] = upgrade.level
            player.speed_multiplier = 1.0 + player_percentage_increase
        Upgrade.UpgradeType.AURA:
            upgrade_levels["aura"] = upgrade.level
            player.aura_multiplier = 1.0 + player_percentage_increase
        Upgrade.UpgradeType.TAX_RATE:
            upgrade_levels["tax_rate"] = upgrade.level
            player.tax_rate_multiplier = 1.0 + player_percentage_increase

    taxes_set.emit()

    _clear_upgrades()

    visible = false
