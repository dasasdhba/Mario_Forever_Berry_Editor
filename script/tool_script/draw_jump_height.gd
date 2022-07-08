tool
extends Node2D

export var preview_color :Color = Color(1,0,0,0.7)

func _ready() ->void:
	if !Engine.editor_hint:
		queue_free()

func _draw() ->void:
	var parent :Node = get_parent()
	if parent.jump_height > 0:
		draw_line(Vector2.ZERO,Vector2(0,-parent.jump_height),preview_color)
	
func _physics_process(_delta) ->void:
	update()
