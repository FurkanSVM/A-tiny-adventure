extends RigidBody2D


@onready var coin_sound: AudioStreamPlayer2D = $coin/AudioStreamPlayer2D


func _on_coin_body_entered(body: Node2D) -> void:
	GameManager.add_point()
	coin_sound.play(0.03)
	hide()
	get_node("coin/CollisionShape2D").queue_free()
	await coin_sound.finished
	queue_free()
