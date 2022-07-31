extends Label

export var target_height :float = 24
export var acceleration :float = 1250
export var bounce_speed :float = 150
export var bounce_speed_random :int = 2

var speed :float = 0

onready var rand :RandomNumberGenerator = Berry.get_rand(self)

func _physics_process(delta) ->void:
	speed += acceleration * delta
	rect_position.y += speed * delta
	if rect_position.y >= target_height:
		rect_position.y = target_height
		speed = -bounce_speed - 50*rand.randi_range(0,bounce_speed_random)
