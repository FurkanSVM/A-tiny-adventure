extends Area2D

@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"../Player"


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("wasted")
		timer.start()
	

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
