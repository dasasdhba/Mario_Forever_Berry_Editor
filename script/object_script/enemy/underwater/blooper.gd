# 不支持旋转
extends Node2D

export var speed :float = 100
export var dive_speed :float = 100
export var dive_stop_range :float = 0
export var dive_time :float = 0.2
export var float_speed_init :float = 225
export var float_acceleration :float = 250
export var top_border :float = 0
export var follow_range :float = 256
export var activate :bool = false
export var activate_range :float = 64

var timer :float = 0
var float_speed :float = 0
var follow :bool = false
var dive :bool = false
var delta_position :Vector2

onready var view :Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
onready var gravity_direction :Vector2 = Vector2.DOWN.rotated(rotation)

func _physics_process(delta):
	# 激活
	if !activate:
		activate = view.is_in_view(global_position,activate_range*scale)
		return
		
	if !view.is_in_view(global_position,follow_range*scale):
		return
	
	var p :Node = scene.get_player_nearest(self)
	if p == null:
		return
	var p_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
	
	delta_position = -position
	
	if !follow:
		position += dive_speed * delta*gravity_direction
		timer += delta
		if timer >= dive_time:
			dive = true
			timer = dive_time
			if position.y >= p_pos.y - dive_stop_range || position.y >= view.current_border.end.y + activate_range:
				float_speed = -float_speed_init
				follow = true
				dive = false
				timer = 0
	else:
		position += float_speed * delta*gravity_direction
		float_speed += float_acceleration * delta
		var dir :int = 1
		if position.x > p_pos.x:
			dir = -1
		position += speed*dir * delta*gravity_direction.tangent()
		if float_speed >= 0:
			float_speed = 0
			follow = false
	
	if global_position.y < top_border:
		global_position.y = top_border
	
	delta_position += position
	
	# 动画与碰撞遮罩
	$AnimatedSprite.frame = dive as int
	$AreaShared/CollisionShapeBig.disabled = dive
	$AreaShared/CollisionShapeSmall.disabled = !dive
	var new_collision :CollisionShape2D
	if dive:
		new_collision = $AreaShared/CollisionShapeSmall
	else:
		new_collision = $AreaShared/CollisionShapeBig
	$AreaShared/Stomped/RectBox2D.load_collision_shape(new_collision)
