extends Node2D

export var score :int = 100

# 移动
const direction :Vector2 = Vector2.UP
const move_height :int = 60
const move_speed :int = 100
onready var origin :Vector2 = position

# 淡出
var fade :bool = false
const fade_speed :int = 3

# 绘制
var draw_position :Vector2
var length :int
var width: float
const height :int = 16
const sep :float = 8.0

func _ready() ->void:
	score = max(0,score) as int
	Global.score += score
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
	var s :String = score as String
	for i in length:
		var num: int = s.substr(i,1) as int
		var texture :Texture = $AnimatedSprite.frames.get_frame("default",num)
		draw_texture(texture,Vector2(-width/2.0+sep*i-2,-height/2.0))
	
func _process(delta) ->void:
	if origin.distance_to(position) < move_height:
		position += move_speed*direction * delta
	elif !fade && $Timer.is_stopped():
		$Timer.start()
		
	if fade:
		modulate.a -= fade_speed * delta
		if modulate.a <= 0:
			queue_free()
	
	length = (score as String).length()
	width = length*sep
	update()

func _on_Timer_timeout() ->void:
	fade = true
