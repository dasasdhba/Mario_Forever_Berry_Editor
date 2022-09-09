extends Gravity

export var speed :float = 150 # 行走速度
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1 # 初始方向
export var dir_to_player :bool = true # 初始化时是否朝向马里奥
export var jump_height :float = 90 # 跳跃高度
export var jump_height_random :float = 110 # 跳跃高度随机部分
export var jump_interval :float = 5
export var jump_interval_random :float = 1
export var stop_interval :float = 1
export var stop_interval_random :float = 1
export var stop_time :float = 0.3
export var stop_time_random :float = 0.6
export var stop_probability :float = 0.3
export var activate :bool = false # 是否激活
export var activate_range :float = 96 # 激活范围
var delta_position :Vector2 = Vector2.ZERO
var player_position = null

var look_player :bool = true
var anim_control :bool = true
var walk :bool = true
var stop :bool = false
var stop_timer :float = 0
var stop_i_random :float = 0
var stop_t_random :float = 0
var jump :bool = true
var jump_timer :float = 0
var jump_i_random :float = 0

export var brush_border :Rect2 = Rect2(-32,-36,64,72)
export var brush_offset :Vector2 = Vector2(32,44)

onready var view: Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
onready var rand :RandomNumberGenerator = Berry.get_rand(self)
	
func _ready() ->void:
	gravity_direction = gravity_direction.rotated(rotation)
	stop_i_random = rand.randf_range(0,stop_interval_random)
	stop_t_random = rand.randf_range(0,stop_time_random)
	jump_i_random = rand.randf_range(0,jump_interval_random)
	
func _physics_process(delta) ->void:
	# 激活
	if !activate:
		activate = view.is_in_view(global_position,activate_range*scale)
		if activate && dir_to_player:
			var p :Node = scene.get_player_nearest(self)
			if p == null:
				return
			var p_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
			if position.direction_to(p_pos).dot(gravity_direction.tangent()) > 0:
				direction = 1
			else:
				direction = -1
		return
		
	var p :Node = scene.get_player_nearest(self)
	if p != null:
		player_position = Berry.get_xform_position(self,p.global_position)
		# 朝向玩家
		if look_player:
			$AnimatedSprite.flip_h = position.direction_to(player_position).dot(gravity_direction.tangent()) <= 0
	else:
		player_position = null
	
	# 运动
	delta_position = -position
	bowser_movement(delta)
	delta_position += position
	
	# 动画
	if anim_control:
		if is_on_floor():
			$AnimatedSprite.animation = "walk"
		else:
			$AnimatedSprite.animation = "jump"
	
func bowser_movement(delta) ->void:
	var walk_speed :float = 0
	var jump_speed :float = 0
	
	# 移动与急停
	if walk:
		if !stop:
			walk_speed = speed
			if stop_interval >= 0:
				stop_timer += delta
				if stop_timer >= stop_interval + stop_i_random:
					stop_i_random = rand.randf_range(0,stop_interval_random)
					stop_timer = 0
					var s_random :float = rand.randf()
					if s_random < stop_probability:
						stop = true
		else:
			stop_timer += delta
			if stop_timer >= stop_time + stop_t_random:
				stop_t_random = rand.randf_range(0,stop_time_random)
				stop_timer = 0
				stop = false
				
	# 跳跃
	if jump && is_on_floor() && jump_interval >= 0:
		jump_timer += delta
		if jump_timer >= jump_interval + jump_i_random:
			jump_i_random = rand.randf_range(0,jump_interval_random)
			jump_timer = 0
			var height :float = jump_height + rand.randf_range(0,jump_height_random)
			jump_speed = sqrt(2*height*gravity_acceleration)
	
	if !is_on_floor():
		gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
	if enemy_movement(delta,walk_speed*direction,jump_speed):
		direction *= -1
