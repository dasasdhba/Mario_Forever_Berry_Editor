extends Node2D

export var life :int = 1

# 移动
const direction :Vector2 = Vector2.UP
const move_height :int = 60
const move_speed :int = 100
onready var origin = position

# 淡出
var fade :bool = false
const fade_speed :int = 3

# 绘制
var draw_position :Vector2
var length :int
var width: float
const height :int = 16
const sep :float = 11.0

func _ready() ->void:
	life = max(0,life) as int
	Global.life += life
	$Life.play()
	var room :Room2D = Berry.get_room2d(self)
	if room != null:
		var parent: Node = get_parent()
		var temp_pos :Vector2 = global_position
		parent.remove_child(self)
		room.add_child(self)
		global_position = temp_pos
		global_rotation = 0
		global_scale = Vector2.ONE
		origin = position

func _draw() ->void:
	var s :String = life as String
	for i in length+2:
		var extra :int = 0
		var texture :Texture
		if i < length:
			var num: int = s.substr(i,1) as int
			texture = $AnimatedSprite.frames.get_frame("default",num)
		else:
			var letter :int = i - length + 10
			extra = i-length
			texture = $AnimatedSprite.frames.get_frame("default",letter)
		draw_texture(texture,Vector2(-width/2.0+sep*i-2+extra,-height/2.0))
			
	
func _process(delta) ->void:
	if origin.distance_to(position) < move_height:
		position += move_speed*direction * delta
	elif !fade && $Timer.is_stopped():
		$Timer.start()
		
	if fade:
		modulate.a -= fade_speed * delta
		if modulate.a <= 0:
			queue_free()
	
	length = (life as String).length()
	width = (length + 2)*sep
	update()

func _on_Timer_timeout() ->void:
	fade = true
