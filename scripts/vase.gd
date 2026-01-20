extends AnimatedSprite2D
class_name Destructible

@onready var vase: AnimatedSprite2D = $"."
@onready var player: CharacterBody2D = %Player
@onready var breaking_sound: AudioStreamPlayer2D = $breaking_sound

var broke = 0

func _ready() -> void:
	broke = 0
	
func _on_player_enemy_die(collider) -> void:
	if collider == get_node("breakable_area"):
		print("asdd")
		if not broke:
			self.play("break")
			breaking_sound.play()
			broke = 1
