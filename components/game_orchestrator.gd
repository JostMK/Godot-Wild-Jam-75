extends Node
class_name GameOrchestrator

enum LevelState {
	START,
	RETRY,
	REPLAY
}

@export var level_ui: LevelUI
@export var follow_camera: FollowCamera

@export var temp_scene_ref: PackedScene

var _current_level: Level
var _state: LevelState

func _ready():
	# for testing
	call_deferred("load_level", temp_scene_ref)

	_state = LevelState.START
	level_ui.StartLevel.connect(start_level)
	

func load_level(level: PackedScene) -> void:
	_current_level = level.instantiate()
	get_tree().root.add_child(_current_level)

	_current_level.PlayerSpawned.connect(_on_player_spawned)
	_current_level.PlayerFinished.connect(_on_player_finished)
	_current_level.PlayerDied.connect(_on_player_died)

	_current_level.process_mode = Node.PROCESS_MODE_DISABLED

	level_ui.set_status_text("Godot Rush")
	level_ui.set_button_text("Start Game")
	level_ui.show()


func start_level() -> void:
	level_ui.hide()

	match _state:
		LevelState.RETRY:
			prepare_retry_level()
		LevelState.REPLAY:
			prepare_restart_level()

	_current_level.process_mode = Node.PROCESS_MODE_INHERIT

	
func prepare_retry_level() -> void:
	follow_camera.set_target(null)
	follow_camera.global_position = _current_level.get_camera_start_pos()

	_current_level.retry()


func prepare_restart_level() -> void:
	get_tree().call_deferred("reload_current_scene")


func _on_player_spawned(player: Player) -> void:
	follow_camera.target = player


func _on_player_finished() -> void:
	_state = LevelState.REPLAY

	level_ui.set_status_text("Congratulations!")
	level_ui.set_button_text("Play Again")
	level_ui.show()


func _on_player_died() -> void:
	_state = LevelState.RETRY
	level_ui.set_status_text("Godot Died!")
	level_ui.set_button_text("Try Again")
	level_ui.show()