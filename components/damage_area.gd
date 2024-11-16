extends Area2D
class_name DamageArea

func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    var player = body as Player
    if not player:
        return

    if player.is_dead():
        return

    player.damage()
