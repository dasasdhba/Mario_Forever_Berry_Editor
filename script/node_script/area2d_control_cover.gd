# 当玩家与该区域接触时，调整 parent Control 节点的 modulate.a
extends Area2D

export var alpha_min :float = 0.5
export var alpha_max :float = 1
export var alpha_speed :float = 3
export var position_fix :bool = true
var adjust :bool = false

onready var parent: Control = get_parent()
onready var view: Node = Berry.get_view(self)
onready var delta_pos: Vector2 = position - parent.rect_position

func _process(delta):
	if position_fix:
		position = view.current_border.position + parent.rect_position + delta_pos
	if !adjust:
		if parent.modulate.a < alpha_max:
			parent.modulate.a += alpha_speed * delta
		else:
			parent.modulate.a = alpha_max
	else:
		if parent.modulate.a > alpha_min:
			parent.modulate.a -= alpha_speed * delta
		else:
			parent.modulate.a = alpha_min

func _physics_process(_delta):
	adjust = false
	for i in get_overlapping_areas():
		if i.has_method("_player"):
			adjust = true
			break
