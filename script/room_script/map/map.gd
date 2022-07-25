extends Room2D

export var next_scene :PackedScene = null
export var save_game :bool = true
export var camera_speed :float = 250

var player_finish :bool = false
var change :bool = false
var mobile :bool = false
var mobile_input :bool = false

onready var save_file :ConfigFile = ConfigFile.new()
onready var view :Node = Berry.get_view(self)

func _ready() ->void:
	room2d_ready()
	
	match OS.get_name():
		"Android", "iOS":
			mobile = true

	if mobile:
		$TipsLayer/Tips/Label.text = "TOUCH TO START"
	else:
		$UILayer/TouchButton.queue_free()
		
	if save_game:
		var file :File = File.new()
		if file.file_exists(Global.save_file):
			var err = save_file.load_encrypted_pass(Global.save_file,Global.save_key)
			if err != OK:
				save_file = ConfigFile.new()
		save_file.set_value("save"+String(Global.save),"scene",manager.current_scene)
		save_file.save_encrypted_pass(Global.save_file,Global.save_key)

func _input(event :InputEvent) ->void:
	if !mobile || !player_finish:
		return
	if Input.is_action_pressed("ui_right") || Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_up") || Input.is_action_pressed("ui_down"):
		return
	if event is InputEventScreenTouch && event.is_pressed():
		mobile_input = true

func _physics_process(delta) ->void:
	if !player_finish:
		if !change:
			$Camera.global_position = $Player.global_position
	else:
		var h :int = (Input.is_action_pressed("ui_right") as int) - (Input.is_action_pressed("ui_left") as int)
		var v :int = (Input.is_action_pressed("ui_down") as int) - (Input.is_action_pressed("ui_up") as int)
		var dir :Vector2 = Vector2(h,v).normalized()
		$Camera.force_center()
		$Camera.position += camera_speed*dir * delta
		
		if mobile:
			$UILayer/TouchButton/Left.visible = view.current_border.size.x != view.current_limit.size.x
			$UILayer/TouchButton/Right.visible = view.current_border.size.x != view.current_limit.size.x
			$UILayer/TouchButton/Up.visible = view.current_border.size.y != view.current_limit.size.y
			$UILayer/TouchButton/Down.visible = view.current_border.size.y != view.current_limit.size.y
		
		if Input.is_action_just_pressed("ui_jump") || mobile_input:
			player_finish = false
			change = true
			if next_scene != null:
				$Fade.play()
				manager.in_circle_speed = 250
				manager.in_circle_wait_time = 0.5
				manager.change_scene(next_scene,manager.TRANS.CIRCLE)
	
func _on_Player_player_finish():
	player_finish = true
	$TipsLayer/Tips/Label.disabled = false
	if save_game:
		$UILayer/Save/GameSaved.visible = true
		$Save.play()
