tool
extends Area2D

enum TYPE {UP, DOWN}
export(TYPE) var type :int = TYPE.UP
	
export var brush_border :Rect2 = Rect2(0,0,288,32)
export var brush_offset :Vector2 = Vector2(0,0)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

# 用于标识
func _bros_jump() ->int:
	return type
	
func _ready() ->void:
	if !Engine.editor_hint:
		$AnimatedSprite.visible = false
	
func _physics_process(_delta):
	if !Engine.editor_hint:
		return
	$AnimatedSprite.frame = type
