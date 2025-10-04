class_name Worker extends CharacterBody2D

const SPEED = 50.0

var resource_name: String = ""
var resource_amount: int = 0
var money: int = 0
var worker_name: String = ""
var navigation_path: PackedVector2Array = []
var current_path_index: int = 0

@onready var label = $Label
@onready var money_label = $MoneyLabel
@onready var resource_label = $ResourceLabel

func set_worker_name(new_name: String) -> void:
    worker_name = new_name
    if is_node_ready() and label:
        label.text = worker_name

func update_money(amount: int) -> void:
    money += amount
    if is_node_ready() and money_label:
        money_label.value = money

func navigate_to(target_position: Vector2) -> void:
    var navigation_map = get_world_2d().navigation_map
    navigation_path = NavigationServer2D.map_get_path(navigation_map, global_position, target_position, true)
    current_path_index = 0
    prints("Worker", worker_name, "navigating to", target_position, "with path:", navigation_path)

func _physics_process(_delta: float) -> void:
    if current_path_index >= navigation_path.size():
        return

    var target = navigation_path[current_path_index]
    var direction = (target - global_position).normalized()
    var distance = global_position.distance_to(target)

    if distance < 2.0:
        current_path_index += 1
    else:
        velocity = direction * SPEED
        move_and_slide()

func is_navigating() -> bool:
    return current_path_index < navigation_path.size()