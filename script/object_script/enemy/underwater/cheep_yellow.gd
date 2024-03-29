extends Node2D

export var speed :float = 50 # 速度
export var follow_range :float = 512 # 跟踪范围
export var shape_name :String = "CollisionShape2D" # 使用的 shape 节点名，用于 AreaShared 初始化

onready var gravity_direction :Vector2 = Vector2.DOWN.rotated(rotation)
onready var scene :Node = Berry.get_scene(self)
	
func _physics_process(delta) ->void:
	# 防止出水
	if $AreaShared/WaterDetect.is_in_water():
		if !$AreaTop/WaterDetect.is_in_water():
			position += speed * delta * gravity_direction
			return
	var p :Node = scene.get_player_nearest(self)
	if p == null:
		return
	var p_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
	if p_pos.x <= position.x - follow_range || p_pos.x >= position.x + follow_range:
		return
	if p_pos.y <= position.y - follow_range || p_pos.y >= position.y + follow_range:
		return
	
	var dir :Vector2 = position.direction_to(p_pos)
	
	position += speed * delta * dir
