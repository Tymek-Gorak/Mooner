extends RigidBody2D

export var friction_custom : float
export var friction_multiplier : float
export var is_attacking := false

onready var stacking_knockback_clock = $"%KnockbackTimeLeft"
var knockback := false
var rng = RandomNumberGenerator.new()

#random variable starting points
export var base_distance_kept_from_player : float
export var base_knockback_distance : float
export var base_speed : int
export var base_max_speed : int

#variables which get randomly altered
onready var distance_kept_from_player = base_distance_kept_from_player * rand_range(0.8, 1.2)
onready var knockback_distance := base_knockback_distance * rand_range(0.8, 1.2)
export onready var speed := base_speed * rand_range(0.8, 1.2)
export onready var max_speed := base_max_speed * rand_range(0.8, 1.2)

onready var sprite := $"%Sprite"
onready var get_hit_anim := $"%GettingHitAnim"
onready var attack_anim := $"%AttackAnim"
onready var player = get_tree().get_nodes_in_group("player")[0]

func _ready():
	rng.randomize()
	
	#random scale on spawn
	var rand_scale := rand_range(.8, 1.2)
	for i in [sprite, $"%hurtBox", $"%CollisionShape2D"]:
		i.scale = i.scale * rand_scale
	
	#connect player detection for attacking
	$"%StartAttackArea".connect("body_entered", self, "attack")
	
func _process(delta):
	
	#changing directions
	if linear_velocity.x < -2 and sprite.scale.x < 0:
		sprite.scale = Vector2(abs(sprite.scale.x), sprite.scale.y)
	elif linear_velocity.x > 2 and sprite.scale.x > 0:
		sprite.scale = Vector2(abs(sprite.scale.x), abs(sprite.scale.y) * -1) * -1
	elif linear_velocity.x > -0.1 and linear_velocity.x < 0.1 and knockback == false:
		if player.position.x - position.x > 0:
			sprite.scale = Vector2(abs(sprite.scale.x), abs(sprite.scale.y) * -1) * -1
		else:
			sprite.scale = Vector2(abs(sprite.scale.x), sprite.scale.y)
	
	
func _physics_process(delta):
	#custom friction
	if linear_velocity.x != 0:
		apply_impulse(Vector2.ZERO, Vector2(min(friction_custom, abs(linear_velocity.x)) * friction_multiplier * -sign(linear_velocity.x), 0))
	
	#walk towards player
	if is_attacking == false:
		if player.position.x - position.x + 80 - distance_kept_from_player < 0 and knockback == false:
			linear_velocity.x = clamp(linear_velocity.x, -max_speed, max_speed)
			apply_impulse(Vector2.ZERO, Vector2.LEFT * speed)
		elif player.position.x - position.x - 80 - distance_kept_from_player > 0 and knockback == false:
			linear_velocity.x = clamp(linear_velocity.x, -max_speed, max_speed)
			apply_impulse(Vector2.ZERO, Vector2.RIGHT * speed)
	
	
	
func attack(player_but_in_this_function := player):
	attack_anim.play("attack")
	yield(attack_anim,"animation_finished")
	if $"%StartAttackArea".get_overlapping_bodies().size() != 0:
		attack()
	
	
	#takes damage
func take_damage_knockback(damage, knockback_direction):
	get_hit_anim.play("RESET")
	attack_anim.stop()
	is_attacking = false
	get_hit_anim.play("take_damage_anim")
	
	#knockback handling
	knockback = true
	
	if knockback_direction.x > 0:
		apply_impulse(Vector2.ZERO, Vector2(750 * knockback_distance, 0))
	else:
		apply_impulse(Vector2.ZERO, Vector2(-750 * knockback_distance, 0))
	
	stacking_knockback_clock.stop()
	stacking_knockback_clock.start()
	yield(stacking_knockback_clock, "timeout")
	if stacking_knockback_clock.time_left <= 0:
		attack_anim.stop()
		is_attacking = false
		knockback = false
	
	print(damage)








