extends Node

class_name TaxData

var tax_name: String
var value: float

static var _taxes: Array[TaxData] = []

func _init(p_name: String, p_value: float = 0.0):
	tax_name = p_name
	value = p_value

static func get_all_taxes() -> Array[TaxData]:
	if _taxes.is_empty():
		_taxes = [
			TaxData.new("Tariff"),
			TaxData.new("VAT"),
			TaxData.new("Income tax")
		]
	return _taxes
