extends Area2D

export var once :bool = false
export var offset :Vector2 = Vector2(0,-512)

# 用于标识
func _moving_block_teleport() ->Vector2:
	return offset
