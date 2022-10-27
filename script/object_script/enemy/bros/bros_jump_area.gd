tool
extends Area2D

enum TYPE {UP, DOWN}
export(TYPE) var type :int = TYPE.UP

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
