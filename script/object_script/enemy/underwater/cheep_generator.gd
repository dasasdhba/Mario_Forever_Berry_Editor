tool
extends Area2D

enum TYPE {RED, GREEN}
export(TYPE) var type :int = 0
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1
export var interval :float = 6
export var number :int = 10
export var preview_red :Color = Color(0.5,0,0,0.3)
export var preview_green :Color = Color(0,0.5,0,0.3)
export var red_cheep :PackedScene
export var green_cheep :PackedScene

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
	var col :Color = preview_red
	var spr :AnimatedSprite = $Red
	if type == TYPE.GREEN:
		col = preview_green
		spr = $Green
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
	if get_tree().get_nodes_in_group("cheep_generator").size() < number:
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
		new_pos.x = view.current_border.end.x + 48
	else:
		new_pos.x = view.current_border.position.x - 48
	new_pos.y = rand.randi_range((position.y + 16) as int, (position.y + 32*scale.y - 16) as int)
	var new :Node
	if type == TYPE.RED:
		new = red_cheep.instance()
	else:
		new = green_cheep.instance()
	new.position = new_pos
	new.direction = direction
	new.activate = true
	parent.add_child(new)
	new.add_to_group("cheep_generator")
