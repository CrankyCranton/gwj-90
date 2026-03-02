class_name ButtonClickEmitter extends Node
## Add this as a child of the button you want to emit the signals on Bus.gd
## (can be added through the regular add node menu)


func _ready() -> void:
	assert(get_parent() is BaseButton, "Must be a child of a button.")
	var parent := get_parent() as BaseButton
	parent.mouse_entered.connect(Bus.button_hovered.emit.bind(parent))
	parent.pressed.connect(Bus.button_clicked.emit.bind(parent))
