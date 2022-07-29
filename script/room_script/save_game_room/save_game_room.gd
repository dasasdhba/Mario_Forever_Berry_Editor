extends Room2D

export var shop_fade_speed :float = 1

var delay :int = 0
var shop_fade :bool = false
var mobile :bool = false

onready var view :Node = Berry.get_view(self)

func _ready() ->void:
	room2d_ready()
	
	match OS.get_name():
		"Android", "iOS":
			mobile = true
	
	if mobile:
		var new_text :String = $TextLayer/Text/DeleteTips.text.replace("'DEL'","pipe")
		$TextLayer/Text/DeleteTips.text = new_text
	
	# 重置数值
	manager.clear_data()
	Global.life = 4
	Global.score = 0
	Global.coin = 0
	for i in Player.get_children():
		i.reset()

func _physics_process(delta :float) ->void:
	for i in manager.current_player:
		# 掉崖重置
		var gdir :Vector2 = Berry.get_global_direction(i,i.gravity_direction)
		if !view.is_in_limit_direction(i.global_position,48*i.scale,gdir):
			i.control = false
			i.move = 0
			i.gravity = 0
			i.pipe = 5
			$PipeStart._pipe_exit(i)
			
	# 删档提示
	$TextLayer/Text/DeleteTips.down = $Save.in_save_area
	
	# 商店字体淡出
	if shop_fade:
		if has_node("TextLayer/Text/Shop"):
			$TextLayer/Text/Shop.modulate.a -= shop_fade_speed * delta
			if $TextLayer/Text/Shop.modulate.a <= 0:
				$TextLayer/Text/Shop.queue_free()

func _on_Shop_bonus_get(life :int):
	var life_text :Label = $TextLayer/Text/Life
	life_text.rect_position = manager.current_player.front().position - 16*Vector2.ONE
	life_text.origin_position = life_text.rect_position
	life_text.text = String(-life)
	life_text.disabled = false
	Global.life -= life
	shop_fade = true
