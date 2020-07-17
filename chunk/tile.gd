extends Control

var bomb = false
var number = 0
var pos = Vector2(0, 0)
var _state = State.NONE
var _showFlagMask = false

enum State {
	NONE,
	CLOSED = 0x1,
	CLOSEDNONE = 0x2,
	FLAG = 0x4,
	FLAGMASK = 0x8,
	FLAGMASKHIDDEN = 0x10,
	QUESTION = 0x20,
	OPENED = 0x100,
	RED = 0x200,
	BOMB = 0x400,
	MISFLAG = 0x800,
	NUMBER = 0x1000,
}

enum Type {
	NONE,
	BOMB,
	NUMBER,
}

func _ready():
	setDefault()
	setState(State.CLOSED)
	pass
	
func getType():
	if bomb:
		return Type.BOMB
	if number != 0:
		return Type.NUMBER
	return Type.NONE
	
func setClosedGroupShow(show):
	var _node = get_node("closed")
	var childs = _node.get_children()
	for c in childs:
		c.set_visible(show)
		pass
	_node.set_visible(show)
	pass
	
func setOpenedGroupShow(show):
	var _node = get_node("opened")
	var childs = _node.get_children()
	for c in childs:
		c.set_visible(show)
		pass
	_node.set_visible(show)
	pass

func setDefault():
	setClosedGroupShow(false)
	setOpenedGroupShow(false)
	pass
	
func swap(tile):
	var temp = {
		"bomb": bomb,
		"number": number,
		"pos": pos,
		"state": _state
	}
	bomb = tile.bomb
	number = tile.number
	pos = tile.pos
	_state = tile._state
	tile.bomb = temp.bomb
	tile.number = temp.number
	tile.pos = temp.pos
	tile._state = temp.state
	pass
	
func setForceOpened():
	if bomb:
		setState(State.OPENED|State.BOMB)
		get_tree().call_group('main', 'onGameOver')
		return
	if number != 0:
		setState(State.OPENED|State.NUMBER)
		return
	setState(State.OPENED)
	pass
	
func setOpened():
	if _state & State.OPENED:
		return
	if _state & State.FLAGMASK:
		setState(State.FLAG)
		return
	if _state & State.FLAG:
		if _showFlagMask:
			setState(State.QUESTION)
		return
	if _state & State.QUESTION:
		if _showFlagMask:
			setState(State.FLAGMASK)
		return
	setForceOpened()
	pass
	
func setBomb():
	bomb = true
	pass
	
func setNumber(n):
	if n <= 0 || n >= 9:
		return
	number = n
	pass

func getNumber():
	return number
	
func setPos(vec):
	pos = vec
	pass
	
func getPos():
	return pos
	
func showFlagMask(show):
	_showFlagMask = show
	if show:
		if _state & State.FLAG != 0 || _state & State.QUESTION:
			return
		setState(State.FLAGMASK)
	else:
		if _state & State.FLAGMASK == 0:
			return
		setState(State.FLAGMASKHIDDEN)
	pass
	
func setState(state):
	if state & State.FLAG != 0:
		setClosedGroupShow(false)
		get_node("closed").set_visible(true)
		get_node("closed/flag").set_visible(true)
		_state = State.CLOSED | State.FLAG
		pass
	if state & State.FLAGMASK != 0:
		setClosedGroupShow(false)
		get_node("closed").set_visible(true)
		get_node("closed/flag-mask").set_visible(true)
		_state = State.CLOSED | State.FLAGMASK
		pass
	if state & State.FLAGMASKHIDDEN != 0:
		setClosedGroupShow(false)
		get_node("closed").set_visible(true)
		get_node("closed/flag-mask").set_visible(false)
		_state = State.CLOSED
		pass
	if state & State.QUESTION != 0:
		setClosedGroupShow(false)
		get_node("closed").set_visible(true)
		get_node("closed/question").set_visible(true)
		_state = State.CLOSED | State.QUESTION
		pass
	if state & State.CLOSEDNONE != 0:
		setClosedGroupShow(false)
		get_node("closed").set_visible(true)
		_state = State.CLOSED
		pass
	if state & State.CLOSED != 0:
		setOpenedGroupShow(false)
		get_node("closed").set_visible(true)
		_state |= State.CLOSED
		return
	if state & State.OPENED != 0:
		setClosedGroupShow(false)
		get_node("opened").set_visible(true)
		_state |= State.OPENED
		pass
	if state & State.RED != 0 || state & State.BOMB != 0:
		setDefault()
		get_node("opened").set_visible(true)
		get_node("opened/exploded").set_visible(true)
		get_node("opened/bomb").set_visible(true)
		_state |= State.RED | state & State.BOMB
		return
	if state & State.MISFLAG != 0:
		setDefault()
		get_node("opened").set_visible(true)
		get_node("opened/bomb").set_visible(true)
		get_node("opened/misflagged").set_visible(true)
		_state |= State.MISFLAG
		return
	if state & State.NUMBER != 0:
		get_node("opened/"+String(number)).set_visible(true)
		_state |= State.NUMBER
		pass
	pass
