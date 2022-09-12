extends Area2D

export var once :bool = false
export var offset :Vector2 = Vector2(0,-512)

export var brush_border :Rect2 = Rect2(0,0,32,32)
export var brush_offset :Vector2 = Vector2(0,0)

# 用于标识
func _moving_block_teleport() ->Vector2:
	return offset
