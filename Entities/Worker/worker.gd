class_name Worker extends CharacterBody2D

var SPEED := 150

var parent_building: Building

var navigation_path: PackedVector2Array = []
var current_path_index: int = 0

var target_parent_production: bool
var target_parent_production2: bool
var target_resource_name: String
var target_amount: int
var target_market: bool
var target_export: bool
var target_export2: bool
var target_supplier: Building
var building_amount: int
var current_amount: int
var money: int
var tax: int

@onready var label = $UI/Label
@onready var money_label = $UI/MoneyLabel
@onready var tax_label = $UI/TaxLabel
@onready var resource_icon = $ResourceIcon
@onready var market = $/root/Main/Market
@onready var taxes: Taxes = $/root/Main/CanvasLayer/Taxes
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    SPEED = randi() % 50 + 150
    _setup_palette_swap()

func set_worker_name(new_name: String) -> void:
    if is_node_ready():
        label.text = new_name

func _update() -> void:
    money_label.value = money
    tax_label.value = tax
    resource_icon.visible = current_amount > 0
    if resource_icon.visible:
        resource_icon.resource_name = target_resource_name

    if taxes.are_controls_enabled():
        var index = LabelRotation.current_label_index % 3
        label.visible = index == 0
        money_label.visible = index == 1
        tax_label.visible = index == 2
    else:
        label.visible = false
        money_label.visible = false
        tax_label.visible = tax > 0

func navigate_to(target_position: Vector2) -> void:
    var navigation_map = get_world_2d().navigation_map
    navigation_path = NavigationServer2D.map_get_path(navigation_map, global_position, target_position, true)
    current_path_index = 0

func _physics_process(_delta: float) -> void:
    _update()

    if current_path_index >= navigation_path.size():
        velocity = Vector2.ZERO
        _update_animation()
        return

    var target = navigation_path[current_path_index]
    var direction = (target - global_position).normalized()
    var distance = global_position.distance_to(target)

    if distance < 2.0:
        current_path_index += 1
        if !is_navigating():
            if target_supplier:
                var result = target_supplier.buy(building_amount)
                var actual_amount = result["total_amount"]
                target_amount -= actual_amount
                current_amount += actual_amount
                money -= result["total_cost"]
                tax += result["total_tax"]
                buy(target_resource_name, target_amount)
            elif target_market:
                target_market = false
                var result = market.buy(target_resource_name, target_amount)
                current_amount += target_amount
                target_amount = 0
                money -= result["total_cost"]
                tax += result["total_tax"]
                if target_parent_production:
                    navigate_to(parent_building.position + Vector2(0, 8))
                    target_parent_production2 = true
                    target_parent_production = false
            elif target_parent_production2:
                target_parent_production2 = false
                parent_building.update_supply(current_amount)
                current_amount = 0
            elif target_export:
                target_export = false
                var amount = min(parent_building.supply, target_amount)
                parent_building.update_supply(-amount)
                current_amount += amount
                if current_amount > 0:
                    target_export2 = true
                    navigate_to(market.position + Vector2(0, 8))
                #money = parent_building.money
                #parent_building.money = 0
            elif target_export2:
                target_export2 = false
                var result = market.sell(target_resource_name, current_amount)
                money += result["total_cost"]
                current_amount = current_amount - result["total_amount"]
                if current_amount > 0:
                    target_parent_production2 = true
                navigate_to(parent_building.position + Vector2(0, 8))
    else:
        velocity = direction * SPEED
        _update_animation()
        move_and_slide()

func is_navigating() -> bool:
    return current_path_index < navigation_path.size()

func produce(amount: int) -> void:
    target_parent_production = true
    target_parent_production2 = false
    buy(parent_building.building_data.input.resource_name, amount)

func export_to_market(amount: int) -> void:
    target_resource_name = parent_building.building_data.output.resource_name
    target_export = true
    target_export2 = true
    target_amount = amount
    navigate_to(parent_building.position + Vector2(0, 8))

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
    
    if target_parent_production:
        navigate_to(parent_building.position + Vector2(0, 8))
        target_parent_production2 = true
        target_parent_production = false
        
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


func _update_animation() -> void:
    if velocity.length() == 0:
        animated_sprite.play("default")
        return

    if abs(velocity.x) > abs(velocity.y):
        animated_sprite.play("walk_right")
        if velocity.x > 0:
            animated_sprite.flip_h = false
        else:
            animated_sprite.flip_h = true
    else:
        animated_sprite.flip_h = false
        if velocity.y > 0:
            animated_sprite.play("walk_down")
        else:
            animated_sprite.play("walk_up")


func _setup_palette_swap() -> void:
    var shader_material = animated_sprite.material as ShaderMaterial
    if not shader_material:
        return

    var original_colors = [
        Color("#ae454a"), Color("#8c3132"), Color("#542323"),
        Color("#fdbd8f"), Color("#f0886b"),
        Color("#bd2709"), Color("#7c122b"),
        Color("#315dcd"), Color("#472a9c"),
        Color("#67314b"), Color("#3f2323"),
        Color("#845750"), Color("#633b3f")
    ]

    var hair_colors = PaletteUtils.select_random_colors_from_palettes(range(1, 7), 3)
    var skin_colors = PaletteUtils.select_random_colors_from_palettes(range(0, 5), 2)
    var shirt_colors = PaletteUtils.select_random_colors_from_palettes(range(7, 16), 2)
    var pants_colors = PaletteUtils.select_random_colors_from_palettes(range(7, 16), 2)
    var shoes_colors = PaletteUtils.select_random_colors_from_palettes(range(1, 3), 2)
    var eyes_colors = PaletteUtils.select_random_colors_from_palettes([1, 2] + range(7, 12), 2)

    for i in range(original_colors.size()):
        shader_material.set_shader_parameter("original_%d" % i, original_colors[i])

    shader_material.set_shader_parameter("replace_0", Color(hair_colors[0]))
    shader_material.set_shader_parameter("replace_1", Color(hair_colors[1]))
    shader_material.set_shader_parameter("replace_2", Color(hair_colors[2]))
    shader_material.set_shader_parameter("replace_3", Color(skin_colors[0]))
    shader_material.set_shader_parameter("replace_4", Color(skin_colors[1]))
    shader_material.set_shader_parameter("replace_5", Color(shirt_colors[0]))
    shader_material.set_shader_parameter("replace_6", Color(shirt_colors[1]))
    shader_material.set_shader_parameter("replace_7", Color(pants_colors[0]))
    shader_material.set_shader_parameter("replace_8", Color(pants_colors[1]))
    shader_material.set_shader_parameter("replace_9", Color(shoes_colors[0]))
    shader_material.set_shader_parameter("replace_10", Color(shoes_colors[1]))
    shader_material.set_shader_parameter("replace_11", Color(eyes_colors[0]))
    shader_material.set_shader_parameter("replace_12", Color(eyes_colors[1]))
