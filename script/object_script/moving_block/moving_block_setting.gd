extends Area2D

enum MODE {AUTOMATIC, PLAYER_STAND_ON}
enum BEHAVIOR {STOP, TURN, GRADIENT, NONE = -1}
enum FALL {FORCE, CANCEL, NONE = -1}

export var once :bool = false
export var velocity_override :bool = true
export var velocity :Vector2 = Vector2(100,0)
export var gradient_override :bool = false
export var gradient_time :float = 1 # 渐变转向时间
export var mode_override :bool = true
export(MODE) var mode :int = MODE.AUTOMATIC
export var reverse_override :bool = false
export(BEHAVIOR) var reverse_mode :int = BEHAVIOR.TURN
export var reflect_override :bool = false
export(BEHAVIOR) var reflect_mode :int = BEHAVIOR.TURN
export var turn_override :bool = false
export(BEHAVIOR) var turn_mode :int = BEHAVIOR.GRADIENT
export var solid_override :bool = false
export(BEHAVIOR) var solid_mode :int = BEHAVIOR.NONE
export(FALL) var fall_state :int = FALL.NONE
export var fall_override :bool = false
export var fall :bool = false
export var fall_max :float = 500
export var fall_acceleration :float = 500
export var fall_angle :float = 90 # 角度

# 用于标识
func _moving_block_setting(block :MovingBlock) ->void:
	if velocity_override:
		block.velocity = velocity
	if gradient_override:
		block.gradient_time = gradient_time
	if mode_override:
		block.mode = mode
	if reverse_override:
		block.reverse_mode = reverse_mode
	if reflect_override:
		block.reflect_mode = reflect_mode
	if turn_override:
		block.turn_mode = turn_mode
	if solid_override:
		block.solid_mode = solid_mode
	if fall_state == FALL.FORCE:
		block.player_detect = true
		block.fall = true
	elif fall_state == FALL.CANCEL:
		block.player_detect = false
		block.fall = false
		block.fall_speed = 0
	if fall_override:
		block.fall = fall
		block.fall_max = fall_max
		block.fall_acceleration = fall_acceleration
		block.fall_angle = fall_angle
	if once:
		queue_free()
