extends Camera2D
class_name FollowCamera

@export var target: Node2D 

@export var speed: float = 500

func set_target(new_target: Node2D) -> void:
	target = new_target
	

func _process(delta: float) -> void:
	if not target:
		return

	global_position.x = move_toward(global_position.x, target.global_position.x, speed * delta)
