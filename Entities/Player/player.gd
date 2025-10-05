class_name Player extends CharacterBody2D


const SPEED = 150.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	var input_direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	if input_direction.length() > 0:
		input_direction = input_direction.normalized()

	velocity = input_direction * SPEED

	_update_animation()

	move_and_slide()


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