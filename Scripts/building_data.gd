class_name BuildingData

var building_name: String
var input: ResourceData
var output: ResourceData
var tags: Array[ResourceData]

static var _buildings: Array[BuildingData] = []
static var _building_map: Dictionary = {}

func _init(p_name: String, p_input: ResourceData, p_output: ResourceData, p_tags: Array[ResourceData]):
	building_name = p_name
	input = p_input
	output = p_output
	tags = p_tags

static func get_all_buildings() -> Array[BuildingData]:
	if _buildings.is_empty():
		var sheep = ResourceData.get_resource("Sheep")
		var wool = ResourceData.get_resource("Wool")
		var milk = ResourceData.get_resource("Milk")
		var meat = ResourceData.get_resource("Meat")
		var food = ResourceData.get_resource("Food")
		var clothes = ResourceData.get_resource("Clothes")
		var drink = ResourceData.get_resource("Drink")

		_buildings = [
			BuildingData.new("Farmer", null, sheep, [sheep, wool, milk, meat, food, clothes, drink]),
			BuildingData.new("Shearer", sheep, wool, [sheep, wool, drink]),
			BuildingData.new("Milker", sheep, milk, [sheep, milk, drink]),
			BuildingData.new("Slaughterer", sheep, meat, [sheep, meat, food, drink]),
			BuildingData.new("Fromager", milk, food, [sheep, milk, food]),
			BuildingData.new("Cooker", meat, food, [sheep, meat, food]),
			BuildingData.new("Weaver", wool, clothes, [sheep, wool, clothes]),
			BuildingData.new("Tanner", meat, clothes, [sheep, meat, drink]),
			BuildingData.new("Milkmaid", milk, drink, [sheep, milk, drink])
		]
		for building in _buildings:
			_building_map[building.building_name.to_lower()] = building
	return _buildings

static func get_building(name: String) -> BuildingData:
	if _buildings.is_empty():
		get_all_buildings()
	return _building_map.get(name.to_lower())
