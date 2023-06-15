extends CanvasLayer

onready var pc_window = $PcInfoBox/CenterContainer/WindowDialog
onready var pc_box = $PcInfoBox

onready var vita_window = $VitaInfoBox/CenterContainer/WindowDialog
onready var vita_box = $VitaInfoBox

signal on_hide

func show():
	self.visible = true
	if Autoload.is_vita_platform:
		vita_window.popup()
		vita_box.visible = true
	else:
		pc_window.popup()
		pc_box.visible = true

func _on_WindowDialog_popup_hide():
	self.visible = false
	pc_box.visible = false
	vita_box.visible = false
	emit_signal("on_hide")

func _on_Close_button_up():
	self.visible = false
	pc_window.visible = false
	pc_box.visible = false
	vita_window.visible = false
	vita_box.visible = false
	emit_signal("on_hide")
