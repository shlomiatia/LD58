class_name Worker extends CharacterBody2D

const SPEED := 150

var navigation_path: PackedVector2Array = []
var current_path_index: int = 0

var target_producer: Building
var target_producer2: Building
var target_resource_name: String
var target_amount: int
var target_market: bool
var target_supplier: Building
var building_amount: int
var current_amount: int
var money: int
var tax: int

@onready var label = $Label
@onready var money_label = $MoneyLabel
@onready var resource_label = $ResourceLabel
@onready var market = $/root/Main/Market

func set_worker_name(new_name: String) -> void:
    if is_node_ready():
        label.text = new_name

func update_money(amount: int) -> void:
    money += amount
    if is_node_ready() and money_label:
        money_label.value = money

func navigate_to(target_position: Vector2) -> void:
    var navigation_map = get_world_2d().navigation_map
    navigation_path = NavigationServer2D.map_get_path(navigation_map, global_position, target_position, true)
    current_path_index = 0

func _physics_process(_delta: float) -> void:
    if current_path_index >= navigation_path.size():
        return

    var target = navigation_path[current_path_index]
    var direction = (target - global_position).normalized()
    var distance = global_position.distance_to(target)

    if distance < 2.0:
        current_path_index += 1
        if !is_navigating():
            if target_supplier:
                prints("worker reached supplier", target_supplier.name)
                var result = target_supplier.buy(building_amount)
                target_amount -= building_amount
                current_amount += building_amount
                money -= result["total_cost"]
                tax += result["total_tax"]
                buy(target_resource_name, target_amount)
            elif target_market:
                prints("worker reached market")
                var result = market.buy(target_resource_name, target_amount)
                current_amount += target_amount
                target_amount = 0
                money -= result["total_cost"]
                tax += result["total_tax"]
                if target_producer:
                    navigate_to(target_producer.position + Vector2(0, 8))
                    target_producer2 = target_producer
                    target_producer = null
            elif target_producer2:
                prints("worker reached producer", target_producer2.name)
                target_producer.update_supply(current_amount)
                current_amount = 0
                target_resource_name = ""
    else:
        velocity = direction * SPEED
        move_and_slide()

func is_navigating() -> bool:
    return current_path_index < navigation_path.size()

func produce(resource_name: String, amount: int, parent: Building) -> void:
    target_producer = parent
    buy(resource_name, amount)

func buy(resource_name: String, amount: int) -> void:
    target_market = false
    target_supplier = null
    building_amount = 0
    target_resource_name = resource_name
    target_amount = amount
    var buildings = get_tree().get_nodes_in_group("buildings")
    var producers = _get_producers_of(buildings, resource_name)
    var market_price = market.get_price_with_tariff(resource_name)
    var internal_price = 0
    if producers.size() > 0:
        internal_price = producers[0].get_price_with_vat()

    if producers.size() > 0 && internal_price <= market_price:
        if _buy_from_buildings(buildings):
            return
        

    if amount > 0:
        navigate_to(market.position + Vector2(0, 8))
        target_market = true
        return
    
    if target_producer:
        navigate_to(target_producer.position + Vector2(0, 8))
        target_producer2 = target_producer
        target_producer = null
        
func _buy_from_buildings(buildings: Array[Node]) -> bool:
    var producers = _get_producers_of(buildings, target_resource_name)
    for producer in producers:
        building_amount = min(target_amount, producer.supply)

        if building_amount > 0:
            target_supplier = producer

            navigate_to(producer.position + Vector2(0, 8))
            return true
    return false

func _get_producers_of(buildings: Array[Node], resource_name: String) -> Array[Building]:
    var producers: Array[Building] = []
    for building in buildings:
        if building.building_data and building.building_data.output:
            if building.building_data.output.resource_name == resource_name:
                producers.append(building)
    return producers