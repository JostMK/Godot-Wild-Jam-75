@tool
extends Area2D
class_name Finish

signal Finished

@export var size: Vector2 = Vector2(100, 100):
	set(value):
		size = value
		_update_visuals()


@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var sprite: Sprite2D = %Sprite2D

func _ready() -> void:
	_update_visuals()

	body_entered.connect(_on_body_entered)


func _update_visuals() -> void:
	if not collision_shape or not sprite:
		return
	
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	collision_shape.shape = shape

	sprite.scale = Vector2(size.x / 256, size.y / 256)


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if not player:
		return

	if player.is_dead():
		return

	Finished.emit()
