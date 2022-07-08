extends RectCollision2D

onready var parent :Node = get_parent()

func _physics_process(_delta):
	if parent.star:
		return
	for i in get_overlapping_rect("enemy_stomp"):
		i.stomp_detect(self)
