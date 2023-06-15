extends CanvasLayer

var win_tips = "CONGRATULATIONS!\nYOU WIN!"
var lose_tips = "GAME OVER!\nYOU SELECTED MINE!"

onready var title = $Control/CenterContainer/background/VBoxContainer/title
onready var mapsize = $Control/CenterContainer/background/VBoxContainer/mapsize
onready var mineratio = $Control/CenterContainer/background/VBoxContainer/mineratio
onready var timespent = $Control/CenterContainer/background/VBoxContainer/timespent

signal on_restart

func show_result(win:bool):
	
	var new_record = false
	var play_second = Autoload.play_time
	var best_score = Autoload.best_score
	if win and play_second < best_score:
		Autoload.best_score = play_second
		new_record = true
	
	var win_tips_copy = win_tips
	if new_record:
		win_tips_copy = win_tips + "\nNEW RECORD!"
	
	if win:
		title.text = win_tips_copy
	else:
		title.text = lose_tips
	
	var map_size = Autoload.map_size
	mapsize.text = "MAP SIZE: {x}x{y}".format({
		"x": int(map_size.x),
		"y": int(map_size.y),
	})
	
	var mine_size = Autoload.mine_size
	mineratio.text = "MINE RATIO: {value}%".format({
		"value": "%0.2f" % (mine_size / (map_size.x * map_size.y) * 100)
	})
	
	var t = _second_to_vector(play_second)
	timespent.text = "TIME SPENT: {m}:{s}".format({
		"m": "%02d" % int(t.x),
		"s": "%02d" % int(t.y),
	})
	
	show()

func _on_restart_button_up():
	self.visible = false
	emit_signal("on_restart")

func _second_to_vector(second:float) -> Vector2:
	var value = int(second)
	var ret = Vector2(floor(value/60), value%60)
	if ret.x > 59:
		ret.x = 59
		ret.y = 59
	return ret
