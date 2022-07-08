# 基于 KinematicBody2D 提供重力参数及加速度 process，与水的接触需要自行判断
extends KinematicBody2D
class_name Gravity, "icon/gravity.png"

var gravity :float = 0 # 重力速度
var gravity_direction :Vector2 = Vector2.DOWN # 重力方向

# 以下默认参数适用于敌人
export var gravity_max :float = 500 # 重力最大速度
export var gravity_max_water :float = 150 # 水中最大速度
export var gravity_acceleration :float = 1000 # 重力加速度
export var gravity_deceleration :float = 1000 # 重力减速度
export var water_acceleration :float = 250 # 水中加速度
export var water_deceleration :float = 2125 # 水中减速度

const push_value :int = 4 # 越大越不容易被吸到反斜坡上，但越容易穿墙

# 计算重力
func gravity_process(delta :float,water :bool = false) ->void:
	if !water:
		if gravity < gravity_max:
			gravity += gravity_acceleration * delta
		else:
			gravity -= gravity_deceleration * delta
	else:
		if gravity < gravity_max_water:
			gravity += water_acceleration * delta
		else:
			gravity -= water_deceleration * delta
			
# 卡墙辅助函数
func solid_push(dir :Vector2, depth :int = -1) ->bool:
	if dir == Vector2.ZERO:
		return false
	var count :int = 0
	var temp: Vector2 = position
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	while move_and_collide(-gdir,true,true,true):
		position += dir
		if depth > 0:
			count += 1
			if count > depth:
				position = temp
				return false
	return true
	
# 简单敌人运动，返回是否撞墙
func enemy_movement(delta :float, speed :float = 0, jump :float = 0) ->bool:
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	var velocity :Vector2 = gravity*gdir + speed*gdir.tangent()
	velocity = move_and_slide_with_snap(velocity,gdir,-gdir,true)
	if is_on_floor():
		if jump > 0:
			gravity = -jump
		else:
			gravity = velocity.dot(gdir)
	elif is_on_ceiling():
		solid_push(gravity_direction,push_value)
		if gravity < 0:
			gravity = 0
			
	var r :bool = is_on_wall() || (is_on_floor() && is_on_ceiling())
	
	# 刷新 is_on_floor()
	var temp :Vector2 = position
	move_and_slide_with_snap(gravity_acceleration*gdir * delta,gdir,-gdir,true)
	position = temp
	
	return r
