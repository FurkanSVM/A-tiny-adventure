extends Node2D

@onready var health_bar: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D



	
func _on_player_health_bar(health) -> void:
	health_bar.frame = 5-health
