class_name BuildingData extends Node

var building_name: String
var input: String
var output: String
var tags: Array[String]

func _init(p_name: String, p_input: String, p_output: String, p_tags: Array[String]):
	building_name = p_name
	input = p_input
	output = p_output
	tags = p_tags

static func get_all_buildings() -> Array[BuildingData]:
	return [
		BuildingData.new("Farmer", "", "sheep", ["sheep", "wool", "milk", "meat", "food", "clothes", "drink"]),
		BuildingData.new("Shearer", "sheep", "wool", ["sheep", "wool", "drink"]),
		BuildingData.new("Milker", "sheep", "milk", ["sheep", "milk", "drink"]),
		BuildingData.new("Slaughterer", "sheep", "meat", ["sheep", "meat", "food", "drink"]),
		BuildingData.new("Fromager", "milk", "food", ["sheep", "milk", "food"]),
		BuildingData.new("Cooker", "meat", "food", ["sheep", "meat", "food"]),
		BuildingData.new("Weaver", "wool", "clothes", ["sheep", "wool", "clothes"]),
		BuildingData.new("Tanner", "meat", "clothes", ["sheep", "meat", "drink"]),
		BuildingData.new("Milkmaid", "milk", "drink", ["sheep", "milk", "drink"])
	]
