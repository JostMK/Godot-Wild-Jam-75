extends Control
class_name LevelUI

signal StartLevel

@onready var status_label: Label = %StatusLabel
@onready var start_button: Button = %StartButton

func _ready() -> void:
	start_button.pressed.connect(StartLevel.emit)


func set_status_text(text: String) -> void:
	status_label.text = text


func set_button_text(text: String) -> void:
	start_button.text = text
