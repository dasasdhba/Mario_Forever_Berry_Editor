tool
extends Lava

export var lava_color :Color = Color(0.47,0,0,1)
export var preview_color :Color = Color(0.47,0,0,0.6)

func _draw() ->void:
	var col :Color = lava_color
	if Engine.editor_hint:
		col = preview_color
	var rect :Rect2 = Rect2(Vector2(0, 0), 32*Vector2.ONE)
	draw_rect(rect,col)
	
func _physics_process(_delta) ->void:
	update()
