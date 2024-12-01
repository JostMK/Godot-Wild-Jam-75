@tool
extends Area2D
class_name DamageArea

const DANGER_LAYER: int = 4
const PLAYER_LAYER: int = 2

func _ready() -> void:
	# to make sure collision shapes always get drawn on top when debugging
	z_index = 1000
	collision_layer = DANGER_LAYER
	collision_mask = PLAYER_LAYER
	
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
