extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var width = 10
var height = 12
var mine = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Control/SpinBox").value = width
	get_node("Control2/SpinBox").value = height
	get_node("Control3/SpinBox").value = mine
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
