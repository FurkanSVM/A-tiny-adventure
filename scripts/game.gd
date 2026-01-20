extends Node2D
func _process(delta):
	$ParallaxBackground/ParallaxLayer/Sprite2D.global_position = $Camera2D.global_position
