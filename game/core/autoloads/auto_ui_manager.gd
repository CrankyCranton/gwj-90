extends CanvasLayer


enum STATE {OPENING_LAYER, CLOSING_LAYER, IDLE}
var state:STATE = STATE.IDLE

const UI_PATHS:Dictionary[StringName, StringName] = {
	&"MAIN_MENU" : &"uid://bliwa2rxl56ll",
	&"GAMEPLAY_HUD" : &"uid://p588hdnemxov"}


@onready var root:Control = %Root
@onready var debug: Control = %DEBUG

var open_layers:Array[UI_Layer] = []
var top_layer:UI_Layer = null

var is_closing:bool = false


func _ready() -> void:
	_connect_bus_signals()


func _connect_bus_signals() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_01"):
		debug.visible = !debug.visible


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		is_closing = true

## Call with await.
func open_new_layer(layer_key:StringName, layer_specific_data:Dictionary = {}) -> void:
	if is_layer_open(layer_key) == true:
		printerr("Tried to open <%s> when it as already open, returning." %[layer_key])
		return
	if state != STATE.IDLE:
		printerr("UI called to open <%s> while busy, returning." %[layer_key])
		return
	
	assert(UI_PATHS.has(layer_key), "Incorrect layer key provided.")
	state = STATE.OPENING_LAYER
	
	var LOADED_UI:PackedScene = load(UI_PATHS.get(layer_key))
	var new_layer:UI_Layer = LOADED_UI.instantiate()
	new_layer.layer_opened.connect(_on_layer_opened)
	new_layer.layer_closing.connect(_on_layer_closing)
	new_layer.layer_closed.connect(_on_layer_closed)
	
	new_layer.name = layer_key
	new_layer.add_to_root(layer_specific_data)
	open_layers.append(new_layer)


func _on_layer_opened(opened_layer:UI_Layer) -> void:
	_add_layer_name_to_debug(opened_layer)
	state = STATE.IDLE


func _on_layer_closing(closing_layer:UI_Layer) -> void:
	state = STATE.CLOSING_LAYER
	open_layers.erase(closing_layer)


func _on_layer_closed(closed_layer:UI_Layer) -> void:
	if closed_layer.has_meta("label"):
		var l:Label = closed_layer.get_meta("label")
		l.queue_free()
	closed_layer.queue_free()
	state = STATE.IDLE

## Global helper function for whatever; used privately to prevent duplicate UI.
func is_layer_open(layer_id:StringName) -> bool:
	for open_layer:UI_Layer in open_layers:
		if open_layer.name == layer_id:
			return true
	return false


#region DEBUG STUFF
@onready var layer_debug_node: VBoxContainer = %LayerDebugNode
func _add_layer_name_to_debug(opened_layer:UI_Layer) -> void:
	var l:Label = Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	layer_debug_node.add_child(l)
	l.text = opened_layer.name + " - POS: " + str(open_layers.size())
	opened_layer.set_meta("label", l)


func _on_root_child_order_changed() -> void:
	if not is_closing:
		if root.get_child_count() == 0:
			return
		
		var x:int = 0
		for open_layer:UI_Layer in root.get_children():
			Input.mouse_mode = open_layer.mouse_mode
			
			if x == root.get_child_count() - 1:
				top_layer = open_layer
			
			if open_layer.has_meta("label"):
				var l:Label = open_layer.get_meta("label")
				l.text = open_layer.name + " - POS: " + str(x)
			
			x += 1

#endregion
