extends Node
class_name GameOrchestrator

enum LevelState {
	START,
	RETRY,
	REPLAY
}

@export var level_ui: LevelUI
@export var follow_camera: FollowCamera

@export var levels: Array[PackedScene]

var _current_level_index: int

var _current_level: Level
var _current_level_scene: PackedScene
var _state: LevelState

func _ready() -> void:

	_current_level_index = 0

	level_ui.StartLevel.connect(start_level)
	level_ui.NextLevel.connect(next_level)
	level_ui.call_deferred("toggle_stats_text", false)

	call_deferred("load_level", levels[_current_level_index])
	

func load_level(level: PackedScene) -> void:
	_current_level_scene = level
	_current_level = level.instantiate()
	get_tree().root.add_child(_current_level)

	_current_level.PlayerSpawned.connect(_on_player_spawned)
	_current_level.PlayerFinished.connect(_on_player_finished)
	_current_level.PlayerDied.connect(_on_player_died)
	_current_level.PlayerChanged.connect(follow_camera.set_target)

	follow_camera.global_position = _current_level.get_camera_start_pos()

	_state = LevelState.START
	level_ui.set_status_text("Godot Rush")
	level_ui.set_button_text("Start Game")

	level_ui.show_level_retry()
	level_ui.show()


func start_level() -> void:
	if not _current_level:
		return

	level_ui.hide()

	match _state:
		LevelState.RETRY:
			prepare_retry_level()
		LevelState.REPLAY:
			restart_level()
			return

	# activates processing for level only in the next frame to avoid conflicts
	_call_next_frame(_current_level.start)


func next_level() -> void:
	_current_level_index  = (_current_level_index + 1) % levels.size()

	_current_level.name = "DELETED"
	_current_level.queue_free()
	_current_level = null

	level_ui.toggle_stats_text(false)

	call_deferred("load_level", levels[_current_level_index])


func prepare_retry_level() -> void:
	follow_camera.set_target(null)
	follow_camera.global_position = _current_level.get_camera_start_pos()

	# restart current level only in the next frame to avoid conflicts
	_call_next_frame(_current_level.retry)
	

func restart_level() -> void:
	_current_level.name = "DELETED"
	_current_level.queue_free()
	_current_level = null

	level_ui.toggle_stats_text(false)

	load_level(_current_level_scene)


func _on_player_spawned(player: Player) -> void:
	follow_camera.target = player


func _on_player_finished() -> void:
	_state = LevelState.REPLAY

	follow_camera.set_target(null)

	level_ui.set_status_text("Congratulations!")
	level_ui.set_button_text("Play Again")
	
	level_ui.set_stats_text(_current_level.get_reflect_stat())
	level_ui.toggle_stats_text(true)

	level_ui.show_level_finished()
	level_ui.show()


func _on_player_died() -> void:
	_state = LevelState.RETRY
	level_ui.set_status_text("Godot Died!")
	level_ui.set_button_text("Try Again")

	level_ui.show_level_retry()
	level_ui.show()


func _call_next_frame(callable: Callable) -> void:
	get_tree().process_frame.connect(callable, CONNECT_ONE_SHOT)
