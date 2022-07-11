tool
extends Sprite

func _physics_process(_delta) ->void:
	if !Engine.editor_hint:
		return
	var p :Node = get_parent()
	$Color.visible = p.type != p.TYPE.BODY
	if p.type == p.TYPE.HEAD:
		$Color.color = Color(1,0,0,0.2)
	else:
		$Color.color = Color(0,0,1,0.2)
