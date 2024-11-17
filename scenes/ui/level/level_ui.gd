extends Control
class_name LevelUI

signal StartLevel
signal NextLevel

@onready var status_label: Label = %StatusLabel
@onready var start_button: Button = %StartButton
@onready var stats_label: Label = %StatsLabel
@onready var level_finished_menu: Control = %LevelFinishedMenu
@onready var replay_button: Button = %ReplayButton
@onready var next_button: Button = %NextButton

func _ready() -> void:
	start_button.pressed.connect(StartLevel.emit)
	replay_button.pressed.connect(StartLevel.emit)
	next_button.pressed.connect(NextLevel.emit)


func set_status_text(text: String) -> void:
	status_label.text = text


func set_button_text(text: String) -> void:
	start_button.text = text


func toggle_stats_text(enable: bool) -> void:
	if enable:
		stats_label.show()
	else:
		stats_label.hide()


func set_stats_text(reflect_count: int) -> void:
	stats_label.text = "Reflections used: %d" % reflect_count


func show_level_finished() -> void:
	start_button.hide()
	level_finished_menu.show()


func show_level_retry() -> void:
	start_button.show()
	level_finished_menu.hide()
