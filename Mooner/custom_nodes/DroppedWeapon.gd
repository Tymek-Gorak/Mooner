extends KinematicBody2D
class_name DroppedWeapon


export var durability : int

export var weapon_type : int
#weapon types:
# 1 - doritos
# 2 - water bottle


var velocity := Vector2(0,0)

func _ready():
	weapon_type = (randi() % 2 + 1)

func _physics_process(delta):
	velocity.y = 250
	velocity = move_and_slide(velocity)

