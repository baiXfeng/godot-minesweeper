extends CanvasLayer

onready var menu_dialog = $Control/CenterContainer/MenuDialog
onready var width_edit = $Control/CenterContainer/MenuDialog/VBoxContainer/HBoxContainer/TextEdit
onready var height_edit = $Control/CenterContainer/MenuDialog/VBoxContainer/HBoxContainer2/TextEdit
onready var mine_edit = $Control/CenterContainer/MenuDialog/VBoxContainer/HBoxContainer3/TextEdit

var current_textedit:TextEdit = null

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
	self.current_textedit = null

func _on_MenuDialog_popup_hide():
	self.visible = false
	self.current_textedit = null
	emit_signal("on_hide")

func _on_MapWidth_focus_entered():
	current_textedit = width_edit

func _on_MapHeight_focus_entered():
	current_textedit = height_edit

func _on_MineSize_focus_entered():
	current_textedit = mine_edit

func _process(delta):
	if current_textedit == null:
		return
	if Input.is_action_pressed("ui_right"):
		var value = current_textedit.text.to_int() + 1
		current_textedit.text = String(value)
	elif Input.is_action_pressed("ui_left"):
		var value = current_textedit.text.to_int() - 1
		if value <= 0:
			value = 0
		current_textedit.text = String(value)
	
	set_process(false)
	yield(get_tree().create_timer(0.1), "timeout")
	set_process(true)
