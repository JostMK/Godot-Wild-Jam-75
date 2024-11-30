@tool
extends Area2D
class_name DamageArea

func _ready() -> void:
	# to make sure collision shapes always get drawn on top when debugging
	self.z_index = 1000

	if Engine.is_editor_hint():
		return

	body_entered.connect(_on_body_entered)

	
func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if not player:
		return

	if player.is_dead():
		return

	player.damage()
