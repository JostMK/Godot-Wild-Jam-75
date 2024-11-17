extends Node2D
class_name Level

signal PlayerSpawned(player: Player)
signal PlayerFinished
signal PlayerDied
signal PlayerChanged(player: Player)

@export var player_cannon: PlayerCannon
@export var player_finish: Finish

@export var reset_nodes: Array[Node]

var _players: Dictionary = {}
var _reflect_count: int = 0

func _ready() -> void:
	_players.clear()
	_reflect_count = 0
	
	player_cannon.Fired.connect(_on_player_spawned)
	player_finish.Finished.connect(PlayerFinished.emit)

	# remove all nodes that do not have the 'reset' method
	for i in range(reset_nodes.size() - 1, -1, -1):
		if not reset_nodes[i].has_method("reset"):
			reset_nodes.remove_at(i)


func start() -> void:
	player_cannon.activate()


func retry() -> void:
	_players.clear()
	_reflect_count = 0

	player_cannon.setup()
	player_cannon.activate()

	for node in reset_nodes:
		node.reset()


func get_camera_start_pos() -> Vector2:
	return player_cannon.global_position


func get_reflect_stat() -> int:
	return _reflect_count
	

func _on_player_spawned(player: Player) -> void:
	_register_player(player)
	player.Reflect.connect(_record_reflect_stat)

	PlayerSpawned.emit(player)


func _player_died(player: Player) -> void:
	_players.erase(player.get_path())

	var reconnect_stats: bool = false
	if player.Reflect.is_connected(_record_reflect_stat):
		player.Reflect.disconnect(_record_reflect_stat)
		reconnect_stats = true

	if _players.size() <= 0:
		PlayerDied.emit()
	else:
		var new_player: Player = _players.values()[0]

		if reconnect_stats:
			new_player.Reflect.connect(_record_reflect_stat)

		PlayerChanged.emit(new_player)


func _player_split(player: Player) -> void:
	_register_player(player)


func _register_player(player: Player) -> void:
	_players[player.get_path()] = player

	player.Died.connect(_player_died)
	player.Split.connect(_player_split)


func _record_reflect_stat() -> void:
	_reflect_count += 1
