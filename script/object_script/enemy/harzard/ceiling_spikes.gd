# 请das自行换算成godot单位
extends Area2D

export(Array, Rect2) var activation_areas:Array = [Rect2(Vector2.ZERO,Vector2.ONE)]
export var waiting_delay:int = 300
export var falling_acceleration:float = 1
export var bottom:float = 320 # 必须是正数
export var bottom_duration:int = 100
export var rising_speed:float = 1
export var vibration_duration:float = 0.75

export var preview:bool = false

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,-160)

var step:int = 0
var count:int = 0
var speed:float = 0

onready var origin:Vector2 = position
onready var fps:int = Engine.iterations_per_second
onready var view:Node = Berry.get_view(self)
onready var rand:RandomNumberGenerator = Berry.get_rand(self)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _physics_process(_delta):
	var t = check_activation()
	if t:
		spike_motion()

func check_activation() -> bool:
	var player = Berry.get_player_nearest(self)
	if player != null:
		for i in activation_areas:
			if i.has_point(player.position):
				return true
				break
	return false

func spike_motion() -> void:
	var direction:Vector2 = Berry.vector2_rotate_degree(rotation_degrees+90)
	var length:float = 0
	match step:
		0:
			count += 1
			if count > waiting_delay - fps:
				spike_shaking(true)
			elif count > waiting_delay - 3*fps:
				spike_shaking(false)
			if count > waiting_delay:
				count = 0
				step = 1
		1:
			var target_length:float = (origin + bottom*direction).length()
			speed += falling_acceleration
			position += speed * direction
			length = update_length()
			if length >= target_length:
				position = origin + bottom*direction
				speed = 0
				view.get_current_camera().shake_time = vibration_duration
				Audio.play($CeilingSpikeStuns)
				step = 2
		2:
			count += 1
			if count > bottom_duration:
				count = 0
				step = 3
		3:
			speed = -rising_speed
			position += speed * direction
			length = update_length()
			if length == 0 || (length > 0 && position.direction_to(origin).dot(direction) > 0):
				position = origin
				speed = 0
				step = 0

func spike_shaking(strong:bool):
	if strong:
		position.y = origin.y + rand.randf_range(-3,3)
	else:
		position.y = origin.y + rand.randf_range(-1,1)

func update_length() -> float:
	print((position - origin).length())
	return (position - origin).length()
