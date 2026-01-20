extends RigidBody2D


@onready var pick_fruit: AudioStreamPlayer2D = $pick_fruit


func collect_heart(player):
	if player.get_health() < 5:
		pick_fruit.play()
		player.increase_health()
		hide()
		get_node("Area2D/CollisionShape2D").free()
		await pick_fruit.finished
		queue_free()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	collect_heart(body)
