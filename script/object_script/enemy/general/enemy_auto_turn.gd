# 敌人自动转向(红乌龟)，需要设置为敌人的子节点
extends Area2D

var delay :bool = false

onready var parent :Node = get_parent()

func _physics_process(_delta):
	if parent.is_on_floor():
		if !delay:
			delay = true
			return
	elif delay:
		delay = false
	if parent.is_on_floor() && !Berry.area2d_is_overlapping_with_solid(self):
		parent.direction *= -1
	$CollisionRight.disabled = parent.direction != 1
	$CollisionLeft.disabled = parent.direction == 1
