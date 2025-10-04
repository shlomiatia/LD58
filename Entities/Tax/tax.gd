class_name Tax extends HBoxContainer

@export var tax_name: String:
	set(value):
		tax_name = value
		_update_name()

var tax_data: TaxData

@onready var name_label = $Name
@onready var value_label = $Value
@onready var slider = $HSlider

func _ready() -> void:
	_update_name()
	slider.value_changed.connect(_on_slider_changed)
	_on_slider_changed(slider.value)

func _update_name() -> void:
	if tax_name and is_node_ready():
		tax_data = TaxData.get_tax(tax_name)
		if tax_data:
			name_label.text = tax_data.tax_name

func _on_slider_changed(value: float) -> void:
	value_label.text = str(int(value))
	if tax_data:
		tax_data.value = value


