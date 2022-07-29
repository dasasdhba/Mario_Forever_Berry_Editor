# 绿果特效
extends Timer
onready var parent :Node = get_parent()
onready var player: Node = parent.get_parent()
	
func _physics_process(_delta) ->void:
	if player.state == 4 && !player.on_floor_snap && player.pipe == 0:
		if is_stopped():
			start()
	else:
		stop()

func _on_TimerLui_timeout() ->void:
	if !player.visible:
		return
	var new :Node2D = Lib.fade.instance()
	new.inherit(player)
	new.add_sprite(parent.get_node(parent.current))
	var root: Node = player.get_parent()
	root.add_child(new)
	root.move_child(new,player.get_index())
