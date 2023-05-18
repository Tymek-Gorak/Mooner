extends RigidBody2D

export var speed : float
export var jump_force : float

export var friction_custom : float
export var friction_multiplier : float

var ready_to_jump := false
var preparing_to_jump := false

var direction := Vector2.ZERO
var move_right_or_left := 0
var weapon_durability_left := 0

var current_weapon := 0
#weapon types:
# 1 - doritos
# 2 - water bottle

onready var dash_cooldown := $"%DashTimer"
onready var attack_cooldown_timer := $"%AttackCooldownTimer"
onready var sprite := $"%Sprite"
onready var hitbox_anim := $"%TempHitboxAnim"
onready var getting_hit_anim := $"%GettingHitAnim"
onready var jump_detection_zone := $"%JumpDetection"





func _ready():
	pass

func _process(delta):
	#falling gravity
	if linear_velocity.y > 0:
		gravity_scale = 1.7
	else:
		gravity_scale = 1
	
	#jump cancel
	if linear_velocity.y < 0 && Input.is_action_just_released("jump"):
		linear_velocity.y = 0
	
	#press jump
	if Input.is_action_just_pressed("jump") and ready_to_jump == true:
		jump()
	elif Input.is_action_just_pressed("jump") and ready_to_jump == false:
		#buffer time
		preparing_to_jump = true
		yield(get_tree().create_timer(.4), "timeout")
		preparing_to_jump = false
	elif preparing_to_jump == true and ready_to_jump == true:
		#jumping after buffer time
		preparing_to_jump = false
		yield(get_tree().create_timer(0.008), "timeout")
		jump() 
	
	#touch ground detected
	if jump_detection_zone.get_overlapping_bodies().size() != 0:
		ready_to_jump = true
		
	if Input.is_action_pressed("dash"):
		set_scale(.6)
		speed = 1200
	elif Input.is_action_just_released("dash"):
		speed = 600
		set_scale(1)
		

		
		
		
	if Input.is_action_just_pressed("attack") and attack_cooldown_timer.time_left <= 0:
		attack_cooldown_timer.start()
		attack()
		

func _physics_process(delta):
	
	# right and left move
	if Input.is_action_just_pressed("move_right"):
		move_right_or_left = 1
		linear_velocity.x = 0
		change_direcetion(1)
	
	if Input.is_action_just_pressed("move_left"):
		move_right_or_left = -1
		linear_velocity.x = 0
		change_direcetion(-1)
	
	if Input.is_action_pressed("move_right") and Input.is_action_just_released("move_left"):
		if move_right_or_left != 1:
			linear_velocity.x = 0
			move_right_or_left = 1
			change_direcetion(1)
	
	if Input.is_action_just_released("move_right") and Input.is_action_pressed("move_left"):
		if move_right_or_left != -1:
			linear_velocity.x = 0
			move_right_or_left = -1	
			change_direcetion(-1)
	
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):	
		apply_impulse(Vector2.ZERO, Vector2(speed * move_right_or_left, 0))
		

		
		
	#friction
	if linear_velocity.x != 0:
		var temp_friction_var = min(friction_custom, abs(linear_velocity.x)) * friction_multiplier * -sign(linear_velocity.x)
		apply_impulse(Vector2.ZERO, Vector2(temp_friction_var, 0))

func _unhandled_input(event):
	if event.is_action_pressed("pick_up"):
		for colision in get_colliding_bodies():
			if colision.is_in_group("pick_ups"):
				change_weapon(colision.weapon_type, colision.durability)
				break
	


	#change direction
func change_direcetion(left_right : int):
	if hitbox_anim.is_playing() == false:
		if left_right == 1:
			sprite.scale = Vector2(abs(sprite.scale.x), sprite.scale.y)
			direction = Vector2.RIGHT
		else:
			sprite.scale = Vector2(abs(sprite.scale.x), abs(sprite.scale.y) * -1) * -1
			direction = Vector2.LEFT
			



func attack():
	
	if weapon_durability_left == 0:
		
		#normal melee atack
		
		hitbox_anim.play("RESET")
		hitbox_anim.play("fist_attack")
		$"%hitBox".damage += 1
	
	else:
		if current_weapon == 1:
			
			#change to dorito attack
			
			hitbox_anim.play("RESET")
			hitbox_anim.play("fist_attack")
			weapon_durability_left -= 1
			print("mmm doritos")
		
		elif current_weapon == 2:
			
			#change to water attack
			
			hitbox_anim.play("RESET")
			hitbox_anim.play("fist_attack")
			weapon_durability_left -= 1
			print("mmm water")
		
		if weapon_durability_left == 0:
			change_weapon(0)
			

	
	
	

func jump():
	linear_velocity.y = -jump_force
	ready_to_jump = false
	
func change_weapon(new_weapon : int, new_durability := 0) -> void:
	current_weapon = new_weapon
	weapon_durability_left = new_durability
	
	print(new_weapon)
	#TO DO HERE:
	#SPRITE CHANGE
	#CHANGE DAMAGE
	




	#takes damage
func take_damage(damage):
	getting_hit_anim.play("RESET")
	getting_hit_anim.play("get_hit")
	
	print(damage, " player")

	#ground not touching
func _on_ground_stop_touching(body):
	#coyotee jump
	yield(get_tree().create_timer(0.1), "timeout")
	ready_to_jump = true

		#sets scale of the player character to any new scale
func set_scale(new_scale):
	for i in [$"%bodyCollision", $"%bodyCollision2", sprite]:
		i.scale = Vector2(new_scale * sign(i.scale.x), new_scale) 
		





