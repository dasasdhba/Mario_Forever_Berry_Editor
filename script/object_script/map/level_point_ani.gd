extends Sprite

export var amplitude :float = 2
export var speed :float = 20
enum DIR {UP = -1, DOWN = 1}
export var dir :int = DIR.UP

onready var origin_position :Vector2 = position

func _process(delta) ->void:
	position += speed*dir*Vector2.DOWN * delta
	if position.distance_to(origin_position) >= amplitude:
		position = origin_position + amplitude*dir*Vector2.DOWN
		dir *= -1
