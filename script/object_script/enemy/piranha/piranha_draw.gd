# 绘制食人花
tool
extends Node2D

export var length :float = 48

var stem :Texture = null
var head :SpriteFrames
var frame: int = 0
var head_tex :Texture = null

var ani_count :float = 0

onready var parent: Node = get_parent()

func _ready() ->void:
	if !Engine.editor_hint:
		stem = $Stem.texture
		head = $Head.frames
		$Stem.queue_free()
		$Head.queue_free()
		modulate.a = 1

func _draw() ->void:
	if head_tex == null || length <= 0:
		return
	if length >= 32:
		draw_texture(head_tex,Vector2.ZERO)
	else:
		var crop :Rect2 = Rect2(0,0,head_tex.get_width(),length+2)
		draw_texture_rect_region(head_tex,crop,crop)
	var stem_len :float = length - 32
	if stem_len <= 0:
		return
	var i :int = 0
	while i < stem_len:
		var stem_pos :Vector2 = Vector2(3,34+i)
		var stem_crop :Vector2 = Vector2(stem.get_width(),min(16,stem_len - i))
		draw_texture_rect_region(stem,Rect2(stem_pos,stem_crop),Rect2(Vector2.ZERO,stem_crop))
		i += 16
	
func _physics_process(delta) ->void:
	if Engine.editor_hint:
		parent = get_parent()
		length = 32 + max(0,parent.stem_count)*16
		if parent.stem_count <= 0:
			modulate.a = 0.5
		else:
			modulate.a = 1
		stem = $Stem.texture
		head = $Head.frames
		position.y = -18 - 16*(max(0,parent.stem_count) - 1) 
			
	ani_count += delta
	if ani_count >= 1/head.get_animation_speed("default"):
		ani_count = 0
		frame += 1
		if frame >= head.get_frame_count("default"):
			frame = 0
	head_tex = head.get_frame("default",frame)
	update()
	
