extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var width = 2
var height = 2
var mine = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Width_value_changed(value):
	width = value
	pass # Replace with function body.


func _on_Height_value_changed(value):
	height = value
	pass # Replace with function body.


func _on_Mine_value_changed(value):
	mine = value
	pass # Replace with function body.


func _on_GameStart_pressed():
	get_tree().call_group('main', 'onGameStart', width, height, mine)
	pass # Replace with function body.
