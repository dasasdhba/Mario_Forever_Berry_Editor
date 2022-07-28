extends Node2D

export var first_scene :PackedScene
export var del_point_total :int = 20
export var del_time :float = 3

var in_save_area :bool = false
var save_index :int = 1

var del_point_current :int = 0
var del_restrict :bool = false
var timer :float = 0

var mobile :bool = false

onready var save_file :ConfigFile = ConfigFile.new()
onready var scene :Node = Berry.get_scene(self)

func _ready() ->void:
	match OS.get_name():
		"Android", "iOS":
			mobile = true
	
	# 存档初始化
	var file :File = File.new()
	if file.file_exists(Global.save_file):
		var err = save_file.load_encrypted_pass(Global.save_file,Global.save_key)
		if err == OK:
			return
	save_file.set_value("save1","scene",first_scene)
	save_file.set_value("save2","scene",first_scene)
	save_file.set_value("save3","scene",first_scene)
	save_file.save_encrypted_pass(Global.save_file,Global.save_key)

func _physics_process(delta) ->void:
	in_save_area = false
	for i in $AreaSave1.get_overlapping_areas():
		if i.has_method("_player"):
			save_index = 1
			in_save_area = true
			break
	for i in $AreaSave2.get_overlapping_areas():
		if i.has_method("_player"):
			save_index = 2
			in_save_area = true
			break
	for i in $AreaSave3.get_overlapping_areas():
		if i.has_method("_player"):
			save_index = 3
			in_save_area = true
			break
			
	# 删档
	if in_save_area:
		var del :bool = false
		if !mobile:
			del = Input.is_key_pressed(KEY_DELETE)
		else:
			var m_pos :Vector2 = get_viewport().get_mouse_position()
			var rect :Rect2 = Rect2(get_node("PipeEnterSave"+String(save_index)).position+Vector2(-32,32),64*Vector2.ONE)
			if rect.has_point(m_pos) && Input.is_mouse_button_pressed(BUTTON_LEFT):
				del = true
		if del:
			if !del_restrict:
				$DelStart.play()
				del_restrict = true
			timer += delta
			del_point_current = round(timer/del_time*del_point_total) as int
			if timer >= del_time:
				timer = 0
				delete_save(save_index)
		else:
			timer = 0
			del_restrict = false
			del_point_current = 0
	else:
		timer = 0
		del_restrict = false
		del_point_current = 0
	
	$Point.scale.x = del_point_current
	
	# 跳转
	for i in scene.current_player:
		if i.pipe == 5:
			for j in 3:
				if get_node("PipeEnterSave"+String(j+1)).player.has(i):
					for k in scene.current_player:
						k.fall_disabled = false
					Global.save = j+1
					var next_scene :PackedScene = save_file.get_value("save"+String(j+1),"scene",first_scene)
					if next_scene != null:
						scene.change_scene(save_file.get_value("save"+String(j+1),"scene",first_scene))
					return
	
func delete_save(index :int) ->void:
	$Delete.play()
	save_file.set_value("save"+String(index),"scene",first_scene)
	save_file.save_encrypted_pass(Global.save_file,Global.save_key)
