tool
extends Area2D

enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1
export var interval :float = 0.26
export var number :int = 3
export var horizontal_range :int = 320
export var vertical_range :int = 300
export var speed :float = 50
export var speed_random :float = 150
export var jump_speed :float = 350
export var jump_speed_random :float = 350
export var preview_color :Color = Color(0.5,0.5,0,0.3)
export var fly_cheep :PackedScene

var parent :Node
var view :Node
var rand :RandomNumberGenerator

func _ready() ->void:
	if Engine.editor_hint:
		return
	$Timer.wait_time = interval
	view = Berry.get_view(self)
	rand = Berry.get_rand(self)
	parent = get_parent()

func _draw() ->void:
	if !Engine.editor_hint:
		return
	var col :Color = preview_color
	var spr :AnimatedSprite = $Red
	draw_rect(Rect2(Vector2.ZERO,Vector2.ONE),col)
	draw_set_transform(Vector2.ZERO,-rotation,Vector2(1/scale.x*direction,1/scale.y))
	var tex :Texture = spr.frames.get_frame("default",spr.frame)
	draw_texture(tex,Vector2(-34*((direction == -1) as int),0))
	draw_texture(tex,Vector2(scale.x*direction,scale.y)-34*Vector2((direction == 1) as int,1))
	draw_set_transform(Vector2.ZERO,-rotation,Vector2(1/scale.x,1/scale.y))
	draw_rect(Rect2(Vector2.ZERO,scale),Color(col.r,col.g,col.b,1),false,2)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
	
func _physics_process(_delta) ->void:
	if Engine.editor_hint:
		update()
		return
		
	var check :bool = false
	if get_tree().get_nodes_in_group("fly_cheep_generator").size() < number:
		for i in get_overlapping_areas():
			if i.has_method("_player"):
				check = true
				break
	if !check:
		if !$Timer.is_stopped():
			$Timer.stop()
	elif $Timer.is_stopped():
		$Timer.start()

func _on_Timer_timeout():
	var new_pos :Vector2
	if direction == DIR.LEFT:
		new_pos.x = view.current_border.end.x + 48 - rand.randi_range(0,horizontal_range)
	else:
		new_pos.x = view.current_border.position.x - 48 + rand.randi_range(0,horizontal_range)
	new_pos.y = view.current_border.end.y + 32 + rand.randi_range(0,vertical_range)
	var new :Node = fly_cheep.instance()
	new.position = new_pos
	new.direction = direction
	new.speed = speed + speed_random*rand.randf()
	new.gravity = -(jump_speed + jump_speed_random*rand.randf())
	parent.add_child(new)
	new.add_to_group("fly_cheep_generator")
