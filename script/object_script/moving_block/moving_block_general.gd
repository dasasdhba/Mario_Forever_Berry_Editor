extends MovingBlock

enum MODE {AUTOMATIC, PLAYER_STAND_ON}
enum BEHAVIOR {STOP, TURN, GRADIENT, NONE = -1}

export var velocity :Vector2 = Vector2(100,0)
export var gradient_time :float = 1 # 渐变转向时间
export(MODE) var mode :int = MODE.AUTOMATIC
export(BEHAVIOR) var reverse_mode :int = BEHAVIOR.TURN
export(BEHAVIOR) var reflect_mode :int = BEHAVIOR.TURN
export(BEHAVIOR) var turn_mode :int = BEHAVIOR.GRADIENT
export(BEHAVIOR) var solid_mode :int = BEHAVIOR.NONE
export var fall :bool = false
export var fall_max :float = 500
export var fall_acceleration :float = 500
export var fall_angle :float = 90 # 角度
export var fall_destroy :bool = true
export var destroy_range :Vector2 = Vector2(256,256)

var delay :bool = false
var stop :bool = false
var player_detect :bool = false
var fall_speed :float = 0
var teleport :bool = false
var teleport_temp_layer :int = 0
var teleport_temp_mask :int = 0
var gradient :int = 0
var gradient_scale :float = 1
var gradient_behavior :Array = []
var gradient_area :AreaShared

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,16)

onready var fall_dir :Vector2 = Berry.vector2_rotate_degree(fall_angle)
onready var view :Node = Berry.get_view(self)

func _ready() ->void:
	$AreaShared.inherit(self)
	for i in $AreaShared.get_shape_owners():
		$AreaShared.shape_owner_get_owner(i).one_way_collision = false
	gradient_area = $AreaShared.duplicate()
	add_child(gradient_area)
	collision_origin_update()

func _physics_process(delta) ->void:
	if !delay:
		delay = true
		return
	if stop:
		set_collision_position()
		return
	if teleport:
		teleport = false
		collision_layer = teleport_temp_layer
		collision_mask = teleport_temp_mask
	if (mode == MODE.PLAYER_STAND_ON || fall) && !player_detect:
		for i in $AreaShared.get_overlapping_areas():
			if i.has_method("_player_bottom") && i.get_parent().on_floor_snap:
				player_detect = true
				break
	if mode == MODE.PLAYER_STAND_ON && !player_detect:
		return
	
	# 运动
	var delta_pos :Vector2 = -position
	var v :Vector2 = gradient_scale * velocity
	if fall && player_detect:
		fall_speed += fall_acceleration * delta
		if fall_speed > fall_max:
			fall_speed = fall_max
		v += fall_speed * fall_dir
	position += v * delta
	set_collision_position(v * delta)
	$AreaShared.position = v*delta
	gradient_area.position = v*gradient_time/2
	
	# 设置与瞬移
	for i in $AreaShared.get_overlapping_areas():
		if i.has_method("_moving_block_setting"):
			i._moving_block_setting(self)
		elif i.has_method("_moving_block_teleport"):
			teleport = true
			teleport_temp_layer = collision_layer
			teleport_temp_mask = collision_mask
			collision_layer = 0
			collision_mask = 0
			position += i._moving_block_teleport()
			return
	
	if fall && player_detect:
		if fall_destroy:
			var gdir :Vector2 = Berry.get_global_direction(self,fall_dir)
			if !view.is_in_limit_direction(global_position,destroy_range*scale,gdir):
				queue_free()
		return
	
	# 渐变
	if gradient > 0:
		if gradient == 1:
			gradient_scale -= (1/gradient_time) * delta
			if gradient_scale <= 0:
				gradient_scale = 0
				gradient = 2
				match gradient_behavior[0]:
					"reverse", "solid":
						velocity *= -1
					"reflect":
						var n :Vector2 = Vector2.RIGHT.rotated(gradient_behavior[1])
						velocity -= 2*velocity.dot(n)*n
					"turn":
						velocity = gradient_behavior[1]
						position = gradient_behavior[2]
				gradient_behavior.clear()
		else:
			gradient_scale += (1/gradient_time) * delta
			if gradient_scale >= 1:
				gradient_scale = 1
				gradient = 0
		return
	
	set_collision_position()
	# 反转
	if reverse_mode == BEHAVIOR.STOP || reverse_mode == BEHAVIOR.TURN:
		for i in $AreaShared.get_overlapping_areas():
			if i.has_method("_moving_block_reverse"):
				var temp_layer :int = collision_layer
				var temp_mask :int = collision_mask
				collision_layer = 2147483648
				move_and_collide(velocity * delta)
				collision_layer = temp_layer
				collision_mask = temp_mask
				if reverse_mode == BEHAVIOR.STOP:
					stop = true
				else:
					position -= velocity * delta
					velocity *= -1
				i._moving_block_reverse()
				break
	elif reverse_mode == BEHAVIOR.GRADIENT:
		for i in gradient_area.get_overlapping_areas():
			if i.has_method("_moving_block_reverse"):
				gradient = 1
				gradient_behavior.append("reverse")
				i._moving_block_reverse()
				break
				
	# 反射
	if reflect_mode == BEHAVIOR.STOP || reflect_mode == BEHAVIOR.TURN:
		for i in $AreaShared.get_overlapping_areas():
			if i.has_method("_moving_block_reflect"):
				var angle :float = i.get_parent().rotation
				var delta_angle :float = angle - velocity.angle()
				delta_angle = wrapf(delta_angle,-PI,PI)
				if abs(delta_angle) <= PI/2:
					continue
				var temp_layer :int = collision_layer
				var temp_mask :int = collision_mask
				collision_layer = 2147483648
				move_and_collide(velocity * delta)
				collision_layer = temp_layer
				collision_mask = temp_mask
				if reflect_mode == BEHAVIOR.STOP:
					stop = true
				else:
					var n :Vector2 = Vector2.RIGHT.rotated(angle)
					velocity -= 2*velocity.dot(n)*n
					position += velocity * delta
				i._moving_block_reflect()
				break
	elif reflect_mode == BEHAVIOR.GRADIENT:
		for i in gradient_area.get_overlapping_areas():
			if i.has_method("_moving_block_reflect"):
				var angle :float = i.get_parent().rotation
				var delta_angle :float = angle - velocity.angle()
				delta_angle = wrapf(delta_angle,-PI,PI)
				if abs(delta_angle) <= PI/2:
					continue
				gradient = 1
				gradient_behavior.append("reflect")
				gradient_behavior.append(angle)
				i._moving_block_reflect()
				break
				
	# 转向
	if turn_mode == BEHAVIOR.STOP || turn_mode == BEHAVIOR.TURN:
		for i in $AreaShared.get_overlapping_areas():
			if !i.has_method("_moving_block_turn"):
				continue
			var i_pos :Vector2 = Berry.get_xform_position(self,i.global_position)
			var length :float = velocity.length()
			if position.distance_to(i_pos) > length * delta:
				continue
			if velocity.angle() != i.rotation:
				position = i_pos
				if turn_mode == BEHAVIOR.STOP:
					stop = true
				else:
					velocity = length * Vector2.RIGHT.rotated(i.rotation)
				i._moving_block_turn()
				break
	elif turn_mode == BEHAVIOR.GRADIENT:
		for i in gradient_area.get_overlapping_areas():
			if !i.has_method("_moving_block_turn"):
				continue
			var i_pos :Vector2 = Berry.get_xform_position(self,i.global_position)
			var length :float = velocity.length()
			if (position+gradient_area.position).distance_to(i_pos) > length * delta:
				continue
			if velocity.angle() != i.rotation:
				gradient = 1
				gradient_behavior.append("turn")
				gradient_behavior.append(length * Vector2.RIGHT.rotated(i.rotation))
				gradient_behavior.append(i_pos)
				i._moving_block_turn()
				break
	# 实心
	if solid_mode == BEHAVIOR.NONE:
		delta_pos += position
		set_collision_position(delta_pos)
		return
	var temp_layer :int = collision_layer
	var temp_mask :int = collision_mask
	if collision_layer & 2147483648 == 2147483648:
		collision_layer -= 2147483648
	collision_mask = 0
	if solid_mode == BEHAVIOR.STOP || solid_mode == BEHAVIOR.TURN:
		if move_and_collide(velocity * delta):
			if solid_mode == BEHAVIOR.STOP:
				stop = true
			else:
				position -= velocity * delta
				velocity *= -1
	elif solid_mode == BEHAVIOR.GRADIENT:
		if move_and_collide(velocity*gradient_time/2 * delta,true,true,true):
			gradient = 1
			gradient_behavior.append("solid")
	collision_layer = temp_layer
	collision_mask = temp_mask
	delta_pos += position
	set_collision_position(delta_pos)
