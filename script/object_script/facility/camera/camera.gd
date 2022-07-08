# Camera 事件，不受坐标系影响
extends Camera2D

enum MODE {SAVE_GAME_ROOM, FOLLOW, FORCE}
export(MODE) var mode :int = MODE.FOLLOW # 0 选关画面，1 跟随，2 强制滚屏
export var force_angle :float = 0 # 强制滚屏方向角
export var force_speed :float = 50 # 强制滚屏速度
export var shake_amplitude :int = 12

var shake_time :float = 0 # 晃屏时间
var smooth_limit :bool = false # 用于恢复正常滚屏

onready var view: Node = Berry.get_view(self)
onready var rand: RandomNumberGenerator = Berry.get_rand(self)

# 设置坐标为当前滚屏中心
func force_center() ->void:
	global_position = get_camera_screen_center()
	
func get_position_center(pos :Vector2) ->Vector2:
	var border :Rect2 = view.current_limit
	var size :Vector2 = get_viewport_rect().size
	var x :float = clamp(pos.x,border.position.x+size.x/2,border.end.x-size.x/2)
	var y :float = clamp(pos.y,border.position.y+size.y/2,border.end.y-size.y/2)
	return Vector2(x,y)

func _ready():
	if !view.camera.has(self):
		view.camera.append(self)

func _physics_process(delta):
	if !current:
		return
	
	camera_event(delta)
	
	# 更新滚屏边界
	view.view_update(get_viewport())
	
	# 取消平滑滚屏
	if smooth_limit:
		if mode != MODE.FOLLOW || get_camera_screen_center().distance_to(get_position_center(global_position)) < smoothing_speed*smoothing_speed * delta:
			smooth_limit = false
			smoothing_enabled = false
	
	# 晃屏
	if mode != MODE.FOLLOW:
		shake_time = 0
	if shake_time > 0:
		global_position = get_position_center(global_position) + Vector2(rand.randi_range(-shake_amplitude,shake_amplitude),rand.randi_range(-shake_amplitude,shake_amplitude))
		shake_time -= delta
		if shake_time <= 0:
			shake_time = 0
			
func camera_event(delta) ->void:
	# 更新玩家出界判定
	var player :Array = []
	for i in Player.player:
		if !Player.get_children().has(i) && i.get_viewport() == get_viewport():
			i.view_limit = (mode == 1 || mode == 2)
			player.append(i)
	
	# 滚屏
	match mode:
		MODE.SAVE_GAME_ROOM:
			# 选关画面滚屏，以一号玩家为准
			smoothing_enabled = false
			if !player.empty():
				var pos :Vector2 = player.front().global_position
				var size :Vector2 = get_viewport_rect().size
				global_position.x = size.x/2 + floor(pos.x/size.x)*size.x
				global_position.y = size.y/2 + floor(pos.y/size.y)*size.y
		MODE.FOLLOW:
			# 跟随滚屏
			if !player.empty():
				var pos :Vector2 = Vector2.ZERO
				for i in Player.player:
					pos += i.global_position
				pos /= player.size()
				global_position = pos
		MODE.FORCE:
			# 强制滚屏
			smoothing_enabled = false
			global_position += force_speed*Berry.vector2_rotate_degree(force_angle) * delta
	
	player.clear()
