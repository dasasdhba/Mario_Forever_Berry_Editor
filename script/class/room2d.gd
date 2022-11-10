# 用于 Scene 管理的 class
extends Node2D
class_name Room2D, "icon/room2d.png"

export var pause_disabled :bool = false
export var touch_button_disabled :bool = false
export var random_seed :String = ""

var manager :Node = Scene
var hud :Control = null
var node_array :Array = [] # 用于暂存部分节点
	
func _ready() ->void:
	room2d_ready()

func room2d_ready() ->void:
	manager.current_room = self
	# 全局设置
	Global.pause_disabled = pause_disabled
	Global.touch_button_disabled = touch_button_disabled
