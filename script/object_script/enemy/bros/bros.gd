extends Gravity

export var speed :float = 100
export var walk_time :float = 0.64
export var walk_time_random :float = 1.28
export var stop_time :float = 2
export var stop_speed :int = 1
export var stop_speed_random :int = 5
export var jump_interval :float = 0.2
export var jump_up_height :float = 160
export var jump_down_height :float = 22.5
export var jump_up_probability :float = 0.05
export var jump_down_probability :float = 0.05
export var launch_interval :float = 0.06
export var launch_probability :float = 1/11.0
export var launch_time :float = 0.6
export var activate :bool = false # 是否激活
export var activate_range :float = 32 # 激活范围
export var auto_destroy :bool = true # 是否自动销毁
export var destroy_range :float = 32 # 自动销毁边界
export var launch_res :PackedScene
var delta_position :Vector2 = Vector2.ZERO

var move_speed :float = 0

var move_state :int = 0
var w_random :float = 0
var s_random :float = 0
var w_timer :float = 0
var s_timer :float = 0
var jump_state :int = 0
var j_timer :float = 0
var launch :bool = false
var l_timer :float = 0

export var brush_border :Rect2 = Rect2(-16,-24,32,48)
export var brush_offset :Vector2 = Vector2(16,25)

onready var view :Node = Berry.get_view(self)
onready var rand :RandomNumberGenerator = Berry.get_rand(self)
onready var parent :Node = get_parent()

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass
	
func _ready() ->void:
	gravity_direction = gravity_direction.rotated(rotation)
	
func _physics_process(delta) ->void:
	# 激活
	if !activate:
		activate = view.is_in_view(global_position,activate_range*scale)
		return
		
	delta_position = -position
	
	movement(delta)
	jump_event(delta)
	launch_event(delta)
	
	# 简单物理运动
	if !is_on_floor():
		gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
	enemy_movement(delta,move_speed)
		
	delta_position += position
	
	# 出界销毁
	if auto_destroy:
		var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
		if !view.is_in_limit_direction(global_position,destroy_range*scale,gdir):
			queue_free()
			
func movement(delta :float) ->void:
	if move_state == 0:
		move_state = 1
		w_random = rand.randf_range(0,walk_time_random)
		s_random = rand.randi_range(0,stop_speed_random)
		s_timer = 0
		w_timer = -(walk_time - walk_time_random)
	if w_timer == 0:
		if move_state == 3:
			move_state = 0
		if s_timer >= stop_time:
			s_timer = 0
			if move_state == 1:
				w_timer = (walk_time - walk_time_random)*2
			elif move_state == 2:
				w_timer = -(walk_time - walk_time_random)
			move_state += 1
		
	if w_timer < -delta:
		w_timer += delta
		move_speed = -speed
	elif w_timer > delta:
		w_timer -= delta
		move_speed = speed
	else:
		move_speed = 0
		w_timer = 0
		s_timer += (stop_speed + s_random) * delta
	
func jump_event(delta :float) ->void:
	if jump_state == -1 && is_on_floor():
		jump_state = 0
		
	if jump_state == 0:
		j_timer += delta
		if j_timer >= jump_interval:
			j_timer = 0
			var dir :int = -1
			for i in $AreaShared.get_overlapping_areas():
				if i.has_method("_bros_jump"):
					dir = i._bros_jump()
			if dir == 0:
				var j_random :float = rand.randf()
				if j_random < jump_up_probability:
					gravity = -sqrt(2*gravity_acceleration*jump_up_height)
					jump_state = 1
			elif dir == 1:
				var j_random :float = rand.randf()
				if j_random < jump_down_probability:
					gravity = -sqrt(2*gravity_acceleration*jump_down_height)
					jump_state = 2
				elif (1-j_random) < jump_up_probability:
					gravity = -sqrt(2*gravity_acceleration*jump_up_height)
					jump_state = 1
	
	if jump_state == 1:
		if gravity < 0:
			$CollisionShape2D.disabled = true
		else:
			$CollisionShape2D.disabled = false
			if move_and_collide(Vector2.DOWN,true,true,true):
				$CollisionShape2D.disabled = true
			else:
				jump_state = -1
				
	if jump_state == 2 && gravity > 0:
		$CollisionShape2D.disabled = false
		if move_and_collide(Vector2.DOWN,true,true,true):
			jump_state = 3
		$CollisionShape2D.disabled = true
	
	if jump_state == 3:
		$CollisionShape2D.disabled = false
		if move_and_collide(Vector2.DOWN,true,true,true):
			$CollisionShape2D.disabled = true
		else:
			jump_state = -1
	
func launch_event(delta :float) ->void:
	if !launch:
		if view.is_in_view(global_position,activate_range*scale):
			l_timer += delta
		if l_timer >= launch_interval:
			l_timer = 0
			var l_random :float = rand.randf()
			if l_random < launch_probability:
				launch = true
				$AnimatedSprite.animation = "launch"
	else:
		l_timer += delta
		if l_timer >= launch_time:
			l_timer = 0
			launch = false
			$AnimatedSprite.animation = "default"
			$Launch.play()
			var new :Node = launch_res.instance()
			Berry.transform_copy(new,self,$LaunchPos.relative($AnimatedSprite.flip_h))
			new.gravity_direction = gravity_direction
			if $AnimatedSprite.flip_h:
				new.direction = -1
			parent.add_child(new)
