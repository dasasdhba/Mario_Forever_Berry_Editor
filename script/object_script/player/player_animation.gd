# 玩家动画
extends Node2D

var current :String = "Small" # 当前 AnimatedSprite
var animation :String = "idle" # 当前 Animation
var walk_speed :float = 0 # 行走动画速度调整
var flip_h :bool = false
var flip_v :bool = false
var swim_finish :bool = false

func _physics_process(_delta) ->void:
	var current_node :AnimatedSprite
	for i in get_children():
		if i.name == current:
			i.visible = true
			if !i.is_connected("animation_finished",self,"on_animation_finished"):
				i.connect("animation_finished",self,"on_animation_finished")
			current_node = i
		elif i is AnimatedSprite:
			i.visible = false
			if i.is_connected("animation_finished",self,"on_animation_finished"):
				i.disconnect("animation_finished",self,"on_animation_finished")
	current_node.animation = animation
	current_node.play()
	if animation == "walk":
		current_node.speed_scale = walk_speed
	else:
		current_node.speed_scale = 1
	current_node.flip_h = flip_h
	current_node.flip_v = flip_v
	
func switch(power :bool) -> void:
	$TimerSwitch.start()
	current = "Switch"
	if power:
		if get_parent().state != 3:
			animation = "powerup"
		else:
			animation = "beet"
	else:
		animation = "powerdown"

func on_animation_finished() ->void:
	if animation == "swim":
		swim_finish = true
