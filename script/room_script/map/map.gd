extends Room2D

export var next_scene :PackedScene = null
export var save_game :bool = true
export var camera_speed :float = 250

var mobile :bool = false

onready var save_file :ConfigFile = ConfigFile.new()

func _ready() ->void:
	room2d_ready()
	
	match OS.get_name():
		"Android", "iOS":
			mobile = true
			
	if save_game:
		var file :File = File.new()
		if file.file_exists(Global.save_file):
			var err = save_file.load_encrypted_pass(Global.save_file,Global.save_key)
			if err != OK:
				save_file = ConfigFile.new()
		save_file.set_value("save"+String(Global.save),"scene",manager.current_scene)
		save_file.save_encrypted_pass(Global.save_file,Global.save_key)
