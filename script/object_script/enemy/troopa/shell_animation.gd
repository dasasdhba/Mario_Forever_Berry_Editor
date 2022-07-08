tool
extends AnimatedSprite

export var disabled = false

onready var parent: Node = get_parent()

func _physics_process(_delta):
	if Engine.editor_hint:
		parent = get_parent()
		if parent.move_at_start:
			play()
		else:
			frame = 3
			stop()
		return
	if disabled || parent.speed == 0:
		frame = 3
		stop()
	else:
		play()
