extends Label

var mouse :bool = false

func _ready() ->void:
	if !is_connected("mouse_exited",self,"on_mouse_exited"):
		connect("mouse_exited",self,"on_mouse_exited")
	if !is_connected("mouse_entered",self,"on_mouse_entered"):
		connect("mouse_entered",self,"on_mouse_entered")

func has_mouse() ->bool:
	return mouse
	
func on_mouse_entered() ->void:
	mouse = true
	
func on_mouse_exited() ->void:
	mouse = false
