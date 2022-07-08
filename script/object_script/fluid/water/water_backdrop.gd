tool
extends Water

export var water_color :Color = Color(0.5,0.66,0.88,0.5)
export var preview_color :Color = Color(0.5,0.66,0.88,0.3)

export var brush_border :Rect2 = Rect2(0,0,32,32)
export var brush_offset :Vector2 = Vector2(0,0)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _draw() ->void:
	var col :Color = water_color
	if Engine.editor_hint:
		col = preview_color
	var rect :Rect2 = Rect2(Vector2(0, 0), 32*Vector2.ONE)
	draw_rect(rect,col)
	
func _physics_process(_delta) ->void:
	update()
