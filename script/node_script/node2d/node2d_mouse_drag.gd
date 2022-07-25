extends Node2D

export var disabled :bool = false
export var radius :float = 30
export var center_offset :Vector2 = Vector2.ZERO
export var border :Rect2 = Rect2(0,0,640,480)

var click :bool = false
var just_click :bool = false
var click_restrict :bool = false
var drag :bool = false

func has_point(point :Vector2) ->bool:
	return point.distance_to(position + center_offset) <= radius

func _process(_delta) ->void:
	if disabled:
		return
	click = Input.is_mouse_button_pressed(BUTTON_LEFT)
	if click:
		if !click_restrict:
			click_restrict = true
			just_click = true
		else:
			just_click = false
	else:
		click_restrict = false
		just_click = false
	var m_pos :Vector2 = get_viewport().get_mouse_position()
	if !drag:
		if just_click && has_point(m_pos):
			drag = true
	else:
		if !click:
			drag = false
		position = m_pos - center_offset
		position.x = clamp(position.x,border.position.x,border.end.x)
		position.y = clamp(position.y,border.position.y,border.end.y)
