# 编辑器界面显示 hidden 贴图
tool
extends Node2D

var rect :Rect2 = Rect2(-16,-16,32,32)

func _ready() ->void:
	if !Engine.editor_hint:
		queue_free()
		
func _draw() ->void:
	var parent :Node = get_parent()
	if parent.hidden:
		draw_rect(rect,Color(1,1,1,0.5),true)
		if parent.once:
			var color :Color = Color(0.5,0,0,0.7)
			var width :float = 1.5
			draw_line(rect.position,rect.end,color,width)
			draw_line(Vector2(rect.end.x,rect.position.y),Vector2(rect.position.x,rect.end.y),color,width)
		
func _process(_delta) ->void:
	var parent :Node = get_parent()
	parent.move_child(self,parent.get_child_count()-1)
	update()
