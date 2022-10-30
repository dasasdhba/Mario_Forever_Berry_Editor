extends Sprite

export var current :int = 0
export var unselected_alpha :float = 0.3
export var alpha_speed :float = 3
export var fade_alpha_speed :float = 5
export var disable :bool = false setget set_disable

var item :Array
var sprite :Sprite
var up_restrict :bool = false
var down_restrict :bool = false
var select_restrict :bool = false
var mobile :bool = false

signal selected(index)

onready var parent :Node = get_parent()

func set_disable(new :bool) ->void:
	disable = new
	up_restrict = true
	down_restrict = true
	select_restrict = true
	set_item_alpha(0,true)

func _ready():
	match OS.get_name():
		"Android", "iOS":
			mobile = true
	
	for i in parent.get_children():
		if i is Label:
			item.append(i)
	set_item_alpha(0,true)
	if !mobile:
		sprite = Sprite.new()
		sprite.texture = texture
	else:
		visible = false
	
func _process(delta) ->void:
	if item.empty() || disable:
		return
	switch()
	select()
	position = item[current].rect_position + Vector2(-37,17)
	set_item_alpha(delta)
	
func get_input() ->int:
	var input :int = (Input.is_action_just_pressed("ui_down") as int) - (Input.is_action_just_pressed("ui_up") as int)
	if input != 0:
		down_restrict = Input.is_action_pressed("ui_down")
		up_restrict = Input.is_action_pressed("ui_up")
	else:
		var down :bool = false
		var up :bool = false
		if Input.is_key_pressed(KEY_DOWN):
			if !down_restrict:
				down_restrict = true
				down = true
		else:
			down_restrict = false
		if Input.is_key_pressed(KEY_UP):
			if !up_restrict:
				up_restrict = true
				up = true
		else:
			up_restrict = false
		input = (down as int) - (up as int)
	return input
	
func switch() ->void:
	if mobile:
		return
	var mouse :bool = false
	var new :int = current
	for i in item.size():
		if item[i].has_method("has_mouse"):
			if item[i].has_mouse():
				new = i
				mouse = true
				break
	if !mouse:
		new = clamp(current+get_input(),0,item.size()-1) as int
	if current != new:
		Audio.play($AudioMove)
		current = new
		var fade :Node = Lib.fade.instance()
		Berry.transform_copy(fade,self)
		fade.inherit(self)
		fade.add_sprite(sprite)
		fade.alpha_speed = fade_alpha_speed
		parent.add_child(fade)
		
func select() ->void:
	if mobile:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if !select_restrict:
				select_restrict = true
				for i in item.size():
					if item[i].has_method("has_mouse"):
						if item[i].has_mouse():
							current = i
							emit_signal("selected",current)
							break
		else:
			select_restrict = false
		return
	if Input.is_action_pressed("ui_jump") || Input.is_action_pressed("ui_accept") || Input.is_mouse_button_pressed(BUTTON_LEFT):
		if !select_restrict:
			select_restrict = true
			emit_signal("selected",current)
	else:
		select_restrict = false

func set_item_alpha(delta :float, immediate :bool = false) ->void:
	if mobile:
		return
	if immediate:
		for i in item.size():
			if i == current:
				item[i].self_modulate.a = 1
			else:
				item[i].self_modulate.a = unselected_alpha
		return
	for i in item.size():
		if i == current:
			if item[i].self_modulate.a < 1:
				item[i].self_modulate.a += alpha_speed * delta
			else:
				item[i].self_modulate.a = 1
		else:
			if item[i].self_modulate.a > unselected_alpha:
				item[i].self_modulate.a -= alpha_speed * delta
			else:
				item[i].self_modulate.a = unselected_alpha
