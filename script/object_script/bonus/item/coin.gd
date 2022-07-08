extends Area2D

export var coin_effect :PackedScene
export var coin :int = 1 # 金币数

func _ready() ->void:
	# 疑似 Godot 的 bug，这里手动连接 signal 以防止 debugger 报错
	if !is_connected("area_entered",self,"on_area_entered"):
		connect("area_entered",self,"on_area_entered")

# 标识该物件可装入问号砖，并作出顶后的反应
func _item(dir :Vector2 = Vector2.UP) ->void:
	var new :Node = coin_effect.instance()
	var parent :Node = get_parent()
	new.direction = dir
	new.position = parent.position + parent.height*parent.scale.y*dir
	new.scale = scale
	new.rotation = Vector2.UP.angle_to(dir)
	parent.get_parent().add_child(new)
	get_coin()

# 检查是否在问号砖中
func is_in_block() ->bool:
	return get_parent().has_method("_block")

func get_coin() ->void:
	Global.coin += coin
	Audio.play($AudioCoin)
	queue_free()

# 玩家获取金币
func on_area_entered(area :Area2D) ->void:
	if is_in_block():
		return
	if area.has_method("_player"):
		get_coin()
