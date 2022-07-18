extends Node2D

export var color :Color = Color(0,0,0,0.5)
export var automatic_update :bool = false

onready var size :Vector2 = get_viewport_rect().size

func _draw() ->void:
	draw_rect(Rect2(Vector2.ZERO,size),color,true)
	
func _process(_delta) ->void:
	if automatic_update && visible:
		update()
