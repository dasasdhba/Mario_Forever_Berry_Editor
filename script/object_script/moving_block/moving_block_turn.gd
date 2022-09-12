extends Area2D

export var once :bool = false

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,16)

# 用于标识
func _moving_block_turn() ->void:
	if once:
		queue_free()
