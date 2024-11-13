extends Node2D
class_name Level

signal PlayerSpawned(player: Player)
signal PlayerFinished
signal PlayerDied

@export var player_cannon: PlayerCannon
@export var player_finish: Finish

func _ready() -> void:
	player_cannon.Fired.connect(_on_player_spawned)
	player_finish.Finished.connect(PlayerFinished.emit)


func get_camera_start_pos() -> Vector2:
	return player_cannon.global_position


func retry() -> void:
	player_cannon.setup()
	

func _on_player_spawned(player: Player) -> void:
	player.Died.connect(PlayerDied.emit)
	PlayerSpawned.emit(player)
