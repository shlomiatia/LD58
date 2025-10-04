class_name Taxes extends HBoxContainer

signal taxes_set

@onready var tariff_tax = $VBoxContainer/Tariff
@onready var vat_tax = $"VBoxContainer/VAT"
@onready var income_tax = $"VBoxContainer/Income tax"
@onready var set_button = $Button
@onready var vbox = $VBoxContainer

func _ready() -> void:
    var all_taxes = TaxData.get_all_taxes()
    tariff_tax.tax_data = all_taxes[0]
    vat_tax.tax_data = all_taxes[1]
    income_tax.tax_data = all_taxes[2]

    set_button.pressed.connect(_on_set_button_pressed)

func _on_set_button_pressed() -> void:
    for tax in vbox.get_children():
        if tax is Tax:
            tax.slider.editable = false
    set_button.disabled = true

    taxes_set.emit()
