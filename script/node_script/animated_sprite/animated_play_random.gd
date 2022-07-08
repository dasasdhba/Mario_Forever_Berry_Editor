# 随机定时播放
extends AnimatedSprite

export var time: float = 0.1
export var probability :float = 0.05

var timer :float = 0

onready var rand :RandomNumberGenerator = Berry.get_rand(self)

func _ready() ->void:
	connect("animation_finished",self,"on_animation_finished")

func _physics_process(delta) ->void:
	if playing:
		return
	timer += delta
	if timer >= time:
		timer = 0
		if rand.randf() < probability:
			frame = 0
			play()
			
func on_animation_finished() ->void:
	stop()
