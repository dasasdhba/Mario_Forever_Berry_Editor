extends AreaExact

onready var parent :Node = get_parent()

func _physics_process(_delta) ->void:
	if parent.star || parent.disable_deferred || parent.get_parent() == Player || parent.get_parent() == null:
		return
	for i in get_overlapping_areas():
		if i.has_node("Stomped"):
			var stomped :Node = i.get_node("Stomped")
			if stomped.has_method("stomp_detect"):
				stomped.stomp_detect(self)
