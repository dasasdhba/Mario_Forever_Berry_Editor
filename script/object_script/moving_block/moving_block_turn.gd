extends Area2D

export var once :bool = false

# 用于标识
func _moving_block_turn() ->void:
	if once:
		queue_free()
