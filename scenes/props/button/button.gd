extends Area2D
class_name LevelButton

@export var targets: Array[Node] = []

func _ready() -> void:
	# remove all nodes that do not have the 'toggle' method
	for i in range(targets.size() - 1, -1, -1):
		if not targets[i].has_method("toggle"):
			targets.remove_at(i)
	
	body_entered.connect(_toggle.unbind(1))
	

func _toggle() -> void:
	for target in targets:
		target.toggle()
