class_name TaxData

var tax_name: String
var value: float

static var _taxes: Array[TaxData] = []
static var _tax_map: Dictionary = {}

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
		for tax in _taxes:
			_tax_map[tax.tax_name.to_lower()] = tax
	return _taxes

static func get_tax(name: String) -> TaxData:
	if _taxes.is_empty():
		get_all_taxes()
	return _tax_map.get(name.to_lower())
