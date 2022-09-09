extends Node2D

export var boss_node :NodePath = @""
enum MODE {RECOVER, PASS}
export(MODE) var end_mode :int = MODE.PASS
export var next_scene :PackedScene
export var pass_wait_time :float = 4
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var pass_direction :int = DIR.RIGHT
export var pass_res :PackedScene
export var hp_target_y :float = 96
export var hp_appear_speed :float = 50

var boss :Node = null
var boss_start :bool = false
var hp_appear :bool = false
var timer :float = 0
var once :bool = false

onready var hp :Sprite = $HP
onready var scene :Node = Berry.get_scene(self)

func _ready() ->void:
	if has_node(boss_node):
		boss = get_node(boss_node)
	if boss == null:
		queue_free()
		return
	hp.first_hp = boss.get_node("Life").health

func recover() ->void:
	hp_appear = false
	$Recover/RecoverMusic.setup_music()
	$Recover/RecoverCamera.setup()
	$Recover/RecoverForce.setup()

func level_pass() ->void:
	var new :Node = pass_res.instance()
	new.visible = false
	new.direction = pass_direction
	new.next_scene = next_scene
	get_parent().add_child(new)
	new._level_pass()
	
func _physics_process(delta :float) ->void:
	var is_boss_valid :bool = boss != null && is_instance_valid(boss)
	
	# HP
	if is_boss_valid:
		hp.hp = boss.get_node("Life").health
	if !hp_appear:
		if hp.position.y > -32:
			hp.position.y -= hp_appear_speed * delta
		elif !is_boss_valid:
			queue_free()
	else:
		if hp.position.y < hp_target_y:
			hp.position.y += hp_appear_speed * delta
		else:
			hp.position.y = hp_target_y
			
	# 结束
	if boss_start && !is_boss_valid:
		if end_mode == MODE.RECOVER:
			if !once:
				recover()
				once = true
		else:
			if !once:
				Audio.music_stop(true)
				for i in scene.current_player:
					i.clear = true
				once = true
			timer += delta
			if timer >= pass_wait_time:
				level_pass()
				queue_free()

func _on_Music_area_entered(area :Area2D) ->void:
	if boss_start:
		return
	if area.has_method("_player"):
		boss_start = true
		boss.activate = true
		var room :Node = Berry.get_room2d(self)
		if room != null:
			var hud :Control = room.hud
			if hud != null:
				remove_child(hp)
				hud.call_deferred("add_child",hp)
				hp.visible = true
				hp_appear = true
