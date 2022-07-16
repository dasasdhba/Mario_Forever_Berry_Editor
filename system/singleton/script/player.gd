# 玩家管理
extends Node

var player :Array = []

func _ready() ->void:
	for i in get_children():
		player.append(i)
		freeze(i)

# 获取玩家最大 state
func get_player_state_max() ->int:
	if player.empty():
		return 0
	var r :int = -INF as int
	for i in player:
		if i.state > r:
			r = i.state
	return r
	
# 获取当前玩家数
func get_player_num() ->int:
	var r :int = player.size() - get_children().size()
	for i in player:
		if i.disable_deferred:
			r -= 1
	return max(0,r) as int

# 获取当前处于无敌星状态的玩家数
func get_player_star_num() ->int:
	var r :int = 0
	for i in player:
		if i.star:
			r += 1
	return r
	
# 恢复玩家
func recover(pstr :String, new_parent :Node) ->Node:
	var p :Node = get_node(pstr)
	remove_child(p)
	p.animated_node.visible = true
	p.set_process(true)
	p.set_physics_process(true)
	p.set_process_input(true)
	p.get_node("AreaShared").get_node("WaterSignal").reset = true
	p.collision_update()
	new_parent.add_child(p)
	return p
	
# 禁用玩家
func disable(p :Node) ->void:
	if !player.has(p) || get_children().has(p):
		return
	# 清理 Scene 的 current_player 数组
	var scene :Node = Berry.get_scene(p)
	for i in scene.current_player.size():
		if p == scene.current_player[i]:
			scene.current_player.remove(i)
			break
	p.get_parent().call_deferred("remove_child",p)
	p.disable_deferred = true
	freeze(p)
	
# 将玩家冻结在初始状态
func freeze(i :Node) ->void:
	i.gravity = 0
	i.move = 0
	i.pipe = 0
	i.pipe_length = 0
	i.hurt = false
	i.star = false
	i.atk_count = 0
	i.clear = false
	i.crouch = false
	i.crouch_push = false
	i.water = false
	i.jump_restrict = false
	i.on_floor_snap = false
	i.on_tank = 0
	i.control_up = 0
	i.control_down = 0
	i.control_left = 0
	i.control_right = 0
	i.control_jump = 0
	i.control_fire = 0
	i.move_delay = 0
	i.left_latest = 0
	i.right_latest = 0
	i.left_key = false
	i.right_key = false
	i.down_key = false
	i.up_key = false
	i.jump_key_time = 0
	i.death_once = false
	i.animated_node.visible = false
	i.animated_node.flip_h = false
	i.animated_node.flip_v = false
	i.animated_node.swim_finish = false
	i.animated_node.current = "Small"
	i.animated_node.animation = "idle"
	i.set_process(false)
	i.set_physics_process(false)
	i.set_process_input(false)
	i.get_node("Audio").audio_stop()
	i.get_node("Timer").timer_stop()
	i.get_node("AreaShared").clear()
	i.get_node("AreaShared").get_node("WaterSignal").disable()
	i.get_node("CollisionShapeSmall").set_deferred("disabled", true)
	i.get_node("CollisionShapeBig").set_deferred("disabled", true)
	i.get_node("CollisionShapeGrace").set_deferred("disabled", true)
	i.get_node("StarParticles").emitting = false

func _physics_process(_delta):
	for i in player:
		if i.disable_deferred:
			var parent :Node = i.get_parent()
			if parent != self:
				if parent == null:
					call_deferred("add_child",i)
			else:
				i.disable_deferred = false
