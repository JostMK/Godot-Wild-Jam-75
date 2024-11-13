extends AnimatableBody2D
class_name Player

signal Bounce
signal Reflect
signal Died

@export var visuals: Node2D

@export var speed: float = 300.0
@export var max_charges: int = 1

@export_category("Death Settings")
@export_flags_2d_physics var damage_layer: int
@export var velocity_damping: float
@export var rotation_speed: float

var charges: int

var _velocity: Vector2
var _dead: bool

func set_direction(direction: Vector2) -> void:
	_velocity = direction * speed


func _ready():
	# needs to be disabled to use move_and_collide
	sync_to_physics = false

	charges = max_charges
	_velocity = Vector2(1, 1).normalized() * speed


func _process(delta: float) -> void:
	if _dead:
		_velocity = _velocity.move_toward(Vector2.ZERO, velocity_damping * delta)
		# rotation speed is proportional to velocity
		var rotation_degree = lerp(0., rotation_speed, _velocity.length_squared() / (speed ** 2))
		visuals.rotate(deg_to_rad(rotation_degree * delta))
		return

	if Input.is_action_just_pressed("Reflect") and charges > 0:
		_velocity.y *= -1

		charges -= 1
		Reflect.emit()


func _physics_process(delta: float) -> void:
	var move_amount: Vector2 = _velocity * delta

	# collide up to 10 bounces
	for __ in 10:
		var collision: KinematicCollision2D = move_and_collide(move_amount)

		if not collision:
			break

		var object: CollisionObject2D = collision.get_collider() as CollisionObject2D
		if object and (object.collision_layer & damage_layer): # logical AND to check if any layer overlaps
			_handle_death()

		move_amount = _handle_collision(collision)

		if _dead:
			return
		
		charges = max_charges
		Bounce.emit()
	

func _handle_collision(collision: KinematicCollision2D) -> Vector2:
	_velocity = _velocity.bounce(collision.get_normal())
	
	# reflect remaining velocity at surface and return it for further movement
	return collision.get_remainder().bounce(collision.get_normal())


func _handle_death() -> void:
	if _dead:
		return

	_dead = true
	Died.emit()
