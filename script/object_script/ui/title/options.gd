extends Control

signal options_back

var left_restrict :bool = false
var right_restrict :bool = false
var key_setting :bool = false
var key_restrict :bool = false

const volume_step :int = 5

export var file_name :String = "user://setting.ini"

onready var setting_file :ConfigFile = ConfigFile.new()
onready var os_name :String = OS.get_name()

func _ready() ->void:
	setting_init()
	
func setting_init() ->void:
	var file :File = File.new()
	if file.file_exists(file_name):
		var err = setting_file.load(file_name)
		if err == OK:
			setting_apply()
		return
	setting_file.set_value("setting","music",100)
	setting_file.set_value("setting","sound",100)
	setting_file.set_value("setting","full_screen",false)
	setting_file.set_value("setting","fps",60)
	match os_name:
		"Windows", "UWP" ,"macOS", "Linux":
			setting_file.set_value("control","up",Berry.get_input_event_key("ui_up"))
			setting_file.set_value("control","down",Berry.get_input_event_key("ui_down"))
			setting_file.set_value("control","left",Berry.get_input_event_key("ui_left"))
			setting_file.set_value("control","right",Berry.get_input_event_key("ui_right"))
			setting_file.set_value("control","jump",Berry.get_input_event_key("ui_jump"))
			setting_file.set_value("control","fire",Berry.get_input_event_key("ui_fire"))
			setting_file.set_value("control","pause",Berry.get_input_event_key("ui_pause"))
		"Android", "iOS":
			pass
	setting_file.save(file_name)
	
func setting_update() ->void:
	setting_file.set_value("setting","music",$OptionsMenu/Music/HSlider.value)
	setting_file.set_value("setting","sound",$OptionsMenu/Sound/HSlider.value)
	setting_file.set_value("setting","full_screen",$OptionsMenu/FullScreen/Switch.text == "ON")
	setting_file.set_value("setting","fps",int($OptionsMenu/FPS/Number.text))
	match os_name:
		"Windows", "UWP" ,"macOS", "Linux":
			setting_file.set_value("control","up",Berry.get_input_event_key("ui_up"))
			setting_file.set_value("control","down",Berry.get_input_event_key("ui_down"))
			setting_file.set_value("control","left",Berry.get_input_event_key("ui_left"))
			setting_file.set_value("control","right",Berry.get_input_event_key("ui_right"))
			setting_file.set_value("control","jump",Berry.get_input_event_key("ui_jump"))
			setting_file.set_value("control","fire",Berry.get_input_event_key("ui_fire"))
			setting_file.set_value("control","pause",Berry.get_input_event_key("ui_pause"))
		"Android", "iOS":
			pass
	setting_file.save(file_name)

func setting_apply() ->void:
	var music :int = setting_file.get_value("setting","music",100)
	var sound :int = setting_file.get_value("setting","sound",100)
	$OptionsMenu/Music/HSlider.value = music
	$OptionsMenu/Sound/HSlider.value = sound
	var music_bus :int = AudioServer.get_bus_index("Music")
	var sound_bus :int = AudioServer.get_bus_index("Sound")
	AudioServer.set_bus_volume_db(music_bus,clamp(10*log(music/100.0)/log(10),-80,0))
	AudioServer.set_bus_volume_db(sound_bus,clamp(10*log(sound/100.0)/log(10),-80,0))
	var full_screen :bool = setting_file.get_value("setting","full_screen",false)
	if full_screen:
		$OptionsMenu/FullScreen/Switch.text = "ON"
	else:
		$OptionsMenu/FullScreen/Switch.text = "OFF"
	OS.window_fullscreen = full_screen
	var fps :int = clamp(setting_file.get_value("setting","fps",60),60,120) as int
	$OptionsMenu/FPS/Number.text = String(fps)
	Engine.iterations_per_second = fps
	match os_name:
		"Windows", "UWP" ,"macOS", "Linux":
			set_input_event_key("ui_up",setting_file.get_value("control","up",Berry.get_input_event_key("ui_up")))
			set_input_event_key("ui_down",setting_file.get_value("control","down",Berry.get_input_event_key("ui_down")))
			set_input_event_key("ui_left",setting_file.get_value("control","left",Berry.get_input_event_key("ui_left")))
			set_input_event_key("ui_right",setting_file.get_value("control","right",Berry.get_input_event_key("ui_right")))
			set_input_event_key("ui_jump",setting_file.get_value("control","jump",Berry.get_input_event_key("ui_jump")))
			set_input_event_key("ui_fire",setting_file.get_value("control","fire",Berry.get_input_event_key("ui_fire")))
			set_input_event_key("ui_pause",setting_file.get_value("control","pause",Berry.get_input_event_key("ui_pause")))
			for i in $ControlsMenu/MenuSelect.item:
				if i.has_node("Key"):
					i.get_node("Key").update_key()
		"Android", "iOS":
			pass
			
func set_input_event_key(action :String, new_event_key :InputEventKey) ->void:
	InputMap.action_erase_event(action,Berry.get_input_event_key(action))
	InputMap.action_add_event(action,new_event_key)
			
func set_fps(dir :int = 1) ->void:
	var number :Label = $OptionsMenu/FPS/Number
	if dir > 0:
		if number.text == "60":
			number.text = "90"
		elif number.text == "90":
			number.text = "120"
		else:
			number.text = "60"
	else:
		if number.text == "60":
			number.text = "120"
		elif number.text == "90":
			number.text = "60"
		else:
			number.text = "90"
			
func get_input() ->int:
	var input :int = (Input.is_action_just_pressed("ui_right") as int) - (Input.is_action_just_pressed("ui_left") as int)
	if input != 0:
		right_restrict = Input.is_action_pressed("ui_right")
		left_restrict = Input.is_action_pressed("ui_left")
	else:
		var right :bool = false
		var left :bool = false
		if Input.is_key_pressed(KEY_RIGHT):
			if !right_restrict:
				right_restrict = true
				right = true
		else:
			right_restrict = false
		if Input.is_key_pressed(KEY_LEFT):
			if !left_restrict:
				left_restrict = true
				left = true
		else:
			left_restrict = false
		input = (right as int) - (left as int)
	return input
	
func _process(_delta) ->void:
	if $OptionsMenu.visible:
		match $OptionsMenu/MenuSelect.current:
			0:
				$OptionsMenu/Music/HSlider.value += volume_step*get_input()
			1:
				$OptionsMenu/Sound/HSlider.value += volume_step*get_input()
			2:
				var input :int = get_input()
				if $OptionsMenu/FullScreen/Switch.text == "OFF":
					if input == 1:
						$OptionsMenu/FullScreen/Switch.text = "ON"
				elif input == -1:
					$OptionsMenu/FullScreen/Switch.text = "OFF"
				if input != 0:
					Audio.play($Switch)
					setting_update()
					setting_apply()
			3:
				var input :int = get_input()
				if input != 0:
					Audio.play($Switch)
					set_fps(input)
					setting_update()
					setting_apply()
					
func _unhandled_input(event :InputEvent) ->void:
	if key_setting:
		if !key_restrict:
			key_restrict = true
			return
		elif event is InputEventKey:
			var menu :Sprite = $ControlsMenu/MenuSelect
			var key :Label = menu.item[menu.current].get_node("Key")
			set_input_event_key(key.action,event)
			setting_update()
			setting_apply()
			key.wait = false
			key_setting = false
			key_restrict = false
			$ControlsMenu/MenuSelect.disable = false
			$Apply.play()
	
func _on_option_selected(index :int) ->void:
	match index:
		2:
			if $OptionsMenu/FullScreen/Switch.text == "ON":
				$OptionsMenu/FullScreen/Switch.text = "OFF"
			else:
				$OptionsMenu/FullScreen/Switch.text = "ON"
			Audio.play($Switch)
			setting_update()
			setting_apply()
		3:
			set_fps()
			Audio.play($Switch)
			setting_update()
			setting_apply()
		4:
			$Apply.play()
			$OptionsMenu.visible = false
			$OptionsMenu/MenuSelect.disable = true
			match os_name:
				"Windows", "UWP" ,"macOS", "Linux":
					$ControlsMenu.visible = true
					$ControlsMenu/MenuSelect.current = 0
					$ControlsMenu/MenuSelect.set_item_alpha(0,true)
					$ControlsMenu/MenuSelect.disable = false
				"Android", "iOS":
					pass
		5:
			$Apply.play()
			$OptionsMenu/MenuSelect.disable = true
			emit_signal("options_back")

func _on_control_selected(index) ->void:
	$Apply.play()
	$ControlsMenu/MenuSelect.disable = true
	if index != 7:
		key_setting = true
		$ControlsMenu/MenuSelect.item[index].get_node("Key").wait = true
	else:
		$ControlsMenu.visible = false
		$OptionsMenu.visible = true
		$OptionsMenu/MenuSelect.disable = false

func _on_volume_changed(_value) ->void:
	setting_update()
	setting_apply()
