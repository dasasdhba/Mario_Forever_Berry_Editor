# 配合 enemy_physics_general 使用
extends AnimatedSprite

export var look_player :bool = false
export var disabled :bool = false

onready var parent :Node = get_parent()
onready var scene :Node = Berry.get_scene(self)

func _physics_process(_delta):
	if disabled:
		return
	if look_player:
		var p :Node = scene.get_player_nearest(self)
		if p == null:
			return
		var p_pos :Vector2 = Berry.get_xform_position(parent,p.global_position)
		flip_h = parent.position.direction_to(p_pos).dot(parent.gravity_direction.tangent()) <= 0
	else:
		flip_h = parent.direction != 1
