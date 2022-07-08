# 逐帧调整 AnimatedSprite 的 Offset，使用 z 作为 frame
tool
extends AnimatedSprite

export var default_offset :Vector2 = Vector2.ZERO
export(Array,String) var custom_animation :Array = ["default"]
export(Array,Vector3) var custom_offset :Array = [Vector3.ZERO]

func _process(_delta) ->void:
	for i in custom_animation.size():
		if animation == custom_animation[i]:
			if frame == custom_offset[i].z:
				offset = Vector2(custom_offset[i].x,custom_offset[i].y)
				return
	offset = default_offset
