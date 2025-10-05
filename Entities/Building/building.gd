class_name Building extends Node2D

@export var building_name: String:
    set(value):
        building_name = value
        _initialize_building()

var building_data: BuildingData
var money: int = 0
var supply: int = 0

@onready var label = $UI/Label
@onready var conversion = $UI/Conversion
@onready var price_label = $UI/PriceLabel
@onready var money_label = $UI/MoneyLabel
@onready var resource_icon = $ResourceIcon

@onready var taxes = $/root/Main/CanvasLayer/Taxes
@onready var sprite = $Sprite2D
@onready var roof = $Roof
@onready var worker = $Worker

func _ready() -> void:
    _initialize_building()
    _setup_palette_swap()
    _animate_building_drop()

func _process(_delta: float) -> void:
    _update()

func _initialize_building() -> void:
    if building_name && is_node_ready():
        building_data = BuildingData.get_building(building_name)
        if building_data:
            label.text = building_data.building_name
            worker.set_worker_name(building_data.building_name)
            worker.parent_building = self

            if building_data.input:
                conversion.input_resource_name = building_data.input.resource_name
                conversion.output_resource_name = building_data.output.resource_name

            price_label.resource_name = building_data.output.resource_name
            resource_icon.resource_name = building_data.output.resource_name

func get_price_with_vat() -> int:
    var vat_tax = TaxData.get_tax("VAT")
    var base_price = building_data.output.cost
    return int(base_price * (1.0 + vat_tax.value / 100.0))

func set_supply(new_supply: int) -> void:
    supply = new_supply
    _update()

func update_supply(new_supply: int) -> void:
    supply += new_supply
    _update()

func update_money(amount: int) -> void:
    money += amount
    _update()


func buy(amount: int) -> Dictionary:
    var resource_data = ResourceData.get_resource(building_data.output.resource_name)
    var base_price = resource_data.cost
    var total_amount = min(amount, supply)
    update_supply(-total_amount)
    var base_cost = total_amount * base_price
    update_money(base_cost)

    var vat_tax = TaxData.get_tax("VAT")
    var vat_amount = int((base_price * vat_tax.value / 100.0) * total_amount)

    return {
        "total_amount": total_amount,
        "total_cost": base_cost + vat_amount,
        "total_tax": vat_amount
    }


func _update() -> void:
    var price = get_price_with_vat()
    price_label.value_text = "%d" % price
    money_label.value = money
    resource_icon.visible = supply > 0

    if taxes.are_controls_enabled():
        var index = LabelRotation.current_label_index % 4
        label.visible = index == 0
        conversion.visible = index == 1
        price_label.visible = index == 2
        money_label.visible = index == 3
    else:
        label.visible = false
        conversion.visible = false
        price_label.visible = false
        money_label.visible = false


func _setup_palette_swap() -> void:
    var sprite_material = sprite.material as ShaderMaterial
    var roof_material = roof.material as ShaderMaterial

    if not sprite_material or not roof_material:
        return

    var original_colors = [
        Color("#ae454a"), Color("#8c3132"), Color("#542323"),
        Color("#d49577"), Color("#9f705a"), Color("#3f2323"),
        Color("#845750"), Color("#633b3f"), Color("#422529"),
        Color("#7dbefa"), Color("#668faf"), Color("#585d81")
    ]

    var roof_colors = PaletteUtils.select_random_colors_from_palettes([0, 2], 3)
    var walls_colors = PaletteUtils.select_random_colors_from_palettes([0, 2, 5, 6], 3)
    var door_colors = PaletteUtils.select_random_colors_from_palettes(range(0, 3) + range(6, 8), 3)
    var window_colors = PaletteUtils.select_random_colors_from_palettes([10, 11], 3)

    for shader_material in [sprite_material, roof_material]:
        for i in range(original_colors.size()):
            shader_material.set_shader_parameter("original_%d" % i, original_colors[i])

        shader_material.set_shader_parameter("replace_0", Color(roof_colors[0]))
        shader_material.set_shader_parameter("replace_1", Color(roof_colors[1]))
        shader_material.set_shader_parameter("replace_2", Color(roof_colors[2]))
        shader_material.set_shader_parameter("replace_3", Color(walls_colors[0]))
        shader_material.set_shader_parameter("replace_4", Color(walls_colors[1]))
        shader_material.set_shader_parameter("replace_5", Color(walls_colors[2]))
        shader_material.set_shader_parameter("replace_6", Color(door_colors[0]))
        shader_material.set_shader_parameter("replace_7", Color(door_colors[1]))
        shader_material.set_shader_parameter("replace_8", Color(door_colors[2]))
        shader_material.set_shader_parameter("replace_9", Color(window_colors[0]))
        shader_material.set_shader_parameter("replace_10", Color(window_colors[1]))
        shader_material.set_shader_parameter("replace_11", Color(window_colors[2]))

func _animate_building_drop() -> void:
    worker.hide()

    var sprite_initial_y = sprite.position.y
    var roof_initial_y = roof.position.y

    sprite.position.y = sprite_initial_y - 360
    roof.position.y = roof_initial_y - 360

    var tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_BOUNCE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(sprite, "position:y", sprite_initial_y, 2.0)
    tween.tween_property(roof, "position:y", roof_initial_y, 2.0)

    await tween.finished
    await get_tree().create_timer(0.5).timeout
    _show_and_move_worker()

func _show_and_move_worker() -> void:
    worker.show()
    worker.navigate_to(position + Vector2(0, 16))
