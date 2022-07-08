extends Node2D

export var disabled :bool = true
export var speed :float = 50
export var radius :Vector2 = Vector2(20,10)

onready var origin_position :Vector2 = position
onready var rand :RandomNumberGenerator = Berry.get_rand(self)
onready var phase :float = 2*PI*rand.randf()

export var brush_border :Rect2 = Rect2(0,0,32,32)
export var brush_offset :Vector2 = Vector2(0,0)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass


func _physics_process(delta) ->void:
	if disabled:
		return
	position = origin_position + radius.rotated(phase)
	phase += speed * delta
