extends Node2D
class_name LaserEmitter

@export var max_length: float = 1000

@onready var raycast: RayCast2D = %RayCast2D
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

@onready var beam_sprite: Sprite2D = %LaserSprite2D
@onready var emitter_sprite: AnimatedSprite2D = %EmitterSprite2D
@onready var impact_sprite: AnimatedSprite2D = %ImpactSprite2D

var _offset: float
var _current_length: float
var _active: bool

func _ready():
	raycast.target_position.y = max_length

	_offset = raycast.position.y
	_current_length = -1
	_active = true

	# check type RectangleShape2D and create new collision shape to ensure the resource isn't shared
	var rect: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if rect:
		collision_shape.shape = rect.duplicate()
	else:
		push_warning("LaserEmitter: Collision shape should be of type RectangleShape2D for calculations to work!")

	if not beam_sprite.region_enabled:
		# warning for my future self if I no longer use regions for displaying the beam
		push_warning("LaserEmitter: Expected regions for beam sprite to be enabled! If this changed please reflect this in code.")

	emitter_sprite.play("active")
	impact_sprite.play("active")


func reset() -> void:
	_active = true
	call_deferred("_update_laser")
	

func toggle() -> void:
	# collision_shape.disabled can fail when called directly
	_active = not _active
	call_deferred("_update_laser")


func _process(_delta: float) -> void:
	# needs to be called always to overwrite the changes made by the animator 
	call_deferred("_update_visuals")

	# check if beam length needs to be updated
	var length: float = max_length

	if raycast.is_colliding():
		var distance: float = (raycast.get_collision_point() - raycast.global_position).length()
		length = distance

	if _current_length == length:
		return

	_current_length = length
	collision_shape.position.y = _offset + _current_length / 2
	beam_sprite.position.y = _offset + _current_length / 2
	impact_sprite.position.y = _offset + _current_length

	# only need to update physics since visuals are updated each frame anyways
	call_deferred("_update_physics")


# Note:	For using tiling texture one cannot use the AnimatedSprite2D but needs to use the Sprit2D region feature,
#		setting the width or hight (rect.size property) of the region to the desired size.
# 		Therefore animating the sprites is done manually by animating the x and y values of the region property
# 		This however changes the whole region property so we need to manually update it to create the correct length sprite.
func _update_visuals() -> void:
	beam_sprite.region_rect.size.y = _current_length / beam_sprite.scale.y


# Note:	Changing the collision shape size property in the first frame does not actually change the underlying physics shape.
#		It therefore has to be updated deferred.
func _update_physics() -> void:
	collision_shape.shape.size.y = _current_length

func _update_laser() -> void:
	if _active:
		beam_sprite.show()
		impact_sprite.show()

		emitter_sprite.play("active")
		
		collision_shape.disabled = false
	else:
		beam_sprite.hide()
		impact_sprite.hide()

		emitter_sprite.play("off")
		
		collision_shape.disabled = true
