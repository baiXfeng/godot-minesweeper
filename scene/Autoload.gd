extends Node

var map_size = Vector2(12, 12)
var mine_size = 15
var best_score = 60 * 59 + 59
var play_time = 0.0

var is_vita_platform = OS.get_name() == "Vita"
