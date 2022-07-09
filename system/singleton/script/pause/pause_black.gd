extends Node2D

onready var size :Vector2 = get_viewport_rect().size

func _draw() ->void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(0,0,0,0.5),true)
