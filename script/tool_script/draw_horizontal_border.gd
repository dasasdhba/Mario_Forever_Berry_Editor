tool
extends Node2D

export var preview_color :Color = Color(0.5,0.5,0,0.8)
export var preview_height :int = 1080
export var width :float = 2

func _ready() ->void:
	if !Engine.editor_hint:
		queue_free()
		
func _draw() ->void:
	var parent :Node = get_parent()
	var xleft :float = parent.left_border - parent.global_position.x
	var xright :float = parent.right_border - parent.global_position.x
	var pos :Vector2 = get_global_mouse_position() - global_position
	var y :float = floor(pos.y/32)*32 - preview_height
	var ytop :float = y
	var ybottom :float = y + 2*preview_height
	var trans :Transform2D = parent.global_transform.affine_inverse()
	trans.origin = Vector2.ZERO
	draw_set_transform_matrix(trans)
	draw_line(Vector2(xleft,ytop),Vector2(xleft,ybottom),preview_color,width)
	draw_line(Vector2(xright,ytop),Vector2(xright,ybottom),preview_color,width)
	
func _physics_process(_delta :float) ->void:
	update()
