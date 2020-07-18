extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mode = 0
var _game = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	add_to_group('main')
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setMode(v):
	mode = v
	_game.showFlagMask(mode==1)
	if mode == 0 :
		get_node("Button").text = 'Clear Mode'
		return
	else:
		get_node("Button").text = 'Flag Mode'
		return
	pass
	
func isFlagMode():
	return mode == 1

func _on_Button_pressed():
	if _game == null:
		return
	setMode(1-mode)
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
	
	setMode(0)
	
	pass
	
func onGameOver():
	if _game.gameover:
		return
	var _class = preload("res://chunk/game_over.tscn")
	add_child(_class.instance())
	_game.gameover = true
	pass
	
func onGameWin():
	if _game.gameover:
		return
	var _class = preload("res://chunk/game_over.tscn")
	var view = _class.instance()
	view.setTips('You Win!')
	add_child(view)
	_game.gameover = true
	pass
	
func _makeKey(x, y):
	return String(int(x))+'-'+String(int(y))
	
var offset = [
	{"x": -1, "y": -1}, {"x": 0, "y": -1}, {"x": 1, "y": -1},
	{"x": -1, "y": 0},                     {"x": 1, "y": 0},
	{"x": -1, "y": 1}, {"x": 0, "y": 1}, {"x": 1, "y": 1},
]
	
func onNumberClick(pos):
	print('number', pos)
	var tile = _game.getTile(pos.x, pos.y)
	if tile != null:
		if tile.isNumberAndOpened() && isFlagMode():
			# 插旗模式 + 点击数字，进行自动扫雷
			var number = tile.getNumber()
			var count = 0
			var list = []
			for o in offset:
				var x = pos.x + o.x
				var y = pos.y + o.y
				var next = _game.getTile(x, y)
				if next == null:
					continue
				if next.isState(next.State.CLOSED):
					list.append(next)
					if next.isState(next.State.FLAG):
						count += 1
				pass
			if count == number:
				for n in list:
					if !n.isState(n.State.FLAG):
						n.setNumberOpened()
				pass
			return
		pass
	pass
	
func onTileOpen(pos):
	
	var flag1 = {}
	var flag2 = {}
	var list1 = [] #检查列表
	var list2 = [] #目标列表
	
	list1.append(pos)
	
	while !list1.empty():
		
		list2.push_back( list1.back() )
		list1.pop_back()
		
		var curr = list2.back()
		
		flag1[_makeKey(curr.x, curr.y)] = false
		flag2[_makeKey(curr.x, curr.y)] = true
		
		var currTile = _game.getTile(curr.x, curr.y)
		if currTile.getType() == currTile.Type.NONE:
			# 不是雷就把周围一圈加入list1
			for o in offset:
				var x = curr.x + o.x
				var y = curr.y + o.y
				var nextTile = _game.getTile(x, y)
				if nextTile != null && nextTile.isState(nextTile.State.CLOSED) && !flag1.get(_makeKey(x, y), false) && !flag2.get(_makeKey(x, y), false):
					# 坐标块有效并且没有被记录，加入待检查列表
					list1.push_back(Vector2(x, y))
					flag1[_makeKey(x, y)] = true
					pass
				pass
		pass
		
	# 得到块列表，把符合条件的块统统打开
	for v in list2:
		var tile = _game.getTile(v.x, v.y)
		if tile.getType() != tile.Type.BOMB:
			tile.setOpened()
			pass
	
	pass
	
func onTileClosed2Opened(pos):
	_game.subClosedTile(pos)
	pass
	
func onError(msg):
	var label = get_node("error-label")
	label.text = msg
	label.set_visible(true)
	pass
