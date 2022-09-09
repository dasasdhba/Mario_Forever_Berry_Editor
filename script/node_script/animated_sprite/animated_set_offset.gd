# 逐帧调整 AnimatedSprite 的 Offset，使用 z 作为 frame
tool
extends AnimatedSprite

export var default_offset :Vector2 = Vector2.ZERO
export(Array,String) var custom_animation :Array = ["default"]
export(Array,Vector3) var custom_offset :Array = [Vector3.ZERO]
export var flip_h_fix :bool = false
export var flip_v_fix :bool = false

func _process(_delta) ->void:
	for i in custom_animation.size():
		if animation == custom_animation[i]:
			if frame == custom_offset[i].z:
				var new_offset :Vector2 = Vector2(custom_offset[i].x,custom_offset[i].y)
				if flip_h_fix && flip_h:
					new_offset.x *= -1
				if flip_v_fix && flip_v:
					new_offset.y *= -1
				offset = new_offset
				return
	offset = default_offset
