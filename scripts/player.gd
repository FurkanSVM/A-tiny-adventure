extends CharacterBody2D


var SPEED = 120.0
const JUMP_VELOCITY = -300.0
const SECOND_JUMP_VELOCITY = -200.0
const DASH_VELOCITY = 200.0
const camera_2d_original_posiiton = Vector2(-0.596587, 0.0)
signal health_bar 
signal enemy_die
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = 0
var able_to_dash = 1
var dashing = 0
var cur_direction = 0
var health = 5
var dying  = 0
var disable_movement = 0
var got_hit = 0
var knocking_back = 0
var inv = 0
var being_inv = 0
var is_attacking = 0
var hit_done = 0
var hit_timer = 0
var enemy_on_right = 0
var enemy_on_left = 0
var enemies_to_hit = []
var enemies_that_got_hit = []
var screen_shake_end = 0
var is_ulting = 0
var ult_pressed = 0
# Camera Shake
var shake_duration = 0.0
var shake_intensity = 0

@onready var animated_sprite = $AnimatedSprite2D

@onready var dash_cooldown: Timer = $Dash_cooldown

@onready var dashing_timer: Timer = $Dashing

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var knocback_timer: Timer = $Knocback

@onready var invisibility_timer: Timer = $İnvisibility

@onready var sword_right: Area2D = $sword_right

@onready var sword_left: Area2D = $sword_left

@onready var hit_animation: Timer = $Hit_animation

@onready var hurt_sound: AudioStreamPlayer2D = $hurt_sound

@onready var camera_2d: Camera2D = $Camera2D


# Sword sounds 
@onready var sword_sound_1: AudioStreamPlayer2D = $sword_sound_1
@onready var sword_sound_2: AudioStreamPlayer2D = $sword_sound_2
# Dashing sound
@onready var dashing_sound: AudioStreamPlayer2D = $dashing_sound
# Jumping sound
@onready var jumping_sound: AudioStreamPlayer2D = $jumping_sound

enum PlayerState {IDLE, RUNNING, JUMPING, ATTACKING, DASHING, INVISIBLE, DYING}
var state = PlayerState.IDLE

func _ready():
	health = 5

func increase_health():
	health = min(health+1, 5)
	
func get_health() -> int:
	return health
	
func apply_gravity(delta):
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += 1.2 *gravity * delta
		else:
			velocity.y += gravity * delta
		
func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = PlayerState.JUMPING 
		velocity.y = JUMP_VELOCITY
		double_jump = 0
		jumping_sound.play()
	if Input.is_action_just_pressed("jump") and not is_on_floor() and double_jump == 0:
		velocity.y = SECOND_JUMP_VELOCITY
		double_jump = 1
		jumping_sound.play()
		
func dash():
	if dashing:
		# print("dashing")
		velocity.x = DASH_VELOCITY*cur_direction
		velocity.y = 0
		
	elif able_to_dash and Input.is_action_just_pressed("dash"): # dashing start
		# print("dashing start")
		dashing_timer.start()
		dashing = 1
		disable_movement = 1
		animated_sprite.play("roll(ground dash)")
		dashing_sound.play()
		
func die():
	disable_movement = 1
	animated_sprite.play("death")
	velocity.x = 0
	velocity.y = 0
	await animated_sprite.animation_finished
	dying = 0
	disable_movement = 0
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func knockback():
	disable_movement = 1
	velocity.x = cur_direction * -1 * 90
	velocity.y = 0
	# print("starterd knockback")
	if not knocking_back:
		knocking_back = 1
		knocback_timer.start()
				
func become_invisible():
	self.set_collision_layer_value(2, false)
	inv = 0
	if not being_inv:
		print("being invable")
		animated_sprite.play("invisible")
		being_inv = 1
		invisibility_timer.start()
		
func trigger_screen_shake(duration, intensity):
	shake_duration = duration  # 0.2 saniye kadar titreme
	shake_intensity = intensity # Şiddet
	camera_2d.position_smoothing_enabled = 0

	
func shake_screen(delta):
	shake_duration -= delta
	camera_2d.position +=  Vector2(
			randf_range(- shake_intensity,  shake_intensity),  # X ekseninde rastgele
			randf_range(- shake_intensity,  shake_intensity)   # Y ekseninde rastgele	
	)
	screen_shake_end = 1
	
func handle_attack(enemies):
	
	for enemy in enemies:
		if hit_done: break
		if enemy_on_right and cur_direction == 1 and enemy not in enemies_that_got_hit:
			print(enemy.name)
			emit_signal("enemy_die",enemy)
			if enemy.name != "breakable_area":
				trigger_screen_shake(0.2,2)
			enemies_that_got_hit += [enemy]
		elif enemy_on_left and cur_direction == -1 and enemy not in enemies_that_got_hit:
			print(enemy.name)
			emit_signal("enemy_die",enemy)
			if enemy.name != "breakable_area":
				trigger_screen_shake(0.2,2)
			enemies_that_got_hit += [enemy]
	
	
	if not hit_timer:
		hit_animation.start()
		hit_timer = 1
	
	
	
func _physics_process(delta):
	# Add the gravity.
	if not disable_movement:
		apply_gravity(delta)
	
	# Show health bar
	emit_signal("health_bar",health)
	
	if shake_duration > 0:
		shake_screen(delta)
	else:
		camera_2d.position = camera_2d_original_posiiton
		

		
	if Input.is_action_just_pressed("debugging"):
		print("debugging : ")
		print("is_attackin: ",is_attacking)
		print("got_hit: ",got_hit)
		print("being inv: ",being_inv)
		print("movement: ",disable_movement)
		print("camera pos: ",camera_2d.position)
		print("player:", self.position)
	# Handle jump.
	if not disable_movement:
		handle_jump()
		
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	if is_attacking:
		handle_attack(enemies_to_hit)
		
	if Input.is_action_just_pressed("ulti") and not ult_pressed:
		ult_pressed = 1
		
	if ult_pressed: 
		is_attacking = 1
		is_ulting = 1
		SPEED = 80
		animated_sprite.play("ulti")
		if Input.is_action_just_released("ulti"):
			SPEED = 100
			is_ulting = 0
			ult_pressed = 0
		
		
		
	if able_to_dash:
		dash()
	
	if got_hit :
		inv = 1
		knockback()
	
	if inv:
		become_invisible()
		
		
	# Flip the Sprite
	if not is_attacking:
		if direction > 0:
			animated_sprite.flip_h = false
			cur_direction = 1
		elif direction < 0:
			animated_sprite.flip_h = true
			cur_direction = -1
		
	# Play animations
	if not dying:
		if Input.is_action_just_pressed("hit") and not is_attacking:
			# print("sword hitting..")
			is_attacking = 1
			var random_val = randi() % 2
			if random_val:
				animated_sprite.play("sword_hit")
				sword_sound_1.play()
			else:
				animated_sprite.play("sowrd_hit_2")
				sword_sound_2.play()
				
		elif not is_attacking and not disable_movement and not being_inv and not dashing:	
			if is_on_floor():
				if direction == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump")
	
	# Apply movement
	if not disable_movement:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Death logic 
	if health == 0 and not dying:
		dying = 1
		die()
		
	move_and_slide()




func _on_dash_cooldown_timeout() -> void:
	# cooldown end
	able_to_dash = 1
	
func _on_dashing_timeout() -> void:
	# dashing end, cooldown
	dashing = 0
	able_to_dash = 0
	disable_movement = 0
	dash_cooldown.start()
	
func _on_enemy_got_hit() -> void:
	hurt_sound.play()
	health -= 1 
	if health > 0:
		got_hit = 1

func _on_knocback_timeout() -> void:
	knocking_back = 0
	got_hit = 0
	disable_movement = 0

func _on_invisibility_timeout() -> void:
	being_inv = 0
	print("invable end")
	self.set_collision_layer_value(2, true)
	print("inv:",inv)
	print("dis_movement:",disable_movement)
	print("is_attacking:",is_attacking)


		  


func _on_hit_animation_timeout() -> void:
	print("hit end")
	is_attacking = 0
	enemies_that_got_hit = []
	hit_timer = 0  
	camera_2d.position_smoothing_enabled = 1
	camera_2d.enabled = 1


func _on_sword_right_area_entered(area: Area2D) -> void:  # sağ kılıç
	print("enemy entered on right")
	enemy_on_right = 1
	enemies_to_hit += [area]


func _on_sword_right_area_exited(area: Area2D) -> void:
	print("enemy exited on right")
	enemy_on_right = 0
	enemies_to_hit.erase(area)
	
func _on_sword_left_area_entered(area: Area2D) -> void:   # sol kılıç
	print("enemy entered on left")
	enemy_on_left = 1
	enemies_to_hit += [area]


func _on_sword_left_area_exited(area: Area2D) -> void:
	print("enemy exited on left")
	enemy_on_left = 0
	enemies_to_hit.erase(area)
