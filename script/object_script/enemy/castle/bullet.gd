extends Node2D

export var speed :float = 162.5 # 速度
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1 # 初始方向
export var activate :bool = false # 是否激活
export var activate_range :float = 64 # 激活范围
export var auto_destroy :bool = true # 是否自动销毁
export var destroy_range :float = 512 # 自动销毁边界
var delta_position :Vector2 = Vector2.ZERO

var layer_adjust :bool = false
var layer_timer :float = 0

onready var view: Node = Berry.get_view(self)
	
func _physics_process(delta) ->void:
	# 激活
	if !activate:
		activate = view.is_in_view(global_position,activate_range*scale)
		return
		
	# 调整图层
	if layer_adjust:
		layer_timer += delta
		if layer_timer >= 0.2:
			layer_adjust = false
			layer_timer = 0
			z_index = 0
		
	delta_position = -position
	
	position += direction*speed*delta*Berry.vector2_rotate_degree(rotation_degrees)
		
	delta_position += position
	
	# 出界销毁
	if auto_destroy:
		if !view.is_in_limit(global_position,destroy_range*scale):
			queue_free()
