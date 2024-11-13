extends Node2D
class_name PlayerCannon

signal Fired(player: Player)

@export var player_scene: PackedScene
@export var rotation_speed: float = 120
@export var rotation_bounds: Vector2 = Vector2(-45, 45)

@onready var player_spawn: Node2D = %PlayerSpawn

var _player: Player

func _ready() -> void:
	rotation_bounds = Vector2(deg_to_rad(rotation_bounds.x), deg_to_rad(rotation_bounds.y))
	setup()


func setup() -> void:
	_player = player_scene.instantiate() as Player
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	
	player_spawn.add_child(_player)
	_player.position = Vector2.ZERO
	_player.rotation = 0


func _process(delta: float) -> void:
	if not _player:
		return

	if Input.is_action_just_released("Reflect"):
		_player.process_mode = Node.PROCESS_MODE_INHERIT
		_player.reparent(get_tree().root)

		_player.rotation = 0;
		_player.set_direction(player_spawn.global_transform.x)

		Fired.emit(_player)
		_player = null

	var rotation_input: float = Input.get_axis("Aim_Up", "Aim_Down")
	rotate(deg_to_rad(rotation_input * rotation_speed * delta))
	rotation = clamp(rotation, rotation_bounds.x, rotation_bounds.y)
