extends Node2D
class_name Level

signal PlayerSpawned(player: Player)
signal PlayerFinished
signal PlayerDied
signal PlayerChanged(player: Player)

@export var player_cannon: PlayerCannon
@export var player_finish: Finish

var _players: Dictionary = {}

func _ready() -> void:
	_players.clear()
	
	player_cannon.Fired.connect(_on_player_spawned)
	player_finish.Finished.connect(PlayerFinished.emit)


func get_camera_start_pos() -> Vector2:
	return player_cannon.global_position


func retry() -> void:
	_players.clear()
	player_cannon.setup()
	

func _on_player_spawned(player: Player) -> void:
	_register_player(player)

	PlayerSpawned.emit(player)


func _player_died(player: Player) -> void:
	_players.erase(player.get_path())

	if _players.size() <= 0:
		PlayerDied.emit()
	else:
		PlayerChanged.emit(_players.values()[0])


func _player_split(player: Player) -> void:
	_register_player(player)


func _register_player(player: Player) -> void:
	_players[player.get_path()] = player

	player.Died.connect(_player_died)
	player.Split.connect(_player_split)
