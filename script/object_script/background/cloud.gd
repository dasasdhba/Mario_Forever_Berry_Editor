extends Node2D

export var disabled :bool = true
export var speed :float = 50
export var radius :Vector2 = Vector2(20,10)

onready var origin_position :Vector2 = position
onready var rand :RandomNumberGenerator = Berry.get_rand(self)
onready var phase :float = 360*rand.randf()

func _physics_process(delta) ->void:
	if disabled:
		return
	position = origin_position + radius.rotated(deg2rad(phase))
	phase += speed * delta
