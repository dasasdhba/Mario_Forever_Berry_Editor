# 需要设置为敌人的子节点
extends AreaShared

export var enemy_turn :bool = true # 与其他敌人碰撞是否使其转向

var attacked :Array = [] # 待处理的攻击判定

func _ready() ->void:
	if get_shape_owners().empty():
		var parent: Node = get_parent()
		if parent is CollisionObject2D:
			inherit(parent)

# 攻击判定标识
func _enemy() ->void:
	pass

# 敌人互相碰撞转向标识
func _enemy_turn() ->bool:
	return enemy_turn
