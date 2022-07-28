extends Area2D

export var stem_count: int = 1 # 茎干数
export var speed_in :float = 50 # 钻入速度
export var speed_out :float = 50 # 钻出速度
export var remain_range: float = 64 # 不出现范围
export var remain_in :float = 1.4 # 水管内停留时间
export var remain_out :float = 1.4 # 水管外停留时间
export var fireball :int = 0 # 火球数
export var fireball_interval :float = 0.2 # 喷火球间隔
export var activate :bool = false # 是否激活
export var activate_range :float = 48 # 激活范围
export var in_pipe_first :bool = false
export var fireball_res :PackedScene

export var brush_border :Rect2 = Rect2(-16,-16,32,48)
export var brush_offset :Vector2 = Vector2(16,16)

var attacked :Array = [] # 待处理的攻击判定

var origin_position :Vector2
var state :int = 0
var pos :float = 0
var r_time :float = 0
var f_count :int = -1
var f_time :float = 0

onready var view :Node = Berry.get_view(self)
onready var rand :RandomNumberGenerator = Berry.get_rand(self)
onready var parent :Node = get_parent()
onready var height: int = 32 + max(0,stem_count)*16
	
# 攻击判定标识
func _enemy() ->void:
	pass
	
func _ready() ->void:
	position.y -= 16*(max(0,stem_count) - 1) 
	origin_position = position
	if in_pipe_first:
		state = 2
		pos = height*scale.y
	
func _physics_process(delta) ->void:
	# 激活
	if !activate:
		activate = view.is_in_view(global_position,activate_range*scale)
		return
	
	# state = 0: 在外
	if state == 0:
		var fire: bool = false
		if f_count > 0 || f_time > 0 || ( fireball > 0 && f_count != -1 && view.is_in_view(position,activate_range*scale)):
			r_time = 0
			fire = true
		
		if fire:
			f_time += delta
			if f_time >= fireball_interval:
				f_time = 0
				f_count += 1
				launch()
				if f_count >= fireball:
					f_count = -1
		else:
			r_time += delta
			if r_time >= remain_out:
				r_time = 0
				f_count = 0
				state = 1
				
	# state = 1: 钻入
	if state == 1:
		pos += speed_in * delta
		if pos >= height*scale.y:
			pos = height*scale.y
			state = 2
			
	# state = 2: 在内
	if state == 2:
		pos = height*scale.y
		var count :bool = true
		var p: Node = Berry.get_player_nearest(self)
		if remain_range > 0 && p != null:
			var p_pos :Vector2 = parent.global_transform.xform_inv(p.global_position)
			var s :float = Berry.distance_to_line(position,p_pos,rotation + PI/2)
			if s <= remain_range + 16*scale.x:
				count = false
				
		if count:
			r_time += delta
			if r_time >= remain_in:
				r_time = 0
				state = 3
				
	# state = 3: 钻出
	if state == 3:
		pos -= speed_out * delta
		if pos <= 0:
			pos = 0
			state = 0
			
	position = origin_position + pos*Vector2.DOWN.rotated(rotation)
	$Draw.length = height - pos/scale.y
	
	# 修正判定
	if $Draw.length <= 0:
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false
		$CollisionShape2D.position.y = ($Draw.length-30)/2 - 0.5
		$CollisionShape2D.shape.extents.y = $Draw.length/2 - 0.5

func launch() ->void:
	Audio.play($Fireball)
	var new :Node = fireball_res.instance()
	if rotation_degrees >= -45 && rotation_degrees <= 45:
		new.speed = rand.randi_range(-5, 5)*50
		new.gravity = rand.randi_range(-12, -8)*50
	elif rotation_degrees >= 45 && rotation_degrees <= 135:
		new.speed = rand.randi_range(5,8)*50
		new.gravity = rand.randi_range(-5,3)*50
	elif rotation_degrees >= 135 || rotation_degrees <= -135:
		new.speed = rand.randi_range(-5, 5)*50
		new.gravity = rand.randi_range(0, 3)*50
	else:
		new.speed = rand.randi_range(-8,-5)*50
		new.gravity = rand.randi_range(-5,3)*50
	Berry.transform_copy(new,self)
	parent.add_child(new)
