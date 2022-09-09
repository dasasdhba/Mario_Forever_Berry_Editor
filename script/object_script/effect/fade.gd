# 淡出特效
extends Node2D
export var alpha_scale :float = 1 # alpha 初始值
export var alpha_speed :float = 2 # alpha 变化速度
var alpha_origin :float = 0
var alpha_accumulate :float = 0

func inherit(target :Node2D) ->void:
	Berry.transform_copy(self,target)
	visible = target.visible
	modulate = target.modulate
	self_modulate = target.self_modulate
	material = target.material
	use_parent_material = target.use_parent_material
	alpha_origin = modulate.a
	alpha_accumulate = 0

func add_sprite(target :Node2D) ->void:
	var new = null
	if target is Sprite:
		new = Sprite.new()
		new.texture = target.texture
	elif target is AnimatedSprite:
		new = AnimatedSprite.new()
		new.frames = target.frames
		new.animation = target.animation
		new.frame = target.frame
		new.speed_scale = 0
		new.playing = false
	if new == null:
		return
	Berry.transform_copy(new,target)
	new.centered = target.centered
	new.offset = target.offset
	new.flip_h = target.flip_h
	new.flip_v = target.flip_v
	new.visible = target.visible
	new.modulate = target.modulate
	new.self_modulate = target.self_modulate
	new.material = target.material
	new.use_parent_material = target.use_parent_material
	add_child(new)
		
func _process(delta) ->void:
	alpha_accumulate += alpha_speed * delta
	modulate.a = min(1,alpha_origin*alpha_scale) - alpha_accumulate
	if modulate.a <= 0:
		queue_free()
