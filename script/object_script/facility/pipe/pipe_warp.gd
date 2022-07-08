tool
extends Node2D

enum MODE {JUMP, PASS}
export(MODE) var mode :int = MODE.JUMP
export var next_scene :PackedScene
export var pass_res :PackedScene

var once :bool = false

export var brush_border :Rect2 = Rect2(-32,-32,64,64)
export var brush_offset :Vector2 = Vector2(0,0)

onready var parent :Node = get_parent()

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass
	
func _ready() ->void:
	if Engine.editor_hint:
		return
	if !parent.has_method("_pipe_enter"):
		queue_free()

func _physics_process(_delta) ->void:
	if Engine.editor_hint:
		$AnimatedSprite.frame = mode
		return
	if once:
		return
	for i in parent.player:
		if i.pipe == 5:
			if mode == MODE.JUMP:
				if next_scene != null:
					var scene :Node = Berry.get_scene(self)
					for j in scene.current_player:
						Player.disable(j)
					scene.change_scene(next_scene)
			else:
				level_pass()
			once = true
			break
		
func level_pass() ->void:
	var new :Node = pass_res.instance()
	new.visible = false
	new.next_scene = next_scene
	add_child(new)
	new._level_pass()
