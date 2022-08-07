extends Gravity

export var speed :float = 50 # 行走速度
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1 # 初始方向
export var dir_to_player :bool = true # 初始化时是否朝向马里奥
export var jump_height :float = 0 # 跳跃高度
export var activate :bool = false # 是否激活
export var activate_range :float = 48 # 激活范围
export var auto_destroy :bool = true # 是否自动销毁
export var destroy_range :float = 48 # 自动销毁边界
var delta_position :Vector2 = Vector2.ZERO

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,16)

onready var view: Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
	
func _ready() ->void:
	gravity_direction = gravity_direction.rotated(rotation)
	
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
		
	delta_position = -position
	
	# 简单物理运动
	if !is_on_floor():
		gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
	var jump :float = sqrt(2*jump_height*gravity_acceleration)
	if enemy_movement(delta,speed*direction,jump):
		direction *= -1
		
	delta_position += position
	
	# 出界销毁
	if auto_destroy:
		var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
		if !view.is_in_limit_direction(global_position,destroy_range*scale,gdir):
			queue_free()
