extends Area2D
class_name SplitterItem

func _ready() -> void:
	body_entered.connect(_split)


func reset() -> void:
	set_deferred("monitoring", true)
	show()


func _split(body: Node2D) -> void:
	var player: Player = body as Player

	if not player:
		return

	if player.is_dead():
		return

	set_deferred("monitoring", false)
	hide()
	
	player.call_deferred("split")
