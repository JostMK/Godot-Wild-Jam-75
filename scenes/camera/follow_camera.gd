extends Camera2D
class_name FollowCamera

@export var target: Node2D :
	set(value):
		target = value
		if target:
			offset = target.global_position * -1

@export var speed: float = 500

func _ready():
	if target:
		offset = target.global_position * -1


func _process(delta: float) -> void:
	if not target:
		return

	global_position.x = move_toward(global_position.x, target.global_position.x, speed * delta)
