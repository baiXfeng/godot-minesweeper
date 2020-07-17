extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mode = 0
var _game = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group('main')
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_pressed():
	mode = 1 - mode
	if _game != null:
		_game.showFlagMask(mode==1)
		pass
	if mode == 0 :
		get_node("Button").text = 'Clear Mode'
		return
	else:
		get_node("Button").text = 'Flag Mode'
		return
	pass # Replace with function body.

func onGameStart(w, h, mine):
	if _game != null:
		remove_child(_game)
		_game.queue_free()
		_game = null
	var _class = preload("res://chunk/game.tscn")
	var game = _class.instance()
	game.start(w, h, mine)
	var box = get_node("GameBox")
	box.add_child(game)
	_game = game
	
	# 设置居中
	var size1 = box.get_size()
	var size2 = game.get_size()
	game.set_position(Vector2((size1.x-size2.x)*0.5, (size1.y-size2.y)*0.5))
	
	# 隐藏错误信息
	var label = get_node("error-label")
	label.set_visible(false)
	
	pass
	
func onError(msg):
	var label = get_node("error-label")
	label.text = msg
	label.set_visible(true)
	pass
