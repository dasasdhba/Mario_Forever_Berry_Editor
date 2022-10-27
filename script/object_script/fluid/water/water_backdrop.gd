tool
extends Water

export var water_color :Color = Color(0.5,0.66,0.88,0.5)
export var preview_color :Color = Color(0.5,0.66,0.88,0.3)

func _draw() ->void:
	var col :Color = water_color
	if Engine.editor_hint:
		col = preview_color
	var rect :Rect2 = Rect2(Vector2(0, 0), 32*Vector2.ONE)
	draw_rect(rect,col)
	
func _physics_process(_delta) ->void:
	update()
