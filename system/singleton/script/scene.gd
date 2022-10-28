# 单 Room2D 管理，使用 Berry.get_scene() 获取 Scene 单例
# 如果需要多 Room2D，可复制本节点并在不同的 Room2D 使用不同的 Scene 单例管理
# 并且修改 Berry 单例的 multiroom 为 true
extends CanvasLayer

export var save_game_room :PackedScene = null

var current_scene :String = "" # 当前 Scene 的 Path
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
enum TRANS {NONE, FADE, CIRCLE}
var trans_in :int = TRANS.NONE
var trans_out :int = TRANS.NONE
var trans_in_hint :bool = false
var trans_out_hint :bool = false
var timer :float = 0
var in_fade_speed :float = 1
var in_fade_wait_time :float = 0.5
var out_fade_speed :float = 3
var in_circle_speed :float = 250
var in_circle_wait_time :float = 0.5
var out_circle_speed :float = 250

# 转场
var change :bool = false
var room_old :Room2D
var room_parent :Node
var scene_new :PackedScene
var delay :bool = false

# 快捷键
const restart_key :int = KEY_F2
const save_key :int = KEY_F3
var restart_restrict :bool = false
var save_restrict :bool = false

# 初始化
func _ready() ->void:
	current_scene = get_tree().current_scene.filename

# 更改当前 Scene
func change_scene(new_scene :PackedScene, in_trans :int = TRANS.NONE, out_trans :int = TRANS.NONE) ->void:
	change = true
	current_scene = new_scene.resource_path
	room_old = current_room
	room_parent = current_room.get_parent()
	scene_new = new_scene
	trans_in = in_trans
	trans_out = out_trans
	trans_in_ready()
	
# 重新加载当前 Scene
func restart_scene(in_trans :int = TRANS.NONE, out_trans :int = TRANS.NONE) ->void:
	var new_current :PackedScene = load(current_scene)
	change_scene(new_current,in_trans,out_trans)
	
# 完全重启
func restart_all() ->void:
	current_scene = get_tree().current_scene.filename
	get_tree().reload_current_scene()
	
# 清空 scene 数据
func clear_data() ->void:
	death_hint = false
	current_checkpoint = []
	checkpoint_scene = null
	checkpoint_room_name = ""
	checkpoint_position = null
	
# 转场效果
func trans_in_ready() ->void:
	match trans_in:
		TRANS.FADE:
			$Fade.color.a = 0
			$Fade.visible = true
		TRANS.CIRCLE:
			$Circle.radius = $Circle.max_radius
			$Circle.visible = true

func trans_in_process(delta :float) ->void:
	match trans_in:
		TRANS.NONE:
			trans_in_hint = true
		TRANS.FADE:
			$Fade.color.a += in_fade_speed * delta
			if $Fade.color.a >= 1:
				timer += delta
				if timer >= in_fade_wait_time:
					timer = 0
					trans_in_hint = true
		TRANS.CIRCLE:
			$Circle.radius -= in_circle_speed * delta
			if $Circle.radius <= 0:
				timer += delta
				if timer >= in_circle_wait_time:
					timer = 0
					trans_in_hint = true
					
func trans_in_cancel() ->void:
	trans_in_hint = false
	match trans_in:
		TRANS.FADE:
			$Fade.visible = false
		TRANS.CIRCLE:
			$Circle.visible = false
			
func trans_out_ready() ->void:
	match trans_out:
		TRANS.FADE:
			trans_out_hint = true
			$Fade.color.a = 1
			$Fade.visible = true
		TRANS.CIRCLE:
			trans_out_hint = true
			$Circle.radius = 0
			$Circle.visible = true
			
func trans_out_process(delta :float) ->void:
	match trans_out:
		TRANS.FADE:
			$Fade.color.a -= in_fade_speed * delta
			if $Fade.color.a <= 0:
				$Fade.color.a = 0
				$Fade.visible = false
				trans_out_hint = false
		TRANS.CIRCLE:
			$Circle.radius += out_circle_speed * delta
			if $Circle.radius >= $Circle.max_radius:
				$Circle.radius = $Circle.max_radius
				$Circle.visible = false
				trans_out_hint = false
	
func _process(delta) ->void:
	if change && !trans_in_hint:
		trans_in_process(delta)
	if trans_out_hint:
		trans_out_process(delta)
		
func _physics_process(_delta) ->void:
	# 检查 current_player
	var i :int = 0
	while i < current_player.size():
		if !is_instance_valid(current_player[i]):
			current_player.remove(i)
			continue
		i += 1
	
	# 转场
	if change && trans_in_hint:
		if !delay:
			delay = true
			return
		if is_instance_valid(room_old):
			room_old.queue_free()
			current_player.clear()
		else:
			trans_in_cancel()
			room_parent.add_child(scene_new.instance())
			change = false
			delay = false
			trans_out_ready()
			
# 快捷转场
func _unhandled_key_input(event :InputEventKey) ->void:
	if change:
		return
	if event.scancode == restart_key:
		if event.pressed:
			if !restart_restrict:
				restart_restrict = true
				restart_all()
		else:
			restart_restrict = false
	elif event.scancode == save_key:
		if event.pressed:
			if !save_restrict:
				save_restrict = true
				if save_game_room != null:
					change_scene(save_game_room)
		else:
			save_restrict = false

# 获取玩家最大 state
func get_player_state_max() ->int:
	if current_player.empty():
		return 0
	var r :int = -INF as int
	for i in current_player:
		if i.state > r:
			r = i.state
	return r
	
# 获取当前玩家数
func get_player_num() ->int:
	return current_player.size()

# 获取当前处于无敌星状态的玩家数
func get_player_star_num() ->int:
	var r :int = 0
	for i in current_player:
		if i.star:
			r += 1
	return r

# 获取最近的玩家
func get_player_nearest(node :Node) ->Node:
	var dmin :float = INF
	var p :Node = null
	for i in current_player:
		if node.global_position.distance_to(i.global_position) < dmin:
			dmin = node.global_position.distance_to(i.global_position)
			p = i
	return p
