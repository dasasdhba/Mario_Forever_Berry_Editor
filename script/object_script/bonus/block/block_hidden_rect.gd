# 用于顶砖判定
extends RectCollision2D

func _ready() ->void:
	collision_name = "block"
	var box :RectBox2D = RectBox2D.new()
	box.load_collision_shape(get_parent().get_node("CollisionShape2D"))
	add_child(box)
	rect_init()
