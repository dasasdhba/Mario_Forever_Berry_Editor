extends Label

var time: int
var warning :bool = false

export var amplitude :int = 5

onready var origin_position :Vector2 = rect_position
onready var rand :RandomNumberGenerator = Berry.get_rand(self)

func _ready() ->void:
	var parent: Node = get_parent()
	time = parent.level_time
	parent.timer = self
	if time <= 0:
		queue_free()

func _process(_delta) ->void:
	text = "TIME\n"+String(time)
	
func _physics_process(_delta) ->void:
	if warning && !$ShakeTimer.is_stopped():
		rect_position = origin_position + Vector2(rand.randi_range(-amplitude,amplitude),rand.randi_range(-amplitude,amplitude))

func _on_Timer_timeout() ->void:
	if time > 0:
		time -= 1
		if !warning && time < 100:
			$ShakeTimer.start()
			$Timeout.play()
			warning = true
		
		if time == 0:
			for i in Berry.get_scene(self).current_player:
				i.player_death(true)

func _on_ShakeTimer_timeout():
	rect_position = origin_position
