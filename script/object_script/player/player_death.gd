extends Sprite

var activate :bool = false
var jump :bool = false
export var gravity :float = -500
export var gravity_max :float = 500
export var accleration: float = 1000
export var stop_music :bool = true

onready var room: Room2D = Berry.get_room2d(self)
onready var scene :Node = room.manager if room != null else Scene

func _physics_process(delta):
	if !activate:
		return
	if !jump && $Timer.is_stopped():
		$AudioDeath.play()
		$Timer.start()
		if scene.get_player_num() > 0:
			if Global.life > 0:
				Global.life -= 1
		else:
			if stop_music:
				Audio.music_stop()
			if room != null:
				var hud: Control = room.hud
				if hud != null && hud.has_method("time_set_paused"):
					hud.time_set_paused(true)
			$TimerReset.start()
				
	if jump:
		gravity += accleration * delta
		if gravity > gravity_max:
			gravity = gravity_max
		position += gravity*Vector2.DOWN.rotated(rotation) * delta

func _on_Timer_timeout():
	jump = true
	if scene.get_player_num() == 0:
		$AudioDeathAll.play()

func _on_TimerReset_timeout():
	if Global.life <= 0:
		if room != null:
			var hud: Control = room.hud
			if hud != null && hud.has_node("GameOver"):
				hud.get_node("GameOver").activate()
				return
	Global.life -= 1
	scene.death_hint = true
	if scene.checkpoint_scene != null:
		scene.change_scene(scene.checkpoint_scene)
	else:
		scene.restart_scene()
