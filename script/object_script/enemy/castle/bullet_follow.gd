extends Node2D

export var speed_init :float = 162.5 # 初速度
export var speed_max :float = 200 # 最大速度
export var acceleration :float = 312.5
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1 # 初始方向
export var activate :bool = false # 是否激活
export var activate_range :float = 64 # 激活范围
export var auto_destroy :bool = true # 是否自动销毁
export var destroy_range :float = 512 # 自动销毁边界
var delta_position :Vector2 = Vector2.ZERO

var speed :float = 0
var layer_adjust :bool = false
var layer_timer :float = 0

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,16)

onready var view: Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
onready var parent :Node = get_parent()
	
func _ready() ->void:
	speed = speed_init
	
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
	
	# 跟踪
	var p: Node = scene.get_player_nearest(self)
	var dir :int = direction
	if p != null:
		var p_pos :Vector2 = parent.global_transform.xform_inv(p.global_position)
		if position.direction_to(p_pos).dot((Vector2.DOWN.rotated(rotation)).tangent()) > 0:
			dir = 1
		else:
			dir = -1
			
	if direction == dir:
		if speed < speed_max:
			speed += acceleration * delta
		else:
			speed = speed_max
	else:
		if speed > 0:
			speed -= acceleration * delta
		else:
			speed = 0
			direction *= -1
	
	position += direction*speed*delta*Berry.vector2_rotate_degree(rotation_degrees)
		
	delta_position += position
	
	# 出界销毁
	if auto_destroy:
		if !view.is_in_limit(global_position,destroy_range*scale):
			queue_free()
