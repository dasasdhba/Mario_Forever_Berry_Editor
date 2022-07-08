# 砖块被顶动画
extends AnimatedSprite

var ani_offset :Vector2 = Vector2.ZERO
const ani_speed :float = 60.0

func _physics_process(delta) ->void:
	if position != ani_offset:
		position -= ani_speed*Vector2.RIGHT.rotated(position.angle_to_point(ani_offset)) * delta
		if position.distance_to(ani_offset) <= ani_speed/50:
			position = ani_offset
			ani_offset = Vector2.ZERO
