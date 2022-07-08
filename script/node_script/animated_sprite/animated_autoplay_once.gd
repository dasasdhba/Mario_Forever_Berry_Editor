# 自动播放，播放结束后自动 free
extends AnimatedSprite

func _ready() ->void:
	play()
	connect("animation_finished",self,"on_animation_finished")

func on_animation_finished() ->void:
	queue_free()
