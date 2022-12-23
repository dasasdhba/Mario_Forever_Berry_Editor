# 甜菜运动
extends Gravity

var speed :float
var count :int = 0
var hit_block_hint :bool = false

export var speed_init :float = 100
export var speed_base: float = 10 # CTF 单位
export var speed_random: int = 32 # CTF 单位
export var direction :int = 1
export var gravity_init :float = 250
export var bounce_speed :float = 400
export var bounce_count :int = 3

onready var rand :RandomNumberGenerator = Berry.get_rand(self)
onready var atk :bool = has_node("AreaShared/AttackEnemy")

func _ready() ->void:
	$AreaShared.inherit(self)
	gravity = -gravity_init
	speed = speed_init
	
func _physics_process(delta) ->void:
	# 顶砖块
	if hit_block_hint:
		$HitBlock.hit_block()
		hit_block_hint = false
	if !$CollisionShape2D.disabled:
		if $HitBlock.hit_block_hidden():
			bounce()
	
	var water :bool = $AreaShared/WaterDetect.is_in_water()
	# 落水与恢复
	if water:
		speed = 0
		gravity = gravity_max_water
		$CollisionShape2D.disabled = true
		if atk:
			$AreaShared/AttackEnemy.disabled = true
		$BubbleLauncher.angle = -gravity_direction.angle()
		$BubbleLauncher.offset = position
	elif $CollisionShape2D.disabled && count < bounce_count:
		if atk:
			$AreaShared/AttackEnemy.disabled = false
		$CollisionShape2D.disabled = false
		if move_and_collide(Vector2.ZERO,true,true,true):
			$CollisionShape2D.disabled = true
	$BubbleLauncher.activate = water
	
	# 重力
	gravity_process(delta,water)
		
	# 应用物理
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	var velocity :Vector2 = gravity*gdir + speed*direction*gdir.tangent()
	move_and_slide(velocity,-gdir,true)
	
	if is_on_floor() || is_on_ceiling() || is_on_wall():
		hit_block_hint = true
		bounce()
		
	# 累计次数
	if count >= bounce_count:
		$CollisionShape2D.disabled = true
		if atk:
			$AreaShared/AttackEnemy.disabled = true
	
func bounce() ->void:
	if count >= bounce_count:
		return
	# 更新数据
	count += 1
	gravity = -bounce_speed
	speed = (speed_base + (rand.randi() % speed_random))*6.25
	direction *= -1
	# 特效与音效
	var new :AnimatedSprite = Lib.boom.instance()
	new.position = position
	new.scale = scale
	get_parent().add_child(new)
	$AudioBoom.play()
	# 上穿墙
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	if move_and_collide(gravity/50*gdir,true,true,true):
		$CollisionShape2D.disabled = true
