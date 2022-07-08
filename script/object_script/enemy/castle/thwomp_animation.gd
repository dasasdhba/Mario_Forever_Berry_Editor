extends AnimatedSprite

func _ready() ->void:
	connect("animation_finished",self,"on_animation_finished")

func on_animation_finished() ->void:
	if animation != "default":
		animation = "default"
