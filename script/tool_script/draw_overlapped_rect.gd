tool
extends Node2D

export var color :Color = Color(1,0,0,0.3)
export var filled :bool = true

func _ready() ->void:
	if !Engine.editor_hint:
		queue_free()
		
func _draw() ->void:
	var parent :Node = get_parent()
	var tex :Texture
	if parent is Sprite:
		tex = parent.texture
	elif parent is AnimatedSprite:
		tex = parent.frames.get_frame("default",parent.frame)
	else:
		return
	var rect :Rect2 = Rect2(-tex.get_size()/2,tex.get_size())
	draw_rect(rect,color,filled)
		
func _physics_process(_delta) ->void:
	update()
