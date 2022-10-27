# 边界判定不支持旋转
extends Node2D

export var left_border :float = 0
export var right_border :float = 10016
export var launch_interval :float = 3.4 # 两次扔刺猬间隔
export var interval_random :float = 2
export var launch_time: float = 0.2 # 扔刺猬动画等待时间
export var launch_random :float = 0.2
export var reborn_time :float = 5
export var reborn_random :float = 1
export var reborn_trim :int = 16
export var speed_max :float = 450
export var speed_min :float = 200
export var acceleration_max :float = 2500
export var acceleration_min :float = 500
export var turn_max :float = 100
export var turn_min :float = 50
export var ball_gravity :float = 350
export var spiny_res :PackedScene

export var shape_name :String = "CollisionShape2D"

var speed :float = 0
var launch :bool = false

var i_random: float = 0
var l_random :float = 0
var r_random :float = 0
var i_timer :float = 0
var l_timer :float = 0
var r_timer :float = 0

var death :bool = false
var delta_position :Vector2 = Vector2.ZERO

onready var origin_position :Vector2 = position
onready var gravity_direction :Vector2 = Vector2.DOWN.rotated(rotation)
onready var rand :RandomNumberGenerator = Berry.get_rand(self)
onready var view :Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
onready var parent :Node = get_parent()

func _ready() ->void:
	i_random = rand.randf_range(0,interval_random)
	l_random = rand.randf_range(0,launch_random)
	r_random = rand.randf_range(0,reborn_random)

func _physics_process(delta) ->void:
	if !death:
		visible = true
		movement(delta)
	else:
		visible = false
		speed = 0
		launch = false
		i_timer = 0
		l_timer = 0
		$Animation.ani_enabled = false
		$AreaShared/Stomped.collision_name = ""
		if reborn_time <= 0:
			queue_free()
			return
		r_timer += delta
		if r_timer >= reborn_time + r_random:
			r_timer = 0
			r_random = rand.randf_range(0,reborn_random)
			death = false
			$AreaShared/Stomped.collision_name = "enemy_stomp"
			$AreaShared/Attacked.disabled = false
			var dir :int = 1
			var pos :Vector2 = view.get_current_camera().get_camera_screen_center()
			var size :float = view.current_border.size.x
			if global_position.x < pos.x:
				dir = -1
			position = Vector2(pos.x,origin_position.y) + dir*(size/2 + 200)*gravity_direction.tangent() + rand.randi_range(-reborn_trim,reborn_trim)*gravity_direction

func movement(delta :float) ->void:
	delta_position = -position
	
	var p :Node = scene.get_player_nearest(self)
	var activate :bool = p != null && p.global_position.x > left_border && p.global_position.x < right_border
		
	if !activate:
		speed = 0
		var pos :Vector2 = view.get_current_camera().get_camera_screen_center()
		var size :float = view.current_border.size.x
		if global_position.x < pos.x:
			if global_position.x > pos.x - size/2 - 200:
				position.x -= speed_min * delta
		elif global_position.x < pos.x + size/2 + 200:
			position.x += speed_min * delta
	else:
		var player_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
		if position.x > player_pos.x + turn_min && speed > -speed_max:
			speed -= acceleration_min * delta
		if position.x < player_pos.x - turn_min && speed < speed_max:
			speed += acceleration_min * delta
		if position.x < player_pos.x + turn_max && position.x > player_pos.x - turn_max:
			if p.move_direction == 1 && speed < -speed_min:
				speed += acceleration_max * delta
			if p.move_direction == -1 && speed > speed_min:
				speed -= acceleration_max * delta
			
		position += speed * delta*gravity_direction.tangent()
		launch_event(delta)
	
	delta_position += position
	
func launch_event(delta :float) ->void:
	if !launch && $Animation.is_ani_stopped:
		i_timer += delta
		if i_timer >= launch_interval + i_random:
			i_timer = 0
			i_random = rand.randf_range(0,interval_random)
			launch = true
			$Animation.ani_enabled = true
			
	if launch && $Animation.is_ani_stopped:
		l_timer += delta
		if l_timer >= launch_time + l_random:
			l_timer = 0
			l_random = rand.randf_range(0,launch_random)
			launch = false
			$Animation.ani_enabled = false
			$Sound.play()
			var new :Node = spiny_res.instance()
			new.gravity_direction = gravity_direction
			new.gravity = -ball_gravity
			Berry.transform_copy(new,self,$LaunchPos.relative())
			parent.add_child(new)
			
