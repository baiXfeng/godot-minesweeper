extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const tileWidth = 108
const tileHeight = 108
var mapWidth = 0
var mapHeight = 0
var mineCount = 0
var tileMap = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#start(10, 10)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func start(w, h, mine):
	if mine >= w*h:
		mine = w*h
	var _map = []
	for j in range(h):
		_map.append([])
		for i in range(w):
			var _class = preload("res://chunk/tile.tscn")
			var tile = _class.instance()
			add_child(tile)
			tile.set_position(Vector2(i*tileWidth, j*tileHeight))
			tile.set_scale(Vector2(3.375, 3.375))
			tile.setPos(Vector2(i, j))
			_map[j].append(tile)
			pass
	set_size(Vector2(108*w, 108*h))
	mapWidth = w
	mapHeight = h
	mineCount = mine
	tileMap = _map
	pass

func showFlagMask(show):
	for y in range(mapHeight):
		for x in range(mapWidth):
			var tile = getTile(x, y)
			if tile != null:
				if show:
					tile.setState(tile.State.FLAGMASK)
				else:
					tile.setState(tile.State.FLAGMASKHIDDEN)
			pass
	pass

func getTile(x, y):
	if x < 0 || x >= mapWidth:
		return null
	if y < 0 || y >= mapHeight:
		return null
	return tileMap[y][x]
	
func computeMove(pos, size0, size1):
	# size0 - self
	# size1 - parent
	
	if size0.x < size1.x:
		if pos.x <= 0:
			pos.x = 0
		elif pos.x + size0.x >= size1.x:
			pos.x = size1.x - size0.x
		pass
	elif size0.x > size1.x:
		if pos.x >= 0:
			pos.x = 0
		elif pos.x <= size1.x - size0.x:
			pos.x = size1.x - size0.x
		pass
	
	if size0.y < size1.y:
		if pos.y <= 0:
			pos.y = 0
		elif pos.y + size0.y >= size1.y:
			pos.y = size1.y - size0.y
		pass
	elif size0.y > size1.y:
		if pos.y >= 0:
			pos.y = 0
		elif pos.y <= size1.y - size0.y:
			pos.y = size1.y - size0.y
		pass
	
	return pos
	
var tileX = -1
var tileY = -1
	
func onMouseDown(event):
	var pos = event.position
	tileX = int(pos.x / tileWidth)
	tileY = int(pos.y / tileHeight)
	#print(pos, '\t', tileX, '\t', tileY)
	pass
	
func onMouseMoved(event):
	var parentSize = get_parent().get_size()
	var selfSize = get_size()
	if selfSize.x < parentSize.x && selfSize.y < parentSize.y:
		return
	var v = event.relative
	var old_pos = get_position()
	var new_pos = Vector2(old_pos.x+v.x, old_pos.y+v.y)
	set_position(computeMove(new_pos, selfSize, parentSize))
	tileX = -1
	tileY = -1
	pass
	
func onMouseUp(event):
	if tileX >= 0 && tileY >= 0:
		var tile = getTile(tileX, tileY)
		if tile != null:
			tile.setOpened()
		return
	pass


var pressed = false
func _on_Control_gui_input(event):
	if event.button_mask != 0:
		if pressed:
			onMouseMoved(event)
			return
		if event.pressed:
			pressed = true
			onMouseDown(event)
			return
	else:
		if pressed:
			pressed = false
			onMouseUp(event)
			pass
		return
	pass # Replace with function body.
