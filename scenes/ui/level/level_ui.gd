extends Control
class_name LevelUI

signal StartLevel

@onready var status_label: Label = %StatusLabel
@onready var start_button: Button = %StartButton
@onready var stats_label: Label = %StatsLabel

func _ready() -> void:
	start_button.pressed.connect(StartLevel.emit)


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
