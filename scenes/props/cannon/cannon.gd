extends Node2D

signal Fired(player: Player)

@export var player_scene: PackedScene

@onready var player_spawn: Node2D = %PlayerSpawn

var _player: Player

func _ready() -> void:
	_player = player_scene.instantiate() as Player
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	
	player_spawn.add_child(_player)
	_player.position = Vector2.ZERO
	_player.rotation = 0


func _process(_delta: float) -> void:
	if not _player:
		return

	if Input.is_action_just_released("Reflect"):
		_player.process_mode = Node.PROCESS_MODE_INHERIT
		_player.reparent(get_tree().root)

		_player.rotation = 0;
		_player.set_direction(player_spawn.global_transform.x)

		Fired.emit(_player)
		_player = null
