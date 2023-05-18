class_name hurtBox
extends Area2D


func _ready():
	connect("area_entered", self, "on_hit_received")

func on_hit_received(hitbox: hitBox):
	if(hitbox == null):
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	elif owner.has_method("take_damage_knockback"):
		owner.take_damage_knockback(hitbox.damage, hitbox.owner.direction)
		
		#time slow down on hitting enemy
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property(Engine, "time_scale", 0.4, 0.02)
		tween.tween_property(Engine, "time_scale", 1.0, 0.02).set_ease(Tween.EASE_OUT)
