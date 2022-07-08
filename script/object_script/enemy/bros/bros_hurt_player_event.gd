extends Node

export var method :String = "boom"

func _on_Hurt_player_hurt():
	get_parent().call(method)
