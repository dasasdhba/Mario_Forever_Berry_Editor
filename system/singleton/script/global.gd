# 全局变量与程序设置
extends Node

# 是否允许暂停
var pause_disabled :bool = false

# 是否显示虚拟按键(移动端)
var touch_button_disabled :bool = false

# 属性相关
var life :int = 4
var coin :int = 0
var score :int = 0
var time :int = -1

onready var os_name :String = OS.get_name()
onready var viewport_width :float = get_viewport().size.x

func _ready() ->void:
	match os_name:
		"Windows", "UWP" ,"macOS", "Linux":
			$TouchButton.queue_free()

func _process(_delta) ->void:
	if has_node("TouchButton"):
		$TouchButton.visible = !touch_button_disabled
		$TouchButton.position = Vector2(viewport_width*(touch_button_disabled as int),0)
		$TouchButton/Joystick.disabled = touch_button_disabled
