# 单 Room2D 管理，使用 Berry.get_scene() 获取 Scene 单例
# 在转场之前，请确保 player 已经被 Player.disable()，否则 player 也会被 queue_free()
# 如果不需要多 Room2D，可以在 _process() 中添加自动 disable player 相关的代码
# 如果需要多 Room2D，可复制本节点并在不同的 Room2D 使用不同的 Scene 单例管理
# 并且修改 Berry 单例的 multiroom 为 true
extends Node

var current_scene :PackedScene = null # 当前 Scene 的 Packed 备份
var current_room :Room2D = null # 当前 Room2D 节点
var current_player :Array = [] # 当前 Room2D 的玩家

# Checkpoint
var current_checkpoint :Array = [] # 当前已激活的 CP 的 name
var checkpoint_scene :PackedScene = null # Checkpoint 所在 Scene
var checkpoint_room_name :String = ""
var checkpoint_position = null

# 是否死亡过
var death_hint :bool = false

# 转场方式
var trans_in :int = 0
var trans_out :int = 0

# 转场
var change :bool = false
var room_old :Room2D
var room_parent :Node
var scene_new :PackedScene
	
# 更改当前 Scene
func change_scene(new_scene :PackedScene) ->void:
	change = true
	room_old = current_room
	room_parent = current_room.get_parent()
	scene_new = new_scene
	
# 重新加载当前 Scene
func restart_scene() ->void:
	change_scene(current_scene)
	
func _process(_delta):
	if change:
		if is_instance_valid(room_old):
			room_old.queue_free()
			current_player.clear()
		else:
			room_parent.add_child(scene_new.instance())
			change = false
