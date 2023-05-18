extends Node
var dummy = load("res://prefab_scenes/chipsEnemy.tscn") 

func _ready():
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("debug_spawn"):
		var spawned_dummy = dummy.instance()
		owner.add_child(spawned_dummy)
		spawned_dummy.position = Vector2(300,0)
