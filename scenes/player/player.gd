extends AnimatableBody2D
class_name Player

signal Bounce
signal Reflect
signal Died(player: Player)
signal Split(new_player: Player)

@export var visuals: Node2D

@export var speed: float = 300.0
@export var max_charges: int = 1

@export_category("Death Settings")
@export var velocity_damping: float
@export var rotation_speed: float

var charges: int

var _velocity: Vector2
var _dead: bool

var _no_clip: bool

func set_direction(direction: Vector2) -> void:
	_velocity = direction * speed


func damage() -> void:
	if _dead:
		return

	_dead = true
	Died.emit(self)


func is_dead() -> bool:
	return _dead


func split() -> Player:
	# edge case of (almost) horizontal movement	
	if abs(_velocity.angle()) < deg_to_rad(5):
		# splits the players with both moving in 45 degree angle afterwards
		set_direction(Vector2(1, 1).normalized())

	var clone: Player = self.duplicate()

	var direction: Vector2 = _velocity.normalized()
	direction.y *= -1

	clone.set_direction(direction)
	
	get_parent().add_child(clone)

	Split.emit(clone)
	return clone


func _ready():
	# needs to be disabled to use move_and_collide
	sync_to_physics = false

	charges = max_charges


func _process(delta: float) -> void:
	if _no_clip:
		var dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		global_position += dir * speed * delta
		return

	if Input.is_action_just_pressed("no_clip"):
		_no_clip = true
		collision_layer = 0
		collision_mask = 0
		z_index = RenderingServer.CANVAS_ITEM_Z_MAX


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
	if _no_clip:
		return

	var move_amount: Vector2 = _velocity * delta

	# collide up to 10 bounces
	for __ in 10:
		var collision: KinematicCollision2D = move_and_collide(move_amount)

		if not collision:
			break

		move_amount = _handle_collision(collision)

		if _dead:
			return
		
		charges = max_charges
		Bounce.emit()
	

func _handle_collision(collision: KinematicCollision2D) -> Vector2:
	_velocity = _velocity.bounce(collision.get_normal())
	
	# reflect remaining velocity at surface and return it for further movement
	return collision.get_remainder().bounce(collision.get_normal())
