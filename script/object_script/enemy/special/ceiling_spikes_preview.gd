tool
extends Node2D

export var color :Color = Color(0.8,0.1,0.3,0.75)
export var preview_width :int = 1920

func _ready() ->void:
	if !Engine.editor_hint:
		queue_free()

func _draw() ->void:
	if Engine.editor_hint:
		var parent :Node = get_parent()
		if parent.preview:
			# 编辑器预览
			var pos :Vector2 = get_global_mouse_position() - global_position
			var x :float = floor(pos.x/32)*32 - preview_width
			draw_line(Vector2(x,0),Vector2(x+preview_width*2,0),color,2)
			draw_line(Vector2(x,parent.fall_height),Vector2(x+preview_width*2,parent.fall_height),color,2)

func physics_process(_delta) ->void:
	update()
