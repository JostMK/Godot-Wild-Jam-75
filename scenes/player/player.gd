extends AnimatableBody2D
class_name Player

signal Bounce
signal Reflect

@export var speed: float = 300.0
@export var max_charges: int = 1

var charges: int

var _velocity: Vector2


func _ready():
	# needs to be disabled to use move_and_collide
	sync_to_physics = false

	charges = max_charges
	_velocity = Vector2(1, 1).normalized()


func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("Reflect") and charges > 0:
		_velocity.y *= -1

		charges -= 1
		Reflect.emit()


func _physics_process(delta: float) -> void:
	var move_amount: Vector2 = _velocity * speed * delta

	# collide up to 10 bounces
	for __ in 10:
		var collision: KinematicCollision2D = move_and_collide(move_amount)

		if not collision:
			break

		move_amount = _handle_collision(collision)
		
		charges = max_charges
		Bounce.emit()
	

func _handle_collision(collision: KinematicCollision2D) -> Vector2:
	_velocity = _velocity.bounce(collision.get_normal())
	
	# reflect remaining velocity at surface and return it for further movement
	return collision.get_remainder().bounce(collision.get_normal())
