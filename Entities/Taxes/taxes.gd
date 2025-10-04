class_name Taxes extends HBoxContainer

signal taxes_set

@onready var tariff_tax = $VBoxContainer/Tariff
@onready var vat_tax = $"VBoxContainer/VAT"
@onready var income_tax = $"VBoxContainer/Income tax"
@onready var set_button = $Button
@onready var vbox = $VBoxContainer

func _ready() -> void:
    tariff_tax.tax_name = "Tariff"
    vat_tax.tax_name = "VAT"
    income_tax.tax_name = "Income tax"

    set_button.pressed.connect(_on_set_button_pressed)

func _on_set_button_pressed() -> void:
    for tax in vbox.get_children():
        if tax is Tax:
            tax.slider.editable = false
    set_button.disabled = true

    taxes_set.emit()
