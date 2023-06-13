extends Node2D

onready var ground_layer = $Background
onready var item_layer = $ItemLayer
onready var top_layer = $TopLayer
onready var flag_layer = $FlagLayer
onready var mistake_layer = $MistakeLayer
onready var camera2d = $Camera2D
onready var result_layer = $CanvasLayer/CenterContainer
onready var play_time_label = $CanvasLayer/ColorRect/HBoxContainer2/play_time
onready var mine_size_label = $CanvasLayer/ColorRect/HBoxContainer/mine_size

var map_size:Vector2
var mine_size:int
var map_border:Rect2
var select_point = Vector2(-1, -1)
var mine_list = []
var first_open = true
var mouse_pressed = false
var play_second = 0.0

var win_tips = "CONGRATULATIONS!\nYOU WIN!"
var lose_tips = "GAME OVER!\nYOU SELECTED MINE!"
var best_score = 65535

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
	_testBuild()

func _testBuild():
	build_map(Vector2(10, 10), 10)

func build_map(mapSize:Vector2, mineSize:int):
	
	set_process_input(true)
	set_process(true)
	
	first_open = true
	map_size = mapSize
	mine_size = mineSize
	map_border = Rect2(Vector2.ZERO, mapSize)
	play_second = 0.0
	
	ground_layer.clear()
	item_layer.clear()
	top_layer.clear()
	flag_layer.clear()
	mistake_layer.clear()
	mine_list.clear()
	result_layer.visible = false
	
	var points = []
	
	for y in mapSize.y:
		for x in mapSize.x:
			var point = Vector2(x, y)
			ground_layer.set_cellv(point, 0)
			top_layer.set_cellv(point, 0)
			points.push_back(point)
	
	points.shuffle()
	
	#print("地雷个数", mineSize)
	#print("地图块数", points.size())
	
	var mineCount = 0
	for i in mineSize:
		var point = points[i]
		mine_list.push_back(point)
		item_layer.set_cellv(point, MINE_ID)
		mineCount += 1
	
	#print("实际地雷个数", mineCount)
	
	for point in mine_list:
		_proc_mine_number(point)
	
	_update_mine_size()
	
	var view_size = map_size * 32
	var camera_position = view_size * 0.5
	camera_position.y = view_size.y * 0.4
	camera2d.position = camera_position

func _proc_mine_number(point:Vector2):
	for p in offsets_8:
		var next = point + p
		if !map_border.has_point(next):
			continue
		if !_is_empty_tile(item_layer.get_cellv(next)):
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

func _first_open_tile(point:Vector2):
	# 把当前地雷移走
	var mine_index = mine_list.find(point)
	mine_list.remove(mine_index)
	item_layer.set_cellv(point, -1)
	# 记录可以放置地雷的位置
	var empty_list = []
	for y in map_size.y:
		for x in map_size.x:
			var e_point = Vector2(x, y)
			var id = item_layer.get_cellv(e_point)
			if !_is_mine_tile(id):
				empty_list.push_back(e_point)
	if empty_list.empty():
		print("没有找到空缺位置放置地雷.")
		return
	empty_list.shuffle()
	var mine_point = empty_list.back()
	mine_list.push_back(mine_point)
	
	item_layer.clear()
	
	for m_point in mine_list:
		item_layer.set_cellv(m_point, MINE_ID)
	for point in mine_list:
		_proc_mine_number(point)
	
	_update_mine_size()

func _auto_open_tile(point:Vector2):
	var current_mine_size = item_layer.get_cellv(point) + 1
	var flag_count = 0
	for offset in offsets_8:
		var next = point + offset
		if _is_flag_tile(flag_layer.get_cellv(next)):
			flag_count += 1
	if flag_count == current_mine_size:
		# 把周围未打开块打开
		var check = false
		var game_over = false
		for offset in offsets_8:
			var next = point + offset
			if !map_border.has_point(next):
				continue
			elif _is_flag_tile(flag_layer.get_cellv(next)):
				continue
			elif _is_empty_tile(top_layer.get_cellv(next)):
				continue
			check = true
			top_layer.set_cellv(next, -1)
			var item_id = item_layer.get_cellv(next)
			if _is_mine_tile(item_id):
				game_over = true
			if _is_empty_tile(item_id):
				_open_tile(next)
		if check and _check_win():
			_proc_win()
		elif game_over:
			_proc_game_over()
			
			for offset in offsets_8:
				var next = point + offset
				if !map_border.has_point(next):
					continue
				if _is_flag_tile(flag_layer.get_cellv(next)) and !_is_mine_tile(item_layer.get_cellv(next)):
					mistake_layer.set_cellv(next, 0)

func _open_tile(point:Vector2):
	
	if first_open and point in mine_list:
		first_open = false
		_first_open_tile(point)
		_open_tile(point)
		print("处理第一步点中地雷")
		return
	
	first_open = false
	
	var id = item_layer.get_cellv(point)
	if _is_mine_tile(id):
		# 游戏结束
		_proc_game_over()
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

func _is_flag_tile(id:int):
	return id == 0

func _check_win():
	var closed_tiles = top_layer.get_used_cells()
	if closed_tiles.size() != mine_list.size():
		return false
	for point in mine_list:
		if not (point in closed_tiles):
			return false
	return true

func _proc_win():
	print("win.")
	set_process_input(false)
	set_process(false)
	_set_tips(true)

func _proc_game_over():
	print("game over.")
	set_process_input(false)
	set_process(false)
	_set_tips(false)

func _set_tips(win:bool):
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	result_layer.visible = true
	
	var new_record = false
	if win and play_second < best_score:
		best_score = play_second
		new_record = true
	
	var win_tips_copy = win_tips
	if new_record:
		win_tips_copy = win_tips + "\nNEW RECORD!"
	
	if win:
		$CanvasLayer/CenterContainer/background/VBoxContainer/title.text = win_tips_copy
	else:
		$CanvasLayer/CenterContainer/background/VBoxContainer/title.text = lose_tips
	
	$CanvasLayer/CenterContainer/background/VBoxContainer/mapsize.text = "MAP SIZE: {x}x{y}".format({
		"x": int(map_size.x),
		"y": int(map_size.y),
	})
	
	$CanvasLayer/CenterContainer/background/VBoxContainer/mineratio.text = "MINE RATIO: {value}%".format({
		"value": "%0.2f" % (mine_list.size() / (map_size.x * map_size.y) * 100)
	})
	
	var t = _second_to_vector(best_score)
	$CanvasLayer/ColorRect/HBoxContainer2/best_score.text = "{m}:{s}".format({
		"m": "%02d" % int(t.x),
		"s": "%02d" % int(t.y),
	})
	
	t = _second_to_vector(play_second)
	$CanvasLayer/CenterContainer/background/VBoxContainer/timespent.text = "TIME SPENT: {m}:{s}".format({
		"m": "%02d" % int(t.x),
		"s": "%02d" % int(t.y),
	})

func _check_point_invalid(point:Vector2):
	var invalid = !map_border.has_point(point)
	if invalid:
		print("无效坐标")
	return invalid

func _process(delta):
	play_second += delta
	_update_play_time()

func _update_play_time():
	var t = _second_to_vector(play_second)
	play_time_label.text = "{m}:{s}".format({
		"m": "%02d" % int(t.x),
		"s": "%02d" % int(t.y),
	})

func _update_mine_size():
	var count = 0
	for point in mine_list:
		if _is_flag_tile(flag_layer.get_cellv(point)):
			count += 1
	var value = mine_list.size() - count
	if value <= 0:
		value = 0
	mine_size_label.text = "{size}".format({
		"size": "%02d" % value
	})

func _second_to_vector(second:float) -> Vector2:
	var value = int(second)
	var ret = Vector2(floor(value/60), value%60)
	if ret.x > 59:
		ret.x = 59
		ret.y = 59
	return ret

func _input(event):
	var mouse = event as InputEventMouseButton
	if mouse:
		var mouse_position = camera2d.to_actual_position(mouse.position)
		if mouse.button_index == BUTTON_RIGHT and mouse.pressed:
			var point = (mouse_position / 32).floor()
			if map_border.has_point(point) and !_is_empty_tile(top_layer.get_cellv(point)):
				if _is_flag_tile(flag_layer.get_cellv(point)):
					flag_layer.set_cellv(point, -1)
				else:
					flag_layer.set_cellv(point, 0)
				_update_mine_size()
			return
		if mouse.button_index == BUTTON_LEFT:
			var point = (mouse_position / 32).floor()
			if mouse.pressed:
				select_point = Vector2(-1, -1)
				if !map_border.has_point(point):
					return
				mouse_pressed = true
				if _is_empty_tile(top_layer.get_cellv(point)):
					if _is_number_tile(item_layer.get_cellv(point)):
						_auto_open_tile(point)
					return
				if _is_flag_tile(flag_layer.get_cellv(point)):
					return
				top_layer.set_cellv(point, 1)
				select_point = point
			else:
				var new_point = (mouse_position / 32).floor()
				var valid_select_point = map_border.has_point(select_point)
				mouse_pressed = false
				if new_point != select_point and valid_select_point:
					top_layer.set_cellv(select_point, 0)
					return
				if valid_select_point:
					top_layer.set_cellv(select_point, -1)
					_open_tile(select_point)
					if _check_win():
						_proc_win()
			return
		if mouse.button_index == BUTTON_MIDDLE and mouse.pressed:
			var point = (mouse_position / 32).floor()
			if map_border.has_point(point):
				top_layer.set_cellv(point, 0)

		return
	
	var mouse_motion = event as InputEventMouseMotion
	if mouse_motion and mouse_pressed:
		if mouse_motion.relative.length() > 1 * camera2d.zoom.x:
			camera2d.position -= mouse_motion.relative * camera2d.zoom
		if mouse_motion.relative.length() > 4 * camera2d.zoom.x:
			var valid_select_point = map_border.has_point(select_point)
			if valid_select_point and top_layer.get_cellv(select_point) == 1:
				top_layer.set_cellv(select_point, 0)
			select_point = Vector2(-1, -1)

func _on_TextureButton_button_up():
	_testBuild()

func _on_restart_button_down():
	_testBuild()
