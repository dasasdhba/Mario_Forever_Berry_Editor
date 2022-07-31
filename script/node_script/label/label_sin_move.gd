extends Label

export var radius :Vector2 = Vector2(0,25)
export var phase :float = 0
export var speed :float = 100

onready var origin_position :Vector2 = rect_position

func _physics_process(delta) ->void:
	phase += speed * delta
	phase = wrapf(phase,0,360)
	var new_pos :Vector2 = Vector2(radius.x*cos(deg2rad(phase)),radius.y*sin(deg2rad(phase)))
	rect_position = origin_position + new_pos
