extends Label

func has_mouse() ->bool:
	var mouse_pos :Vector2 = get_viewport().get_mouse_position()
	if Rect2(rect_position,rect_size).has_point(mouse_pos):
		return true
	for i in get_children():
		if i is Control:
			if Rect2(rect_position + i.rect_position,i.rect_size).has_point(mouse_pos):
				return true
	return false
