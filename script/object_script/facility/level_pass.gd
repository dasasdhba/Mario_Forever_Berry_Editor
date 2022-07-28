extends Node2D

export var next_scene :PackedScene
export var speed :float = 187.5
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = DIR.RIGHT
export var line_res :PackedScene
const height :float = 224.0

var disabled :bool = false
var line_dir :int = 1
var time_count :bool = false
var time_snd :float = 0

onready var parent :Node = get_parent()
onready var room :Node = Berry.get_room2d(self)
onready var scene :Node = room.manager
onready var rand :RandomNumberGenerator = Berry.get_rand(self)

export var brush_border :Rect2 = Rect2(-48,-144,96,288)
export var brush_offset :Vector2 = Vector2(0,-128)

# 用于标识
func _level_pass() ->void:
	for i in get_tree().get_nodes_in_group("fireball_player"):
		var new :Node = Lib.score.instance()
		new.score = 100
		Berry.transform_copy(i,new)
		parent.add_child(new)
		i.queue_free()
	for i in get_tree().get_nodes_in_group("beet_player"):
		var new :Node = Lib.score.instance()
		new.score = 200
		Berry.transform_copy(i,new)
		parent.add_child(new)
		i.queue_free()
	
	disabled = true
	$Pass.play()
	$Timer.start()
	Audio.music_stop(true)
	scene.current_checkpoint.clear()
	scene.checkpoint_scene = null
	scene.checkpoint_room_name = ""
	for i in scene.current_player:
		i.clear = true
		i.clear_direction = direction
		i.control = false
	if room.hud != null:
		room.hud.time_set_paused(true)
	
func get_bonus() ->void:
	var bonus :Node
	if $Area2D.position.y <= 30:
		bonus = Lib.life.instance()
	else:
		bonus = Lib.score.instance()
		if $Area2D.position.y <= 60:
			bonus.score = 5000
		elif $Area2D.position.y <= 100:
			bonus.score = 2000
		elif $Area2D.position.y <= 150:
			bonus.score = 1000
		elif $Area2D.position.y <= 200:
			bonus.score = 500
		else:
			bonus.score = 200
	Berry.transform_copy(bonus,self,$LinePos.relative())
	parent.add_child(bonus)
	
func _physics_process(delta) ->void:
	if time_count:
		var i :int = 0
		while room.hud.get_node("Time").time > 0 && i < 4:
			room.hud.get_node("Time").time -= 1
			Global.score += 10
			i += 1
		time_snd += delta
		if time_snd >= 0.1:
			time_snd = 0
			Audio.play($Count)
		if room.hud.get_node("Time").time == 0:
			time_count = false
			$TimerJump.start()
	if disabled:
		return
	$Area2D.position += line_dir*speed*delta*Vector2.DOWN
	if line_dir == 1:
		if $Area2D.position.y >= height:
			$Area2D.position.y = height
			line_dir *= -1
	elif $Area2D.position.y <= 0:
		$Area2D.position.y = 0
		line_dir *= -1
	
func _on_Area2D_area_entered(area :Area2D) ->void:
	if disabled:
		return
	if !area.has_method("_player"):
		return
	var p :Node = area.get_parent()
	if p.clear:
		return
	$Area2D.visible = false
	$LinePos.position.y = $Area2D/Sprite.position.y + $Area2D.position.y
	get_bonus()
	var new :Node = line_res.instance()
	Berry.transform_copy(new,self,$LinePos.relative())
	var angle :float
	if direction == DIR.LEFT:
		angle = (rand.randi_range(11,13))*11.25
	else:
		angle = (rand.randi_range(3,5))*11.25
	new.velocity = -250*Berry.vector2_rotate_degree(angle)
	new.gravity_direction = Vector2.DOWN.rotated(rotation)
	parent.add_child(new)
	_level_pass()

func _on_Timer_timeout():
	if room.hud == null || room.hud.level_time <= 0:
		$TimerJump.start()
		return
	time_count = true

func _on_TimerJump_timeout():
	if next_scene != null:
		scene.clear_data()
		scene.change_scene(next_scene)
