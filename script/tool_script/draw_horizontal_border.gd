tool
extends Node2D

export var start :float = -480
export var height :float = 10016
export var preview_color :Color = Color(0.5,0.5,0,0.8)
export var width :float = 2

func _ready() ->void:
	if !Engine.editor_hint:
		queue_free()
		
func _draw() ->void:
	var parent :Node = get_parent()
	var xleft :float = parent.left_border - parent.global_position.x
	var xright :float = parent.right_border - parent.global_position.x
	var ytop :float = start - parent.global_position.y
	var ybottom :float = height - parent.global_position.y
	var trans :Transform2D = parent.global_transform.affine_inverse()
	trans.origin = Vector2.ZERO
	draw_set_transform_matrix(trans)
	draw_line(Vector2(xleft,ytop),Vector2(xleft,ybottom),preview_color,width)
	draw_line(Vector2(xright,ytop),Vector2(xright,ybottom),preview_color,width)
	
func _physics_process(_delta :float) ->void:
	update()
