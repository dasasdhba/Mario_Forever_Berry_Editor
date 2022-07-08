extends Node2D

export var speed :float = 50 # 速度
export var float_speed :float = 25 # 浮动速度
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1 # 初始方向
export var dir_to_player :bool = true # 初始化时是否朝向马里奥
export var activate :bool = false # 是否激活
export var activate_range :float = 48 # 激活范围
export var auto_destroy :bool = true # 是否自动销毁
export var destroy_range :float = 32 # 自动销毁边界

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,16)

var float_dir :int = 0

onready var view: Node = Berry.get_view(self)
onready var rand :RandomNumberGenerator = Berry.get_rand(self)
onready var gravity_direction :Vector2 = Vector2.DOWN.rotated(rotation)
onready var parent :Node = get_parent()

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass
	
func _physics_process(delta) ->void:
	# 激活
	if !activate:
		activate = view.is_in_view(global_position,activate_range*scale)
		if activate && dir_to_player:
			var p :Node = Berry.get_player_nearest(self)
			if p == null:
				return
			var p_pos :Vector2 = parent.global_transform.xform_inv(p.global_position)
			if position.direction_to(p_pos).dot(gravity_direction.tangent()) > 0:
				direction = 1
			else:
				direction = -1
		return
	
	if $Timer.is_stopped():
		$Timer.start()
		
	# 防止出水
	if $AreaShared/WaterDetect.is_in_water():
		if !$AreaTop/WaterDetect.is_in_water():
			float_dir = 1
		
	position += speed * delta * direction*gravity_direction.tangent()
	position += float_speed * delta * float_dir*gravity_direction
	
	# 出界销毁
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	if auto_destroy:
		if !view.is_in_limit_direction(global_position,destroy_range*scale,direction*gdir.tangent()):
			queue_free()
			
	# 生成器重置
	if is_in_group("cheep_generator"):
		if !view.is_in_view_direction(global_position,destroy_range*scale,direction*gdir.tangent()):
			remove_from_group("cheep_generator")

func _on_Timer_timeout() ->void:
	float_dir = (rand.randi() % 3) - 1
