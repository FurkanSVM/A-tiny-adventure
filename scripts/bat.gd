extends AnimatedSprite2D


@onready var dying_soung: AudioStreamPlayer2D = $dying_soung



var direction = null
var speed = 60
var dying = 0
var player 

signal got_hit

func _ready():
	if not player:
		player = %Player
	self.connect("got_hit",Callable(player,"_on_enemy_got_hit"))
	player.connect("enemy_die",Callable(self,"_on_player_enemy_die"))

	
func die():
	dying_soung.play()
	self.play("death")
	get_node("Area2D/CollisionShape2D").free()
	await self.animation_finished
	queue_free()
	 
func get_direction():
	var a = 0 ; var b = 0;
	if player.global_position[0] < global_position[0]:
		a = -1
	else:
		a = 1
	if player.global_position[1] < global_position[1]:
		b = -1 
	else:
		b = 1
	return [a,b]
	
func _on_player_enemy_die(collider) -> void:
	if collider == get_node("Area2D"):
		dying = 1
		die()
func distance_to_player():
	return  global_position.distance_to(player.global_position)
	
func distance_to_player_x():
	return  abs(global_position.x - player.global_position.x)
	
func distance_to_player_y():
	return  abs(global_position.y - player.global_position.y)
	
func _process(delta: float) -> void:
	direction = get_direction()
	
	if not dying and distance_to_player() < 300:
		position.x += direction[0] * speed * (distance_to_player_x()/distance_to_player()) * delta
		position.y += direction[1] * speed * (distance_to_player_y()/distance_to_player()) * delta
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	emit_signal("got_hit")
