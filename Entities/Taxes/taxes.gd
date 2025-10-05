class_name Taxes extends VBoxContainer

signal taxes_set

const UPGRADE_SCENE := preload("res://Entities/Upgrade/Upgrade.tscn")

var is_enabled: bool
var upgrade_levels: Dictionary = {
    "tariff": 0,
    "vat": 0,
    "speed": 0,
    "aura": 0
}
var is_first_upgrade: bool = true
var current_upgrades: Array[Upgrade] = []

@onready var player: Player = $/root/Main/Player

func set_controls_enabled() -> void:
    _generate_upgrades()
    is_enabled = true

func are_controls_enabled() -> bool:
    return is_enabled

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
            Upgrade.UpgradeType.AURA
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

    var level = upgrade_levels[type_key] + 1
    upgrade_instance.upgrade_selected.connect(_on_upgrade_selected)

    add_child(upgrade_instance)
    upgrade_instance.setup(type, level)
    current_upgrades.append(upgrade_instance)

func _clear_upgrades() -> void:
    for upgrade in current_upgrades:
        upgrade.queue_free()
    current_upgrades.clear()

func _on_upgrade_selected(upgrade: Upgrade) -> void:
    # Apply the upgrade
    var percentage_increase = upgrade.level * 0.05

    match upgrade.upgrade_type:
        Upgrade.UpgradeType.TARIFF:
            upgrade_levels["tariff"] = upgrade.level
            TaxData.get_tax("Tariff").value = percentage_increase
        Upgrade.UpgradeType.VAT:
            upgrade_levels["vat"] = upgrade.level
            TaxData.get_tax("VAT").value = percentage_increase
        Upgrade.UpgradeType.SPEED:
            upgrade_levels["speed"] = upgrade.level
            player.speed_multiplier = 1.0 + percentage_increase
        Upgrade.UpgradeType.AURA:
            upgrade_levels["aura"] = upgrade.level
            player.aura_multiplier = 1.0 + percentage_increase

    # Emit taxes_set signal
    taxes_set.emit()

    # Clear upgrades
    _clear_upgrades()

    # Disable controls
    is_enabled = false
