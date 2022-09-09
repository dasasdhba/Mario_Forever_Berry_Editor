extends Node

# 招式列表（函数名）
export(Array,String) var attack_list :Array = [
	"flame",
	"flame",
	"flame",
	"triple"
]

# 8-4 attack list
#export(Array,String) var attack_list :Array = [
#	"flame",
#	"flame",
#	"flame",
#	"triple",
#	"hammer",
#	"flame",
#	"flame",
#	"flame",
#	"fire"
#]

var phrase :int = 0
var ground_pos = null

onready var parent :Node = get_parent()
onready var anim :AnimatedSprite = parent.get_node("AnimatedSprite")
onready var scene :Node = Berry.get_scene(self)
onready var rand :RandomNumberGenerator = Berry.get_rand(self)

func _physics_process(delta :float) ->void:
	if !parent.activate:
		return
	
	if parent.is_on_floor():
		ground_pos = parent.position
	
	if has_method(attack_list[phrase]):
		call(attack_list[phrase],delta)
	else:
		attack_switch()

# 切换招式
func attack_switch() ->void:
	phrase += 1
	if phrase >= attack_list.size():
		phrase = 0
	if !has_method(attack_list[phrase]):
		attack_switch()
	elif has_method(attack_list[phrase]+"_ready"):
		call(attack_list[phrase]+"_ready")

# 喷火
export var flame_res :PackedScene
export var flame_speed :float = 300
export var flame_speed_follow :float = 100
export var flame_interval :float = 2
export var flame_interval_random :float = 1
export var flame_wait_time :float = 0.5
export var flame_end_time :float = 0.5
var flame_phrase :int = 0
var flame_timer :float = 0
var flame_i_random :float = 0

func flame_ready() ->void:
	flame_phrase = 0
	flame_timer = 0
	flame_i_random = rand.randf_range(0,flame_interval_random)

func flame(delta :float, triple :bool = false) ->void:
	match flame_phrase:
		0:
			flame_timer += delta
			if flame_timer >= flame_interval + flame_i_random:
				flame_timer = 0
				flame_phrase = 1
				parent.anim_control = false
		1:
			var wait :float
			if !triple:
				wait = flame_wait_time
				anim.animation = "flame_ready"
			else:
				wait = triple_wait_time
				anim.animation = "triple_ready"
			flame_timer += delta
			if flame_timer >= wait:
				flame_timer = 0
				flame_phrase = 2
				$Audio/Flame.play()
				flame_launch(triple)
		2:
			anim.animation = "flame"
			flame_timer += delta
			if flame_timer >= flame_end_time:
				flame_timer = 0
				flame_phrase = 0
				parent.anim_control = true
				attack_switch()

func flame_get_follow_position() ->Vector2:
	var result :Vector2
	if parent.player_position is Vector2:
		result = Berry.grid(parent.player_position,16) + 32*rand.randi_range(-1,1)*parent.gravity_direction
	else:
		result = Berry.grid(parent.position,16) + 32*rand.randi_range(-1,1)*parent.gravity_direction
	if ground_pos is Vector2:
		var d :float = (result - ground_pos - $FlameBottomPos.relative()).dot(parent.gravity_direction)
		if d > 0:
			result -= d*parent.gravity_direction
	return result
	
func is_position_over_ground(pos :Vector2) ->bool:
	if !(ground_pos is Vector2):
		return true
	return (pos - ground_pos - $FlameBottomPos.relative()).dot(parent.gravity_direction) <= 0
	
func flame_create(follow_pos :Vector2 = Vector2.ZERO) ->void:
	var new :Node = flame_res.instance()
	Berry.transform_copy(new,parent,$FlamePos.relative(anim.flip_h))
	new.direction = 1 if !anim.flip_h else -1
	new.follow = true
	new.follow_position = follow_pos
	new.speed = flame_speed
	new.speed_follow = flame_speed_follow
	parent.get_parent().add_child(new)
	
func flame_launch(triple :bool = false) ->void:
	var follow_position :Vector2 = flame_get_follow_position()
	if !triple:
		flame_create(follow_position)
	else:
		var i :int = 0
		var j :int = 0
		var i_flag :bool = false
		while i+j < triple_number:
			var create_pos :Vector2 = follow_position
			if !i_flag:
				create_pos += 32*i*parent.gravity_direction
			else:
				create_pos -= 32*(j+1)*parent.gravity_direction
				flame_create(create_pos)
				j += 1
				continue
			if is_position_over_ground(create_pos):
				flame_create(create_pos)
				i += 1
				continue
			else:
				i_flag = true

# 三重火
export var triple_wait_time :float = 1
export var triple_number :int = 3

func triple_ready() ->void:
	flame_ready()

func triple(delta :float) ->void:
	flame(delta, true)

# 锤子
export var hammer_res :PackedScene
export var hammer_round_count :int = 4
export var hammer_wait_time :float = 2
export var hammer_interval :float = 0.12
export var hammer_number :int = 16

var hammer_timer :float = 0
var hammer_counter :int = 0
var hammer_r_counter :int = 0
var hammer_throw :bool = false

func hammer_ready() ->void:
	hammer_timer = 0
	hammer_counter = 0
	hammer_r_counter = 0
	hammer_throw = false
	parent.walk = false
	parent.jump = false
	parent.anim_control = false
	
func hammer(delta :float) ->void:
	if !hammer_throw:
		anim.animation = "hammer_ready"
		if hammer_r_counter >= hammer_round_count:
			hammer_r_counter = 0
			parent.walk = true
			parent.jump = true
			parent.anim_control = true
			attack_switch()
			return
		hammer_timer += delta
		if hammer_timer >= hammer_wait_time:
			hammer_timer = 0
			hammer_throw = true
	else:
		anim.animation = "hammer"
		hammer_timer += delta
		if hammer_timer >= hammer_interval:
			hammer_timer = 0
			
			var new :Node = hammer_res.instance()
			Berry.transform_copy(new,parent,$HammerPos.relative(anim.flip_h))
			new.direction = 1 if !anim.flip_h else -1
			var rng :Node = new.get_node("RNG")
			rng.gravity_min = 10
			rng.gravity_max = 14
			parent.get_parent().add_child(new)
			
			hammer_counter += 1
			if hammer_counter >= hammer_number:
				hammer_counter = 0
				hammer_r_counter += 1
				hammer_throw = false

# 火球
export var fire_res :PackedScene
export var fire_wait_time :float = 2
export var fire_interval :float = 0.14
export var fire_number :int = 30

var fire_launch :bool = false
var fire_timer :float = 0
var fire_counter :int = 0

func fire_ready() ->void:
	fire_launch = false
	fire_timer = 0
	fire_counter = 0
	parent.walk = false
	parent.anim_control = false
	parent.look_player = false
	
func fire(delta :float) ->void:
	if !fire_launch:
		anim.animation = "flame"
		fire_timer += delta
		if fire_timer >= fire_wait_time:
			fire_timer = 0
			fire_launch = true
	if fire_launch:
		anim.animation = "fire"
		fire_timer += delta
		if fire_timer >= fire_interval:
			fire_timer = 0
			Audio.play($Audio/Fire)
			
			var new :Node = fire_res.instance()
			Berry.transform_copy(new,parent,$FlamePos.relative(anim.flip_h))
			var dir :int = 1 if !anim.flip_h else -1
			new.speed = dir*rand.randi_range(8,12)*50
			new.gravity = -rand.randi_range(3,8)*50
			parent.get_parent().add_child(new)
			
			fire_counter += 1
			if fire_counter >= fire_number:
				fire_counter = 0
				fire_launch = false
				parent.walk = true
				parent.anim_control = true
				parent.look_player = true
				attack_switch()
