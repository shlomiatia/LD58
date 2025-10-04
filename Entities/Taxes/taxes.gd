class_name Taxes extends HBoxContainer

signal taxes_set

@onready var tariff_tax = $VBoxContainer/Tariff
@onready var vat_tax = $"VBoxContainer/VAT"
@onready var income_tax = $"VBoxContainer/Income tax"
@onready var set_button = $Button
@onready var vbox = $VBoxContainer
@onready var money_label = $VBoxContainer/MoneyLabel

var money: int = 0

func _ready() -> void:
    tariff_tax.tax_name = "Tariff"
    vat_tax.tax_name = "VAT"
    income_tax.tax_name = "Income tax"

    set_button.pressed.connect(_on_set_button_pressed)
    _update_money_label()

func _on_set_button_pressed() -> void:
    for tax in vbox.get_children():
        if tax is Tax:
            tax.slider.editable = false
    set_button.disabled = true

    taxes_set.emit()

func add_money(amount: int) -> void:
    money += amount
    _update_money_label()

func _update_money_label() -> void:
    if is_node_ready() and money_label:
        money_label.value = money
