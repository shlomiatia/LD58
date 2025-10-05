class_name ResourceData

var resource_name: String
var cost: int
var min_external_demand: int
var max_external_demand: int

static var _resources: Array[ResourceData] = []
static var _resource_map: Dictionary = {}

func _init(p_name: String, p_cost: int, p_min_demand: int, p_max_demand: int):
	resource_name = p_name
	cost = p_cost
	min_external_demand = p_min_demand
	max_external_demand = p_max_demand

static func get_all_resources() -> Array[ResourceData]:
	if _resources.is_empty():
		_resources = [
			#ResourceData.new("Sheep", 20, 12, 18),
			#ResourceData.new("Wool", 40, 12, 36),
			#ResourceData.new("Milk", 40, 12, 36),
			#ResourceData.new("Meat", 40, 12, 36),
			#ResourceData.new("Food", 80, 5, 15),
			#ResourceData.new("Clothes", 80, 5, 15),
			#ResourceData.new("Drink", 80, 5, 15)
            ResourceData.new("Sheep", 20, 12, 12),
			ResourceData.new("Wool", 40, 12, 12),
			ResourceData.new("Milk", 40, 12, 12),
			ResourceData.new("Meat", 40, 12, 12),
			ResourceData.new("Food", 80, 5, 5),
			ResourceData.new("Clothes", 80, 5, 5),
			ResourceData.new("Drink", 80, 5, 5)
		]
		for resource in _resources:
			_resource_map[resource.resource_name.to_lower()] = resource
	return _resources

static func get_resource(_resource_name: String) -> ResourceData:
	if _resources.is_empty():
		get_all_resources()
	return _resource_map.get(_resource_name.to_lower())
