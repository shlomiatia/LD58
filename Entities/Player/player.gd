class_name Player extends CharacterBody2D

const SPEED = 150.0
const TAX_PER_SECOND = 16
const MONEY_SOUNDS_PER_SECOND = 60.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var taxes: Taxes = $/root/Main/CanvasLayer/Taxes
@onready var money_label: MoneyLabel = $MoneyLabel
@onready var tutorial_label: Label = $TutorialLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var worker_tax_accumulator: Dictionary = {}
var money: int = 0
var can_move: bool = false
var has_moved: bool = false
var speed_multiplier: float = 1.0:
    set(value):
        speed_multiplier = value
var aura_multiplier: float = 1.0:
    set(value):
        aura_multiplier = value
        _update_aura_radius()
var tax_rate_multiplier: float = 1.0

var _money_sound_timer: float = 0.0
var _money_sound_interval: float = 0.0
var _is_collecting_taxes: bool = false
var _money_sound_streams: Array[AudioStream] = []

func _ready() -> void:
    _money_sound_streams = [
        preload("res://Sounds/tax1.wav"),
        preload("res://Sounds/tax2.wav"),
        preload("res://Sounds/tax3.wav")
    ]

    _money_sound_interval = 1.0 / MONEY_SOUNDS_PER_SECOND if MONEY_SOUNDS_PER_SECOND > 0 else 0.0

func _physics_process(delta: float) -> void:
    if taxes && taxes.are_controls_enabled():
        velocity = Vector2.ZERO
        _update_animation()
        return

    if not can_move:
        velocity = Vector2.ZERO
        _update_animation()
        _collect_taxes(delta)
        return

    var input_direction = Vector2(
        Input.get_axis("left", "right"),
        Input.get_axis("up", "down")
    )

    # Add mouse movement support
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        var mouse_pos = get_global_mouse_position()
        var direction_to_mouse = (mouse_pos - global_position).normalized()
        input_direction = direction_to_mouse

    if input_direction.length() > 0:
        input_direction = input_direction.normalized()
        has_moved = true

    velocity = input_direction * SPEED * speed_multiplier

    _update_animation()

    move_and_slide()

    _collect_taxes(delta)


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


func _collect_taxes(delta: float) -> void:
    var tax_amount_per_frame = TAX_PER_SECOND * delta * tax_rate_multiplier
    var nearby_bodies = area_2d.get_overlapping_bodies()
    var nearby_worker_ids = []
    var collected_any_tax = false

    for body in nearby_bodies:
        if body is Worker:
            var worker: Worker = body
            var worker_id = worker.get_instance_id()
            nearby_worker_ids.append(worker_id)

            if worker.tax > 0:
                if not worker_tax_accumulator.has(worker_id):
                    worker_tax_accumulator[worker_id] = 0.0

                worker_tax_accumulator[worker_id] += tax_amount_per_frame

                var tax_to_collect_int = int(worker_tax_accumulator[worker_id])
                if tax_to_collect_int > 0:
                    tax_to_collect_int = min(tax_to_collect_int, worker.tax)

                    worker.tax -= tax_to_collect_int

                    add_money(tax_to_collect_int)

                    worker_tax_accumulator[worker_id] -= tax_to_collect_int
                    collected_any_tax = true

    if collected_any_tax:
        if not _is_collecting_taxes:
            _is_collecting_taxes = true
            _money_sound_timer = 0.0

        _money_sound_timer += delta
        if _money_sound_timer >= _money_sound_interval:
            _play_money_sound()
            _money_sound_timer = 0.0
    else:
        _is_collecting_taxes = false

    var keys_to_remove = []
    for worker_id in worker_tax_accumulator.keys():
        if not worker_id in nearby_worker_ids:
            keys_to_remove.append(worker_id)

    for worker_id in keys_to_remove:
        worker_tax_accumulator.erase(worker_id)

func add_money(amount: int) -> void:
    money += amount
    money_label.value = money
    GlobalData.total_taxes_collected = money

func _play_money_sound() -> void:
    if _money_sound_streams.is_empty():
        return

    audio_stream_player.stream = _money_sound_streams[randi() % _money_sound_streams.size()]
    audio_stream_player.pitch_scale = randf_range(0.9, 1.1)
    audio_stream_player.play()

func _update_aura_radius() -> void:
    if collision_shape and collision_shape.shape is CapsuleShape2D:
        var base_radius = 25.0
        var base_height = 75.0
        collision_shape.shape.radius = base_radius * aura_multiplier
        collision_shape.shape.height = base_height * aura_multiplier
