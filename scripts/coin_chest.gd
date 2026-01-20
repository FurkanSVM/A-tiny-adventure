extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var coin_scene: PackedScene

var is_open = 0


func _ready() -> void:
	is_open = 0

func _on_body_entered(body: Node2D) -> void:
	open()

func open():
	if not is_open:
		animated_sprite_2d.play("open_v2")
		is_open = 1
		create_coins(5)
		
func create_coins(i):
	for j in range(0,i):
		var coin = coin_scene.instantiate()
		coin.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		get_tree().current_scene.add_child(coin)
		coin.apply_impulse(Vector2(randf_range(-60,60),randf_range(-200,-300)))
