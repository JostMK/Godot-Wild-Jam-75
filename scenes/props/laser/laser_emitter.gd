@tool
extends Node2D
class_name LaserEmitter

@export var max_length: float = 1000

@onready var raycast: RayCast2D = %RayCast2D
@onready var sprite: Sprite2D = %LaserSprite2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

var _offset: float
var _current_length: float
var _active: bool

func _ready():
	raycast.target_position.y = max_length

	_offset = raycast.position.y
	_current_length = -1
	_active = true

	# create new collision shape to ensure type RectangleShape2D and make sure the resource isn't shared
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size.x = sprite.texture.get_size().x * sprite.scale.x
	collision_shape.shape = rect


func reset() -> void:
	_active = true
	call_deferred("_update_laser")
	

func toggle() -> void:
	# collision_shape.disabled can fail when called normaly
	_active = not _active
	call_deferred("_update_laser")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		raycast.force_raycast_update()

	var length: float = max_length

	if raycast.is_colliding():
		var distance: float = (raycast.get_collision_point() - raycast.global_position).length()
		length = distance

	if _current_length == length:
		return

	# updating size and position of sprite and collision shape
	var sprite_height: float = sprite.texture.get_size().y
	sprite.scale.y = length / sprite_height
	sprite.position.y = _offset + length / 2

	var rect: RectangleShape2D = collision_shape.shape as RectangleShape2D
	rect.size.y = length
	collision_shape.position.y = _offset + length / 2

	_current_length = length


func _update_laser() -> void:
	if _active:
		sprite.show()
		collision_shape.disabled = false
	else:
		sprite.hide()
		collision_shape.disabled = true
