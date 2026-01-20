extends AnimatedSprite2D

signal got_hit
signal game_over
var health = 0
var getting_hit = 0
var boss_fight_on = 0
var side_l = 0
var is_attacking = 0
var left_shooting_place = Vector2 (3817, -60)
var right_shooting_place = Vector2 (4276, -61)

var fire_time = 10
var is_up = 0
var firing = 0
var speed = 150
var hitting = 0

@onready var blasting_fire_sound: AudioStreamPlayer2D = $blasting_fire_sound
@onready var hurt_sound: AudioStreamPlayer2D = $hurt_sound
@onready var dying_sound: AudioStreamPlayer2D = $dying_sound
@onready var player: CharacterBody2D = %Player
@onready var boss_music: AudioStreamPlayer2D = $boss_music
@onready var fireball_sound: AudioStreamPlayer2D = $fireball_sound

@onready var main_attack_timer: Timer = $Main_attack_timer
@onready var fire_timer: Timer = $Fire_timer

@export var fire_scene: PackedScene
@export var slime_scene: PackedScene
@export var bat_scene: PackedScene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("enterr")
		emit_signal("got_hit")

func _ready() -> void:
	health = 10
	boss_fight_on = 0
	
func distance_to_player():
	return  global_position.distance_to(player.global_position)
	
func fire():
	fireball_sound.play()
	var breath = fire_scene.instantiate()
	breath.global_position = global_position - Vector2(0,-10)
	breath.connect("got_hit", Callable(player,"_on_enemy_got_hit"))
	
	if player.global_position.x > global_position.x:
		breath.scale.x = -1

	get_tree().current_scene.add_child(breath)
		
func die():
	health = 0
	set_process(false)
	set_physics_process(false)
	self.play("death")
	dying_sound.play()
	get_node("Area2D/CollisionShape2D").queue_free()
	await animation_finished
	await dying_sound.finished
	boss_music.stop()
	Music.play()
	emit_signal("game_over")
	queue_free()
	
	
func deploy_slime(how_much):
	for i in range(0,how_much):
		var slime = slime_scene.instantiate()
		slime.global_position = Vector2(global_position.x,-29)
		slime.player = player
		get_tree().current_scene.add_child(slime)
		
func deploy_bat(how_much):
	for i in range(0,how_much):
		var bat = bat_scene.instantiate()
		bat.global_position = global_position
		bat.player = player
		get_tree().current_scene.add_child(bat)
		
func main_attack(delta):
	if not is_up :
		if global_position.y > -110:
			position.y -= 300 *delta
		else:
			is_up = 1
	else:
		var destination
		if side_l:
			destination = left_shooting_place
		else:
			destination = right_shooting_place
		var distance = global_position.distance_to(destination)
		if distance > 5:
			position.x += (destination[0] - global_position.x) / distance  * delta * speed
			position.y += (destination[1] - global_position.y) / distance  * delta * speed
		else:
			if fire_time != 0:
				if not firing:
					hitting = 1
					print("i fired")
					print("fire_time:", fire_time)
					fire_time -= 1
					firing = 1
					fire_timer.start()
			else:
				deploy_slime(1)
				deploy_bat(1)
				hitting = 0
				side_l ^= 1
				fire_time = 10
				is_attacking = 0
				is_up = 0
				firing = 0
				main_attack_timer.start()
	
	
	
	
func _physics_process(delta: float) -> void:
	if is_attacking:
		main_attack(delta)
		
func _process(delta: float) -> void:
	if not getting_hit and not hitting and health>0:
		self.play("default")
	
	if distance_to_player() < 200 and boss_fight_on == 0:
		boss_fight_on = 1
		main_attack_timer.start()
		Music.stop()
		boss_music.play()
	
	if player.global_position.x < global_position.x:
		self.scale.x = 1
	else:
		self.scale.x = -1
		
func _on_player_enemy_die(collider) -> void:
	if collider == get_node("Area2D"):
		getting_hit = 1
		health -= 1
		if health == 0:
			die()
		else:
			hurt_sound.play()
			self.play("got_hit")


func _on_animation_finished() -> void:
	if self.animation == "got_hit":
		getting_hit = 0


func _on_main_attack_timer_timeout() -> void:
	is_attacking = 1


func _on_fire_timer_timeout() -> void:
	global_position = Vector2(global_position.x, randf_range(global_position.y -40, global_position.y+40))
	fire()
	print("firing: ", firing)
	self.play("hit")
	firing = 0
