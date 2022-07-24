extends Label

export var distance :float = 48
export var speed :float = 200

var down :bool = false

onready var origin_position :Vector2 = rect_position

func _physics_process(delta) ->void:
	if down:
		if origin_position.distance_to(rect_position) < distance:
			rect_position += speed * Vector2.DOWN * delta
	elif origin_position.distance_to(rect_position) > 0:
		rect_position -= speed * Vector2.DOWN * delta
