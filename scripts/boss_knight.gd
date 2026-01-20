extends CharacterBody2D


@onready var player: CharacterBody2D = %Player
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta):
	self.scale.x = -1
	if global_position.distance_to(player.global_position) < 50 :
		animated_sprite_2d.play("attack")
	else:
		animated_sprite_2d.play("default")
