extends AnimatedSprite2D

@onready var raycast_right: RayCast2D = $raycast_right
@onready var raycast_left: RayCast2D = $raycast_left
@onready var hurt_sound: AudioStreamPlayer2D = $hurt_sound
@onready var dying_sound: AudioStreamPlayer2D = $dying_sound
@onready var hit_sound: AudioStreamPlayer2D = $hit_sound


@export var heart_scene: PackedScene

const speed = 60

var direction = 1
var health = 2
var is_hurt = 0
var player 

signal got_hit

func _ready():
	if not player:
		player = %Player
	self.connect("got_hit",Callable(player,"_on_enemy_got_hit"))
	player.connect("enemy_die",Callable(self,"_on_player_enemy_die"))
	
func _process(delta):
	if raycast_right.is_colliding():
		direction = -1
		self.flip_h = true
	if raycast_left.is_colliding():
		direction =  1
		self.flip_h = false
	position.x += direction*speed*delta
	
	if not is_hurt:
		self.play("default")
	else:
		self.play("hurt")




func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	# hurt_sound.play()
	emit_signal("got_hit")
	
func create_fruit():
	var fruit = heart_scene.instantiate()
	fruit.global_position = global_position
	get_tree().current_scene.add_child(fruit)
	fruit.apply_impulse(Vector2(randf_range(-20,20),-200))
	
func die():
	print("killing")
	dying_sound.play()
	create_fruit()
	hide()
	get_node("Area2D/CollisionShape2D").queue_free()
	await dying_sound.finished
	
	queue_free()
	
	
func _on_player_enemy_die(collider) -> void:
	if collider == get_node("Area2D"):
		health -= 1
		if health == 0: 
			die()
		else:
			is_hurt = 1 
			hit_sound.play()
			


func _on_animation_finished() -> void:
	if animation == "hurt":
		is_hurt = 0
