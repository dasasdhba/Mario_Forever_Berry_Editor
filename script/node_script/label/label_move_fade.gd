extends Label

export var distance :float = 30
export var direction :float = -90
export var speed :float = 100
export var fade_wait_time :float = 1
export var fade_speed :float = 3
export var disabled :bool = false

var timer :float = 0

onready var origin_position :Vector2 = rect_position

func _physics_process(delta :float) ->void:
	if disabled:
		return
	if rect_position.distance_to(origin_position) < distance:
		rect_position += speed * Berry.vector2_rotate_degree(direction) * delta
	else:
		timer += delta
		if timer >= fade_wait_time:
			modulate.a -= fade_speed * delta
			if modulate.a <= 0:
				queue_free()
