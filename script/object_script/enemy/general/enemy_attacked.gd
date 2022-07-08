# 处理敌人攻击判定，需要设置父节点为 enemy_area
extends Node

# false: 响应并判定为有效攻击
# true: 响应(stomp,fireball,beet)并判定为无效攻击
# 不存在: 不响应
export var def_dict :Dictionary = {
	"stomp" : false,
	"fireball" : false,
	"beet" : false,
	"bump" : false,
	"shell" : false,
	"star" : false,
	"lava" : false
}
export var shell_attack :bool = false # 是否是龟壳
export var hardness :int = 0 # 用于龟壳攻击判定
export var stomp_overwrite: bool = false # 是否覆盖玩家踩敌人速度
export var stomp_bounce: float = 450
export var stomp_jump:float = 650
export var lava_sound_range :float = 128 # 碰岩浆死亡音效范围
export var one_shot :bool = true # 只判定一次
export var disabled :bool = false

var atk_count :int = 0 # 龟壳连击数

onready var parent :Area2D = get_parent()
onready var root: Node = parent.get_parent()

signal attacked(atk)

func def_process() ->void:
	var arr :Array = parent.attacked
	if disabled:
		arr.clear()
		return
	while !arr.empty():
		var atk: Array = arr.pop_back()
		if def_dict.has(atk[0]):
			if is_instance_valid(atk[1]):
				match atk[0]:
					"stomp": 
						if !stomp_overwrite:
							atk[1].player_stomp()
						else:
							atk[1].player_stomp(stomp_bounce,stomp_jump)
					"fireball":
						atk[1].boom()
					"beet":
						atk[1].bounce()
					"shell", "star":
						if !def_dict[atk[0]]:
							atk[1].atk_count += 1
							Audio.play(get_node("Kick"+String(atk[1].atk_count)))
							if atk[1].has_method("def_process") && atk[1].shell_attack == false:
								atk[1].atk_count = 0
							elif atk[1].atk_count >= 7:
								atk[1].atk_count = 0
								var l :Node = Lib.life.instance()
								l.position = root.position
								root.get_parent().add_child(l)
							else:
								var s :Node = Lib.score.instance()
								s.position = root.position
								match atk[1].atk_count:
									1:
										s.score = 100
									2:
										s.score = 200
									3:
										s.score = 500
									4:
										s.score = 1000
									5:
										s.score = 2000
									6:
										s.score = 5000
								root.get_parent().add_child(s)
			if !def_dict[atk[0]]:
				if atk[0] != "stomp" && atk[0] != "shell" && atk[0] != "star":
					if atk[0] == "lava":
						if View.is_in_view(root.position,lava_sound_range*root.scale):
							Audio.play($Kick1)
					else:
						Audio.play($Kick1)
				emit_signal("attacked",atk)
				if one_shot:
					disabled = true
					break
					
func _physics_process(_delta) ->void:
	if shell_attack:
		for i in parent.get_overlapping_areas():
			if i.has_method("_enemy"):
				if !i.has_node("Attacked"):
					break
				var atk: Node = i.get_node("Attacked")
				if atk.shell_attack:
					if hardness <= atk.hardness:
						parent.attacked.append(["shell",atk])
					if hardness >= atk.hardness:
						i.attacked.append(["shell",self])
				else:
					if hardness < atk.hardness:
						parent.attacked.append(["shell",atk])
					else:
						i.attacked.append(["shell",self])
	def_process()
