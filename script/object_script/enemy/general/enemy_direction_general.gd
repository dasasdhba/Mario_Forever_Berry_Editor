# 配合 enemy_physics_general 使用
extends AnimatedSprite

export var look_player :bool = false
export var disabled :bool = false

onready var parent :Node = get_parent()
onready var root :Node = parent.get_parent()

func _physics_process(_delta):
	if disabled:
		return
	if look_player:
		var p :Node = Berry.get_player_nearest(self)
		if p == null:
			return
		var p_pos :Vector2 = root.global_transform.xform_inv(p.global_position)
		if parent.position.direction_to(p_pos).dot(parent.gravity_direction.tangent()) > 0:
			flip_h = false
		else:
			flip_h = true
	else:
		flip_h = parent.direction != 1
