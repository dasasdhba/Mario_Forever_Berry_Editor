extends Node2D

export var detect_radius :float = 30
export var max_length :float = 32
export var disabled :bool = false
export var up_action :InputEventAction
export var down_action :InputEventAction
export var left_action :InputEventAction
export var right_action :InputEventAction

var touch_event :InputEvent = null
var touch_position :Vector2 = Vector2.ZERO

func has_point(point :Vector2) ->bool:
	return point.distance_to(position + $Stick.position) <= detect_radius

func parse_input(clear :bool = false) ->void:
	up_action.pressed = false
	down_action.pressed = false
	left_action.pressed = false
	right_action.pressed = false
	if clear:
		$Stick.position = Vector2.ZERO
		Input.parse_input_event(up_action)
		Input.parse_input_event(down_action)
		Input.parse_input_event(left_action)
		Input.parse_input_event(right_action)
		return
	
	var l :float = $Stick.position.length()
	var dir :Vector2 = $Stick.position.normalized()
	if l > max_length:
		$Stick.position = max_length * dir
		l = max_length
	
	var s :float = $Stick.position.dot(Vector2.UP)
	if s >= max_length/2:
		up_action.pressed = true
		up_action.strength = s/max_length
	s = $Stick.position.dot(Vector2.DOWN)
	if s >= max_length/2:
		down_action.pressed = true
		down_action.strength = s/max_length
	s = $Stick.position.dot(Vector2.LEFT)
	if s >= max_length/2:
		left_action.pressed = true
		left_action.strength = s/max_length
	s = $Stick.position.dot(Vector2.RIGHT)
	if s >= max_length/2:
		right_action.pressed = true
		right_action.strength = s/max_length
	
	Input.parse_input_event(up_action)
	Input.parse_input_event(down_action)
	Input.parse_input_event(left_action)
	Input.parse_input_event(right_action)
	
func _input(event :InputEvent) ->void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if touch_event == null:
				if !has_point(event.position):
					return
			elif touch_event.index != event.index:
				return
			touch_event = event
			touch_position = event.position
		elif touch_event != null && touch_event.index == event.index:
			touch_event = null
	elif event is InputEventScreenDrag:
		if touch_event != null && touch_event.index == event.index:
			touch_position = event.position

func _process(_delta) ->void:
	if disabled:
		touch_event = null
		parse_input(true)
		return
	if touch_event == null:
		$Stick.position = Vector2.ZERO
	else:
		$Stick.position = touch_position - position
	parse_input()
