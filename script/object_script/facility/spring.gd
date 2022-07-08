extends Area2D

export var height_normal :float = 60.5
export var height_jump :float = 180.5
export var jump_time :float = 0.14
export var brush_border :Rect2 = Rect2(-16,-24,32,48)
export var brush_offset :Vector2 = Vector2(16,24)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _ready() ->void:
	if !is_connected("area_entered",self,"on_area_entered"):
		connect("area_entered",self,"on_area_entered")
		
func on_area_entered(area :Area2D) ->void:
	if !area.has_method("_player"):
		return
	var p :Node = area.get_parent()
	if p.gravity <= 0:
		return
	if p.control_jump > 0 && p.jump_key_time < jump_time:
		p.gravity = -sqrt(2*p.gravity_acceleration*height_jump)
	else:
		p.gravity = -sqrt(2*p.gravity_acceleration*height_normal)
	$Jump.play()
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play()

func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 0
