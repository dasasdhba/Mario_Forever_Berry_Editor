# 用于 Scene 管理的 class
extends Node2D
class_name Room2D, "icon/room2d.png"

export var pause_disabled :bool = false
export var random_seed :String = ""

var manager :Node = Scene
var hud :Control = null
var water :Water = null
var lava :Area2D = null

func _ready() ->void:
	# Scene 单例初始化
	manager.current_room = self
	manager.current_scene = PackedScene.new()
	manager.current_scene.pack(self)
	# 暂停
	Global.pause_disabled = pause_disabled
