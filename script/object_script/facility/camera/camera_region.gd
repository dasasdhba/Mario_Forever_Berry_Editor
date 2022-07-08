# 不支持旋转
tool
extends Node2D

export var preview_color :Color = Color(0.5,0,0.5,0.3)

# 用于标识
func _camera_region() ->void:
	pass

func _draw() ->void:
	if !Engine.editor_hint:
		return
	var col :Color = preview_color
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE),col)
	draw_set_transform(Vector2.ZERO,-rotation,Vector2(1/scale.x,1/scale.y))
	draw_rect(Rect2(Vector2.ZERO,scale),Color(col.r,col.g,col.b,1),false,2)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _physics_process(_delta) ->void:
	if Engine.editor_hint:
		update()
