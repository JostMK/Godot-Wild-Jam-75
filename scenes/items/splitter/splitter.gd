extends Area2D
class_name SplitterItem

func _ready() -> void:
	body_entered.connect(_split)


func _split(body: Node2D):
	var player: Player = body as Player

	if not player:
		return

	set_deferred("monitoring", false)
	player.call_deferred("split")
	queue_free()
