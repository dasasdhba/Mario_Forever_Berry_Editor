extends StaticBody2D

export(Array, Rect2) var activation_areas :Array = [Rect2(Vector2.ZERO,Vector2(10016,480))]
export var infinity :bool = true # 不支持旋转
export var waiting_time :float = 6
export var shake_strong_time :float = 1
export var shake_weak_time :float = 2
export var fall_acceleration: float = 2500
export var fall_height: float = 320 # 必须是正数
export var rise_wait_time :float = 2
export var rise_speed: float = 50
export var shake_time :float = 0.75

export var preview :bool = true

export var brush_border :Rect2 = Rect2(-384,-480,768,512)
export var brush_offset :Vector2 = Vector2(320,64)

var step :int = 0
var timer :float = 0
var speed :float = 0

onready var origin :Vector2 = position
onready var direction :Vector2 = Berry.vector2_rotate_degree(rotation_degrees+90)
onready var view :Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
onready var rand :RandomNumberGenerator = Berry.get_rand(self)

func _physics_process(delta :float) ->void:
	if check_activation():
		spike_motion(delta)
	else:
		timer = 0
		
	if infinity:
		infinity_position()

func infinity_position() ->void:
	while global_position.x - 320 > view.current_border.position.x:
		global_position.x -= 32
	while global_position.x + 320 < view.current_border.end.x:
		global_position.x += 32

func check_activation() ->bool:
	if step > 0:
		return true
	var p :Node = scene.get_player_nearest(self)
	if p != null:
		var p_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
		for i in activation_areas:
			if i.has_point(p_pos):
				return true
	return false

func spike_motion(delta :float) -> void:
	match step:
		0:
			timer += delta
			if timer > waiting_time - shake_strong_time - shake_weak_time:
				spike_shaking(timer > waiting_time - shake_strong_time)
			if timer > waiting_time:
				timer = 0
				step = 1
		1:
			speed += fall_acceleration * delta
			position += speed * direction * delta
			var target_pos :Vector2 = origin + fall_height*direction
			if abs((position-target_pos).dot(direction)) < speed * delta:
				position = target_pos
				speed = 0
				var camera :Camera2D = view.get_current_camera()
				if camera != null:
					camera.shake_time = shake_time
				$CeilingSpike.play()
				step = 2
		2:
			timer += delta
			if timer > rise_wait_time:
				timer = 0
				step = 3
		3:
			position -= rise_speed*direction * delta
			if abs((position-origin).dot(direction)) < rise_speed*delta:
				position = origin
				speed = 0
				step = 0

func spike_shaking(strong :bool = false):
	if strong:
		position.y = origin.y + rand.randi_range(-3,3)
	else:
		position.y = origin.y + rand.randi_range(-1,1)
