extends KinematicBody2D

export var speed :float = 50 # 速度
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1 # 初始方向
export var dir_to_player :bool = true # 初始化时是否朝向马里奥
export var activate :bool = true # 是否激活
export var activate_range :float = 48 # 激活范围
export var auto_destroy :bool = true # 是否自动销毁
export var destroy_range :float = 32 # 自动销毁边界

onready var view: Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
onready var gravity_direction = Vector2.DOWN.rotated(rotation)
	
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
	
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	var velocity :Vector2 = speed * delta * direction*gdir.tangent()
	if move_and_collide(velocity):
		direction *= -1
	
	# 出界销毁
	if auto_destroy:
		if !view.is_in_limit_direction(global_position,destroy_range*scale,gdir*gravity_direction.tangent()):
			queue_free()
