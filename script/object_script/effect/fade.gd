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
	if target is Sprite || target is AnimatedSprite:
		var new: Node2D = target.duplicate()
		if new is AnimatedSprite:
			new.speed_scale = 0
		add_child(new)
		
func _process(delta) ->void:
	alpha_accumulate += alpha_speed * delta
	modulate.a = min(1,alpha_origin*alpha_scale) - alpha_accumulate
	if modulate.a <= 0:
		queue_free()
