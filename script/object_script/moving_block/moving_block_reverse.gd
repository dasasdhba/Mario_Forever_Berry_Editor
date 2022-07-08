extends AreaShared

export var once :bool = false

onready var parent :Node = get_parent()

func _ready() ->void:
	inherit(parent)

# 用于标识
func _moving_block_reverse() ->void:
	if once:
		parent.queue_free()
