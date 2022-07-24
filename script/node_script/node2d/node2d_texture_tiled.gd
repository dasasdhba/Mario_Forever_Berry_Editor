# 无限平铺 Texture
tool
extends Node2D

export var texture :Texture
export var auto_update :bool = false

onready var size :Vector2 = texture.get_size()

var rect :Rect2

func _ready() ->void:
	if !Engine.editor_hint:
		if texture == null:
			queue_free()
			return
		rect = Rect2(Vector2.ZERO,Vector2(scale.x*size.x,scale.y*size.y))

func _draw() ->void:
	if texture == null:
		return
	draw_set_transform(Vector2.ZERO,0,Vector2(1/scale.x,1/scale.y))
	draw_texture_rect(texture,rect,true)
	
func _process(_delta) ->void:
	if Engine.editor_hint:
		if texture == null:
			update()
			return
		var _size :Vector2 = texture.get_size()
		rect = Rect2(Vector2.ZERO,Vector2(scale.x*_size.x,scale.y*_size.y))
		update()
		return
	if auto_update:
		rect = Rect2(Vector2.ZERO,Vector2(scale.x*size.x,scale.y*size.y))
		update()
