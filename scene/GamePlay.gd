extends Node

onready var ground_layer = $Background
onready var item_layer = $ItemLayer
onready var top_layer = $TopLayer

var map_size:Vector2
var mine_size:int
var map_border:Rect2
var select_point = Vector2(-1, -1)
var mine_list = []

const MINE_ID = 8

const offsets_8 = [
	Vector2(-1, -1),
	Vector2(0, -1),
	Vector2(1, -1),
	Vector2(-1, 0),
	Vector2(1, 0),
	Vector2(-1, 1),
	Vector2(0, 1),
	Vector2(1, 1),
]
const offsets_4 = [
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
]

func _ready():
	randomize()
	build_map(Vector2(20, 15), 15)

func build_map(mapSize:Vector2, mineSize:int):
	
	map_size = mapSize
	mine_size = mineSize
	map_border = Rect2(Vector2.ZERO, mapSize)
	
	ground_layer.clear()
	item_layer.clear()
	top_layer.clear()
	mine_list.clear()
	
	var points = []
	
	for y in mapSize.y:
		for x in mapSize.x:
			var point = Vector2(x, y)
			ground_layer.set_cellv(point, 0)
			top_layer.set_cell(x, y, 0)
			points.push_back(point)
	
	points.shuffle()
	
	print("地雷个数", mineSize)
	print("地图块数", points.size())
	
	var mineCount = 0
	for i in mineSize:
		var point = points[i]
		mine_list.push_back(point)
		item_layer.set_cellv(point, MINE_ID)
		mineCount += 1
	
	print("实际地雷个数", mineCount)
	
	for point in mine_list:
		#_proc_mine_number(point)
		pass
	

func _proc_mine_number(point:Vector2):
	for p in offsets_8:
		var next = point + p
		if !map_border.has_point(next):
			continue
		_fill_number(next)

func _fill_number(point:Vector2):
	var number = 0
	for p in offsets_8:
		var next = point + p
		if _is_mine_tile(item_layer.get_cellv(next)):
			number += 1
	if number >= 1:
		item_layer.set_cellv(point, number-1)

func _open_tile(point:Vector2):
	var id = item_layer.get_cellv(point)
	if _is_mine_tile(id):
		# 游戏结束
		print("game over.")
		return
	if _is_empty_tile(id):
		# 展开邻接的所有空白块
		_open_empty_tile(point)
		return
	for p in offsets_4:
		var next = point + p
		if !map_border.has_point(next):
			continue
		if _is_empty_tile(item_layer.get_cellv(next)):
			# 展开邻接的所有空白块
			_open_empty_tile(next)

func _open_empty_tile(point:Vector2):

	var check_list = [point]
	var closed_list = []
	
	while !check_list.empty():
		var current = check_list.pop_back()
		if _is_empty_tile(item_layer.get_cellv(current)):
			for p in offsets_8:
				var next = current + p
				if next in closed_list:
					continue
				if map_border.has_point(next):
					check_list.push_back(next)
		closed_list.push_back(current)
	for point in closed_list:
		top_layer.set_cellv(point, -1)

func _is_number_tile(id:int):
	return id >= 0 and id <= 7

func _is_empty_tile(id:int):
	return id == -1

func _is_mine_tile(id:int):
	return id == MINE_ID

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		for point in mine_list:
			_proc_mine_number(point)

func _input(event):
	var mouse = event as InputEventMouseButton
	if mouse:
		if mouse.button_index == BUTTON_RIGHT and mouse.pressed:
			build_map(Vector2(20, 15), 15)
			return
		if mouse.button_index == BUTTON_LEFT:
			var point = (mouse.position / 32).floor()
			if mouse.pressed:
				if !map_border.has_point(point):
					return
				if _is_empty_tile(top_layer.get_cellv(point)):
					return
				top_layer.set_cellv(point, 1)
				select_point = point
			else:
				var new_point = (mouse.position / 32).floor()
				if new_point != select_point:
					top_layer.set_cellv(select_point, 0)
					return
				top_layer.set_cellv(select_point, -1)
				_open_tile(select_point)
				select_point = Vector2(-1, -1)
			return
		if mouse.button_index == BUTTON_MIDDLE and mouse.pressed:
			var point = (mouse.position / 32).floor()
			top_layer.set_cellv(point, 0)
