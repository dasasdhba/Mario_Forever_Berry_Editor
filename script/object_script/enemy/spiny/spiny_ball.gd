extends Node

export var spiny_res :PackedScene

onready var parent :Node = get_parent()
onready var collision :CollisionShape2D = parent.get_node(parent.shape_name)
onready var solid_detect :bool = parent.move_and_collide(-parent.gravity_direction,true,true,true) != null

func _ready() ->void:
	if solid_detect:
		collision.disabled = true

func _physics_process(_delta) ->void:
	if solid_detect:
		collision.disabled = false
		if parent.move_and_collide(-parent.gravity_direction,true,true,true):
			collision.disabled = true
		else:
			solid_detect = false
	if parent.is_on_floor():
		var new :Node = spiny_res.instance()
		Berry.transform_copy(new,parent)
		new.dir_to_player = true
		parent.get_parent().add_child(new)
		parent.queue_free()
