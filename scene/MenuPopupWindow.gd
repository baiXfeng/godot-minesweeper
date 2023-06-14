extends CanvasLayer

onready var menu_dialog = $Control/CenterContainer/MenuDialog

signal on_restart
signal on_hide

func show():
	self.visible = true
	menu_dialog.popup()

func _on_Restart_button_up():
	var width = $Control/CenterContainer/MenuDialog/VBoxContainer/HBoxContainer/TextEdit.text.to_int()
	var height = $Control/CenterContainer/MenuDialog/VBoxContainer/HBoxContainer2/TextEdit.text.to_int()
	var mine_count = $Control/CenterContainer/MenuDialog/VBoxContainer/HBoxContainer3/TextEdit.text.to_int()	
	emit_signal("on_restart", Vector2(width, height), mine_count)
	menu_dialog.visible = false
	self.visible = false

func _on_MenuDialog_popup_hide():
	self.visible = false
	emit_signal("on_hide")
