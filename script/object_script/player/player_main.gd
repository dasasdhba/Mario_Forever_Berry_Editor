extends Gravity

# 图层
const z_index_normal :int = 10
const z_index_pipe :int = -51

# 属性
export var character :PackedScene
export var death: Texture
export var fireball: PackedScene
export var beet: PackedScene
export var state :int = 0 # 玩家状态，0小个子，1大个子，2花身，3甜菜，4绿果
var pipe :int = 0 # 进水管状态
var pipe_length :float = 0 # 进水管动画长度
const pipe_speed :float = 50.0 # 进水管动画速度
const pipe_horizontal :int = 32 # 左右进水管长度
const pipe_vertical :int = 64 # 上下进水管长度
var clear :bool = false # 是否通关
var clear_direction :int = 1 # 通关行走方向
const clear_speed :float = 92.875 # 通关行走速度
var crouch :bool = false # 是否蹲下
var water: bool = false # 是否在水中
var hurt: bool = false # 是否受伤
var hurt_flash :float = 0 # 受伤闪烁
const hurt_flash_speed :float = 20*PI # 受伤闪烁角速度
var star: bool = false # 是否无敌星
var star_flash :float = 0 # 无敌星闪烁
const star_flash_speed :float = 10*PI # 无敌星闪烁角速度
var on_tank :bool = false # 用于坦克滚屏判定
var death_once :bool = false # 防止反复触发死亡
var disable_deferred :bool = false # 用于统计玩家数量
var animated_node :Node2D # 动画
var delta_position :Vector2 = Vector2.ZERO # 位置差

# 移动
var move :float = 0 # 行走速度
export var move_direction :int = 1 # -1左，1右（相对重力方向向下）
export var move_grace :float = 14 # 土狼范围
export var move_max :float = 210 # 行走最大速度
export var move_max_run :float = 155 # 奔跑附加最大速度
export var move_initial :float = 45 # 初速度
export var move_acceleration :float = 310 # 行走加速度
export var move_deceleration :float = 310 # 行走减速度
export var turn_deceleration :float = 1225 # 转向减速度
export var crouch_deceleration :float = 625 # 滑蹲减速度
export var slope_max_angle :float = 55 # 允许行走的最大坡角

# 跳跃
export var jump :float = 650 # 跳跃初速度
export var swim :float = 150 # 游泳初速度
export var jump_out_water :float = 450 # 跳出水面速度
export var jump_add_idle :float = 1000 # 静止跳跃加成
export var jump_add_move :float = 1250 # 运动跳跃加成
export var jump_add_lui :float = 1500 # 绿果跳跃加成
var jump_restrict :bool = false # 限制连跳
var on_floor_snap :bool = false # 是否在地面上(动画)
const snap_value :int = 6 # 越大越容易站在斜坡上，但判定越不精确

# 踩敌人速度
export var stomp_bounce: float = 450
export var stomp_jump :float = 650
var atk_count :int = 0 # 无敌星计数

var crouch_push :bool = false # 滑蹲防卡墙
const crouch_push_speed :int = 100 # 滑蹲卡墙速度

export var fall_disabled = false # 是否禁止摔死
export var swim_disabled :bool = false # 是否禁止游泳
var view_limit :bool = true # 是否禁止出界

# 按键设置
var control_recover :bool = false # 用于延迟一帧恢复控制
export var control :bool = true # 是否允许控制
export var key_up :String = "ui_up"
export var key_down :String = "ui_down"
export var key_left :String = "ui_left"
export var key_right :String = "ui_right"
export var key_jump :String = "ui_jump"
export var key_fire :String = "ui_fire"

# 控制，0未按，1按住，2按住瞬间
var control_up :int = 0
var control_down :int = 0
var control_left :int = 0
var control_right :int = 0
var control_jump :int = 0
var control_fire :int = 0

# 相对重力方向按键检测
var move_delay :int = 0
var left_latest :int = 0
var right_latest :int = 0
var left_key :bool = false
var right_key :bool = false
var up_key: bool = false
var down_key :bool = false

# 按跳时间，用于踩弹簧
var jump_key_time :float = 0

onready var view: Node = Berry.get_view(self)

func _ready() ->void:
	# 初始化动画
	if !get_children().has(animated_node):
		animated_node = character.instance()
		add_child(animated_node)
		move_child($StarParticles,get_child_count())
	
	# 碰撞遮罩
	collision_update()

func _physics_process(delta) ->void:
	delta_position = -position
	# 控制
	get_control(delta)

	if pipe == 0:
		# 运动
		player_movement(delta)
		# 动画
		player_animation(delta)
		# 攻击
		player_attack()
	else:
		# 水管
		player_pipe_animation(delta)
	delta_position += position

# 获取控制
func get_control(delta) ->void:
	# 按键检测
	if control:
		control_up = (Input.is_action_pressed(key_up) as int) + (Input.is_action_just_pressed(key_up) as int)
		control_down = (Input.is_action_pressed(key_down) as int) + (Input.is_action_just_pressed(key_down) as int)
		control_left = (Input.is_action_pressed(key_left) as int) + (Input.is_action_just_pressed(key_left) as int)
		control_right = (Input.is_action_pressed(key_right) as int) + (Input.is_action_just_pressed(key_right) as int)
		control_jump = (Input.is_action_pressed(key_jump) as int) + (Input.is_action_just_pressed(key_jump) as int)
		control_fire = (Input.is_action_pressed(key_fire) as int) + (Input.is_action_just_pressed(key_fire) as int)
	else:
		control_up = 0
		control_down = 0
		control_left = 0
		control_right = 0
		control_jump = 0
		control_fire = 0
		move_delay = 0
		left_latest = 0
		right_latest = 0
		left_key = false
		right_key = false
		down_key = false
		up_key = false
		if control_recover:
			control = true
			control_recover = false
		return

	var gravity_angle :float = rad2deg(gravity_direction.angle())
	# 获取上下按键
	var c1 :bool = gravity_angle >= 45 && gravity_angle <= 135 && control_down > 0
	var c2 :bool = gravity_angle >= -45 && gravity_angle <= 45 && control_right > 0
	var c3 :bool = gravity_angle <= -45 && gravity_angle >= -135 && control_up > 0
	var c4 :bool = (gravity_angle <= -135 || gravity_angle >= 135) && control_left > 0
	down_key = c1 || c2 || c3 || c4
	
	c1 = gravity_angle >= 45 && gravity_angle <= 135 && control_up > 0
	c2 = gravity_angle >= -45 && gravity_angle <= 45 && control_left > 0
	c3 = gravity_angle <= -45 && gravity_angle >= -135 && control_down > 0
	c4 = (gravity_angle <= -135 || gravity_angle >= 135) && control_right > 0
	up_key = c1 || c2 || c3 || c4
		
	# 获取左右按键
	if move_delay > 0:
		if min(1,control_up) + min(1,control_down) + min(1,control_left) + min(1,control_right) == 1:
			move_delay = 1
	
		c1 = left_latest == 1 && (control_left == 0 || control_right > 0)
		c2 = left_latest == 2 && (control_right == 0 || control_left > 0)
		c3 = left_latest == 3 && (control_up == 0 || control_down > 0)
		c4 = left_latest == 4 && (control_down == 0 || control_up > 0)
		if c1 || c2 || c3 || c4:
			left_latest = 0
			left_key = false
			move_delay = 0
			
		c1 = right_latest == 1 && (control_left == 0 || control_right > 0)
		c2 = right_latest == 2 && (control_right == 0 || control_left > 0)
		c3 = right_latest == 3 && (control_up == 0 || control_down > 0)
		c4 = right_latest == 4 && (control_down == 0 || control_up > 0)
		if c1 || c2 || c3 || c4:
			right_latest = 0
			right_key = false
			move_delay = 0
			
	if move_delay == 0:
		if control_right != control_left || control_up != control_down:
			left_key = false
			right_key = false
			left_latest = 0
			right_latest = 0
			
			if gravity_angle >= 45 && gravity_angle <= 135:
				if control_left > 0:
					left_key = true
					left_latest = 1
					move_delay = 1
				if control_right > 0:
					right_key = true
					right_latest = 2
					move_delay = 1				
			elif gravity_angle <= -45 && gravity_angle >= -135:
				if control_right > 0:
					left_key = true
					left_latest = 2
					move_delay = 1
				if control_left > 0:
					right_key = true
					right_latest = 1
					move_delay = 1				
			elif gravity_angle >= 135 || gravity_angle <= -135:
				if control_up > 0:
					left_key = true
					left_latest = 3
					move_delay = 1
				if control_down > 0:
					right_key = true
					right_latest = 4
					move_delay = 1
			else:
				if control_down > 0:
					left_key = true
					left_latest = 4
					move_delay = 1
				if control_up > 0:
					right_key = true
					right_latest = 3
					move_delay = 1
				
	if move_delay == 1:
		if left_key:
			if left_latest <= 2:
				if gravity_angle >= -45 && gravity_angle <= 45 && control_up > 0 && control_down == 0:
					left_latest = 0
					right_latest = 3
					left_key = false
					right_key = true
					move_delay = 2
				if (gravity_angle >= 135 || gravity_angle <= -135) && control_down > 0 && control_up == 0:
					left_latest = 0
					right_latest = 4
					left_key = false
					right_key = true
					move_delay = 2
			else:
				if gravity_angle <= -45 && gravity_angle >= -135 && control_left > 0 && control_right == 0:
					left_latest = 0
					right_latest = 1
					left_key = false
					right_key = true
					move_delay = 2
				if gravity_angle >= 45 && gravity_angle <= 135 && control_right > 0 && control_left == 0:
					left_latest = 0
					right_latest = 2
					left_key = false
					right_key = true
					move_delay = 2
		if right_key:
			if right_latest <= 2:
				if (gravity_angle >= 135 || gravity_angle <= -135) && control_up > 0 && control_down == 0:
					left_latest = 3
					right_latest = 0
					left_key = true
					right_key = false
					move_delay = 2
				if gravity_angle >= -45 && gravity_angle <= 45 && control_down > 0 && control_up == 0:
					left_latest = 4
					right_latest = 0
					left_key = true
					right_key = false
					move_delay = 2
			else:
				if gravity_angle >= 45 && gravity_angle <= 135 && control_left > 0 && control_right == 0:
					left_latest = 1
					right_latest = 0
					left_key = true
					right_key = false
					move_delay = 2
				if gravity_angle <= -45 && gravity_angle >= -135 && control_right > 0 && control_left == 0:
					left_latest = 2
					right_latest = 0
					left_key = true
					right_key = false
					move_delay = 2
	
	# 跳键时间
	if control_jump == 0 || is_on_floor():
		jump_key_time = 0
	else:
		jump_key_time += delta
	

# 玩家运动
func player_movement(delta) ->void:
	# 水
	water = $AreaShared/WaterDetect.is_in_water()
	$BubbleLauncher.activate = water
	if water:
		$BubbleLauncher.offset = position + $Point/Bubble.relative()
		$BubbleLauncher.angle = -gravity_direction.angle()
	
	# 重力
	if !is_on_floor():
		gravity_process(delta,water)
		if gravity < 0 && !water && control_jump > 0:
			if state == 4:
				gravity -= jump_add_lui * delta
			elif move < 25:
				gravity -= jump_add_idle * delta
			else:
				gravity -= jump_add_move * delta
	if on_floor_snap:
		if control_jump > 0 && !water && !jump_restrict && !crouch:
			gravity = -jump
			jump_restrict = true
			$Audio/Jump.play()
	if water && !swim_disabled && control_jump > 0 && !jump_restrict && !crouch:
			if $AreaTop/WaterDetect.is_in_water():
				gravity = -swim
			else:
				gravity = -jump_out_water
			$Audio/Swim.play()
			jump_restrict = true
			
	if control_jump == 0:
		jump_restrict = false
		
	# 移动
	var dir :int = (right_key as int) - (left_key as int)
	if !crouch && !crouch_push:
		if dir == 0:
			move -= move_deceleration * delta
		elif dir == move_direction:
			if move <= 0:
				move = move_initial
			elif move < move_max + min(1,control_fire)*((!water) as int)*move_max_run:
				move += move_acceleration * delta
		else:
			move -= turn_deceleration * delta
			if move <= 0:
				move *= -1
				move_direction *= -1
	else:
		if dir == move_direction:
			move -= move_deceleration * delta
		else:
			move -= crouch_deceleration * delta
			
	if move < 0:
		move = 0
		
	# 通关
	if clear:
		move = clear_speed
		move_direction = clear_direction
		
	# 下蹲
	if down_key && state > 0 && !crouch && on_floor_snap:
		crouch = true
	if crouch && (!down_key || state == 0 || !on_floor_snap):
		crouch = false
	
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	# 判定大小与防卡墙
	var crouch_fix :bool = !$CollisionShapeSmall.disabled
	collision_update()
	if crouch_fix && $CollisionShapeSmall.disabled:
		if is_on_floor():
			crouch_push = true
		else:
			player_solid_push(gravity_direction)
	
	if crouch_push:
		if move_and_collide(-gdir,true,true,true):
			position -= crouch_push_speed*gravity_direction.rotated(0-move_direction*PI/2) * delta
			move = 0
			return
		else:
			crouch_push = false
	
	# 土狼范围
	var grace :float = 0
	if is_on_floor():
		grace = move_grace*min(1,move/(move_max*0.75))
	$CollisionShapeGrace.position.x = -grace*move_direction
	var collide_dir :Vector2 = gdir + 2*move_direction*gdir.tangent()
	while grace > 0 && move_and_collide(-collide_dir,true,true,true):
		grace -= 1
		if grace < 0:
			grace = 0
		$CollisionShapeGrace.position.x = -grace*move_direction
	
	# 着地动画判定
	var velocity :Vector2 = gravity*gdir + move*move_direction*gdir.tangent()
	var temp: Vector2 = position
	$CollisionShapeGrace.disabled = true
	on_floor_snap = false
	for i in snap_value+1:
		position = temp + i*gravity_direction
		move_and_slide_with_snap(velocity,gdir,-gdir,true,4,deg2rad(slope_max_angle))
		if is_on_floor():
			on_floor_snap = true
			break
	position = temp
	$CollisionShapeGrace.disabled = false
	
	# 应用物理
	velocity = move_and_slide_with_snap(velocity,gdir,-gdir,true,4,deg2rad(slope_max_angle))
	if is_on_ceiling():
		player_solid_push(gravity_direction,push_value)
		if gravity < 0:
			gravity = 0
			$HitBlock.hit_block(false,state == 0,true)
	elif is_on_floor():
		gravity = velocity.dot(gdir)
	if (is_on_floor() && is_on_ceiling()) || (is_on_wall() && !is_on_floor()):
		move = 0
	else:
		var move_new :float = velocity.dot(move_direction*gdir.tangent())
		if move_new >= 0 && move_new < move:
			move = move_new
	
	# 隐藏砖
	if gravity < 0:
		if $HitBlock.hit_block_hidden(-gravity_direction,8,false,state == 0,true):
			gravity = 0
	
	# 刷新 is_on_floor()
	temp = position
	move_and_slide_with_snap(gravity_acceleration*gdir * delta,gdir,-gdir,true,4,deg2rad(slope_max_angle))
	position = temp
	
	if !clear && !pipe:
		# 摔死
		if !fall_disabled:
			if !view.is_in_view_direction(global_position,48*scale,gdir):
				player_death()
	
		# 滚屏边界限制
		if view_limit:
			while !view.is_in_view_direction(global_position+$Point/ViewBorder.relative(),Vector2.ZERO,gdir.tangent()):
				position -= gravity_direction.tangent()
				move = 0
			while !view.is_in_view_direction(global_position+$Point/ViewBorder.relative(true),Vector2.ZERO,-gdir.tangent()):
				position += gravity_direction.tangent()
				move = 0
				
		# 挤死判定
		var crush :KinematicCollision2D = $Crush.move_and_collide(Vector2.ZERO,true,true,true)
		if crush:
			for i in crush.collider.get_shape_owners():
				if !crush.collider.shape_owner_get_owner(i).one_way_collision:
					player_death()
	
# 玩家动画
func player_animation(delta) ->void:
	# 方向
	animated_node.flip_h = move_direction != 1
	
	# 受伤/无敌星闪烁
	if hurt:
		animated_node.modulate.a = 0.5 + 0.5*cos(hurt_flash)
		hurt_flash += hurt_flash_speed * delta
	elif star:
		animated_node.modulate.a = 0.75 + 0.25*cos(star_flash)
		star_flash += star_flash_speed * delta
	else:
		animated_node.modulate.a = 1
		hurt_flash = 0
		star_flash = 0
		
	# 无敌星
	if star:
		# 音效
		if $Timer/Star.time_left > 1-delta && $Timer/Star.time_left < 1+delta:
			if !$Audio/StarOut.playing:
				$Audio/StarOut.play()
				if Player.get_player_star_num() == 1:
					Audio.channel_fade_out(0,15)
	
	# 切换状态
	if !animated_node.get_node("TimerSwitch").is_stopped():
		return
	match(state):
		0: animated_node.current = "Small"
		1: animated_node.current = "Big"
		2: animated_node.current = "Fire"
		3: animated_node.current = "Beet"
		4: animated_node.current = "Lui"
	
	# 切换动画
	if on_floor_snap:
		if crouch:
			animated_node.animation = "crouch"
		else:
			if !$Timer/Launch.is_stopped() && (state == 2 || state == 3):
				animated_node.animation = "launch"
			elif move >= 0 && move < move_initial/2:
				animated_node.animation = "idle"
			else:
				animated_node.animation = "walk"
				animated_node.walk_speed = move*0.01
	elif water:
		if control_jump == 2:
			animated_node.animation = "swim"
		elif animated_node.animation == "swim":
			if animated_node.swim_finish:
				animated_node.animation = "dive"
				animated_node.swim_finish = false
		else:
			animated_node.animation = "dive"
	else:
		animated_node.animation = "jump"

# 玩家攻击
func player_attack() ->void:
	# 发子弹
	if control_fire == 2 && !crouch:
		if state == 2 && get_tree().get_nodes_in_group("fireball_mario").size() < 2:
			$Audio/Fireball.play()
			$Timer/Launch.start()
			var new :KinematicBody2D = fireball.instance()
			Berry.transform_copy(new,self,$Point/Launcher.relative())
			new.direction = move_direction
			new.gravity_direction = gravity_direction
			new.add_to_group("fireball_mario")
			get_parent().add_child(new)
		if state == 3 && get_tree().get_nodes_in_group("beet_mario").size() < 2:
			$Audio/Fireball.play()
			$Timer/Launch.start()
			var new :KinematicBody2D = beet.instance()
			Berry.transform_copy(new,self,$Point/Launcher.relative())
			new.direction = move_direction
			new.gravity_direction = gravity_direction
			new.add_to_group("beet_mario")
			get_parent().add_child(new)
			
	# 无敌星
	$AreaShared/AttackEnemy.disabled = !star

# 玩家踩敌人
func player_stomp(bounce_speed :float = stomp_bounce, jump_speed :float = stomp_jump) ->void:
	if disable_deferred || get_parent() == Player || get_parent() == null:
		return
	$Audio/Stomp.play()
	if control_jump > 0:
		gravity = -jump_speed
	else:
		gravity = -bounce_speed

# 更新碰撞遮罩
func collision_update() ->void:
	if state == 0 || crouch:
		$CollisionShapeSmall.disabled = false
		$CollisionShapeBig.disabled = true
		$AreaShared.add_shape($CollisionShapeSmall)
		$AreaTop/CollisionShapeTop.position.y = -7
		$StompEnemy/RectBox2D.load_collision_shape($CollisionShapeSmall)
		$Point/Bubble.position.y = -2
	else:
		$CollisionShapeSmall.disabled = true
		$CollisionShapeBig.disabled = false
		$AreaShared.add_shape($CollisionShapeBig)
		$AreaTop/CollisionShapeTop.position.y = -33
		$StompEnemy/RectBox2D.load_collision_shape($CollisionShapeBig)
		$Point/Bubble.position.y = -23
	$Crush/CollisionShapeSmall.disabled = $CollisionShapeSmall.disabled
	$Crush/CollisionShapeBig.disabled = $CollisionShapeBig.disabled
	$HitBlock.position.y = $AreaTop/CollisionShapeTop.position.y - 5

# 玩家卡墙辅助函数
func player_solid_push(dir :Vector2, depth :int = -1) ->bool:
	collision_update()
	return solid_push(dir,depth)

# 状态更新
func player_state_update(state_new :int, force :bool = false) ->void:
	if disable_deferred || get_parent() == Player || get_parent() == null:
		return
	if force:
		if state == state_new:
			$Audio/ReversedItem.play()
		elif state >= 1 && state_new <= 1:
			$Audio/PowerDown.play()
			animated_node.switch(false)
		else:
			$Audio/PowerUp.play()
			animated_node.switch(state_new > 1)
		state = state_new
	elif state_new <= 0 || state == state_new || (state_new == 1 && state > 1):
		$Audio/ReversedItem.play()
	else:
		if state == 0:
			state = 1
			animated_node.switch(false)
		else:
			state = state_new
			animated_node.switch(true)
		$Audio/PowerUp.play()

# 受伤
func player_hurt(atk :int = 1, force :bool = false) ->void:
	if disable_deferred || get_parent() == Player || get_parent() == null:
		return
	if !force && (hurt || star || clear || pipe || atk < 1):
		return
	else:
		var state_new :int = min(2,state) as int - atk
		if state_new < 0:
			state = 0
			player_death(force)
		else:
			player_state_update(state_new,true)
			hurt = true
			$Timer/Hurt.start()

# 死亡
func player_death(force :bool = false) ->void:
	if death_once:
		return
	if disable_deferred || get_parent() == Player || get_parent() == null:
		return
	if !force && (clear || pipe):
		return
	else:
		player_star_cancel()
		death_once = true
		state = 0
		var new :Sprite = $Death.duplicate()
		Berry.transform_copy(new,self)
		new.texture = death
		new.visible = true
		new.activate = true
		get_parent().add_child(new)
		Player.disable(self)

# 无敌星
func player_star() ->void:
	if disable_deferred || get_parent() == Player || get_parent() == null:
		return
	star = true
	Audio.music_set_paused(true)
	Audio.fade_out[0] = -1
	Audio.music_channel[0].volume_db = 0
	Audio.music_channel[0].play()
	$Timer/Star.start()
	$StarParticles.emitting = true
	
# 取消无敌星
func player_star_cancel() ->void:
	star = false
	$StarParticles.emitting = false
	if Player.get_player_star_num() == 0:
		Audio.music_channel[0].stop()
		Audio.music_set_paused(false)
		
# 进水管
func player_pipe_enter(dir :int) ->void:
	$Audio/PowerDown.play()
	$Timer/Hurt.paused = true
	$Timer/Star.paused = true
	var room :Room2D = Berry.get_room2d(self)
	if room != null:
		var hud :Control = room.hud
		if hud != null:
			hud.time_set_paused(true)
	control = false
	pipe = dir + 1
	move = 0
	gravity = 0
	animated_node.z_index = z_index_pipe
	
# 出水管
func player_pipe_exit(dir :int) ->void:
	$Audio/PowerDown.play()
	animated_node.visible = true
	pipe += dir + 1
	
# 水管动画
func player_pipe_animation(delta :float) ->void:
	pipe_length += pipe_speed * delta
	match pipe:
		1, 6:
			animated_node.flip_h = false
			animated_node.animation = "walk"
			animated_node.walk_speed = 1.8
			if pipe_length < pipe_horizontal:
				position += pipe_speed*gravity_direction.tangent() * delta
			else:
				if pipe < 5:
					animated_node.visible = false
					if pipe_length >= pipe_vertical:
						pipe_length = 0
						pipe = 5
				else:
					pipe_length = 0
					move_direction = 1
					pipe = 10
		2, 7:
			if pipe < 5:
				if state == 0:
					animated_node.animation = "idle"
				else:
					animated_node.animation = "crouch"
			else:
				animated_node.animation = "jump"
			if pipe_length < pipe_vertical:
				position += pipe_speed*gravity_direction * delta
			else:
				pipe_length = 0
				if pipe < 5:
					pipe = 5
					animated_node.visible = false
				else:
					pipe = 10
		3, 8:
			animated_node.flip_h = true
			animated_node.animation = "walk"
			animated_node.walk_speed = 1.8
			if pipe_length < pipe_horizontal:
				position -= pipe_speed*gravity_direction.tangent() * delta
			else:
				if pipe < 5:
					animated_node.visible = false
					if pipe_length >= pipe_vertical:
						pipe_length = 0
						pipe = 5
				else:
					pipe_length = 0
					move_direction = -1
					pipe = 10
		4, 9:
			if pipe < 5:
				animated_node.animation = "jump"
			else:
				if state == 0:
					animated_node.animation = "idle"
				else:
					animated_node.animation = "crouch"
			if pipe_length < pipe_vertical:
				position -= pipe_speed*gravity_direction * delta
			else:
				pipe_length = 0
				if pipe < 5:
					pipe = 5
					animated_node.visible = false
				else:
					pipe = 10
	
	# 恢复
	if pipe == 10:
		$Timer/Hurt.paused = false
		$Timer/Star.paused = false
		var room :Room2D = Berry.get_room2d(self)
		if room != null:
			var hud :Control = room.hud
			if hud != null:
				hud.time_set_paused(false)
		pipe = 0
		control_recover = true
		animated_node.z_index = z_index_normal
	
# 水花
func water_spray() ->void:
	var new:AnimatedSprite = Lib.water_spray.instance()
	Berry.transform_copy(new,self,$Point/WaterSpray.relative())
	get_parent().add_child(new)

func _on_WaterSignal_water_in_exact() ->void:
	if gravity > 0:
		$Audio/Splash.play()
		water_spray()

func _on_WaterSignal_water_out_exact() ->void:
	if gravity < 0:
		$Audio/SplashSmall.play()
		water_spray()

func _on_Hurt_timeout() ->void:
	hurt = false

func _on_Star_timeout() ->void:
	player_star_cancel()
