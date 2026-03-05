extends UI_Layer

@onready var intro_anims: AnimationPlayer = %IntroAnims
@onready var rule_page: TextureRect = %RulePage
@onready var rules_root: Control = %RulesRoot

@onready var prev_button: Button = %PreviousPage
@onready var next_button: Button = %NextPage

# Explicitly typed Array of Textures
@onready var _pages: Array[Texture2D] = [
	preload("uid://hcm8iubp5lbp"),
	preload("uid://4jihytsijmff"),
	preload("uid://8kyay22anjqc"),
	preload("uid://2rgf6d4sp5f4"),
	preload("uid://c00spe132f4m5"),
	preload("uid://pklwik2u7euy"),
	preload("uid://c460vmhn61lx4"),
	preload("uid://y6a2m2pki31g"),
	preload("uid://4m18pijyiekc")
]

var _current_page_index: int = 0

const MAP = preload("uid://rqfjuu0k5g1k")

func _ready() -> void:
	intro_anims.play("intro_01_title_in")
	rules_root.visible = false

func _on_rules_pressed() -> void:
	_current_page_index = 0
	rules_root.visible = true
	_update_ui()

func _on_next_page_pressed() -> void:
	# Check if we are on the "EXIT" state
	if _current_page_index == _pages.size() - 1:
		_close_rules()
		return

	_current_page_index += 1
	_update_ui()

func _on_previous_page_pressed() -> void:
	if _current_page_index > 0:
		_current_page_index -= 1
		_update_ui()

func _update_ui() -> void:
	# Update the texture
	rule_page.texture = _pages[_current_page_index]

	# Visibility of Previous Button (Hide on first page)
	prev_button.visible = (_current_page_index > 0)

	# Handle Next Button vs Exit
	if _current_page_index == _pages.size() - 1:
		next_button.text = "EXIT"
	else:
		next_button.text = "NEXT"

func _close_rules() -> void:
	rules_root.visible = false
	# You could emit to your Signals bus here if other systems need to know
	# Signals.rules_closed.emit()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(MAP)
	close_layer()
