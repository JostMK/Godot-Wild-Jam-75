extends Area2D
class_name LevelButton

@export var targets: Array[Node] = []

func _ready() -> void:
	# remove all nodes that do not have the 'toggle' method
	for i in range(targets.size() - 1, -1, -1):
		if not targets[i].has_method("toggle"):
			targets.remove_at(i)
	
	body_entered.connect(_toggle)
	

func _toggle(body: Node2D) -> void:
	var player: Player = body as Player

	if not player:
		return

	if player.is_dead():
		return

	for target in targets:
		target.toggle()
