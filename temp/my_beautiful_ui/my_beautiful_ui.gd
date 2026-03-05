class_name MyBeautifulUI extends CanvasLayer


var selected_character: PlayerCharacter = null
var target_score := 0
var awaiting_turn := false

@onready var score: Label = %Score
@onready var turns_left: Label = %TurnsLeft
@onready var bandits: Label = $%Bandits


func _ready() -> void:
	Bus.target_score_set.connect(func(value: int) -> void: target_score = value; _on_bus_total_score_changed(0))
	Bus.turn_finished.connect(_on_bus_turn_finished)
	Bus.return_valid_character_movement.connect(_on_bus_return_valid_character_movement)
	Bus.character_selected.connect(_on_bus_character_selected)
	Bus.location_selected.connect(_on_bus_location_selected)
	Bus.total_score_changed.connect(_on_bus_total_score_changed)
	Bus.turns_left_changed.connect(_on_bus_turns_left_changed)
	Bus.bandit_added.connect(_on_bus_bandits_changed)
	Bus.bandit_removed.connect(_on_bus_bandits_changed)


func fetch_valid_spots() -> void:
	var types: Array[Script] = [null]
	Bus.fetch_valid_character_movement.emit(selected_character, types)


func _on_bus_turn_finished() -> void:
	fetch_valid_spots()
	awaiting_turn = false


func _on_bus_return_valid_character_movement(_character: PlayerCharacter, locations: Array[Location]) -> void:
	for location: Location in get_tree().get_nodes_in_group(&"locations"):
		Bus.set_location_enabled.emit(location, location in locations)


func _on_bus_character_selected(character: Character) -> void:
	selected_character = character
	if not awaiting_turn:
		fetch_valid_spots()


func _on_bus_location_selected(location: Location) -> void:
	if not awaiting_turn:
		awaiting_turn = true
		get_tree().call_group(&"locations", &"set_enabled", false)
		Bus.move_character.emit(selected_character, location)


func _on_bus_bandits_changed() -> void:
	bandits.text = "Bandits: " + str(Bandit.bandits)


@warning_ignore("shadowed_variable")
func _on_bus_total_score_changed(score: int) -> void:
	self.score.text = "Score: " + str(score) + "/" + str(target_score)


func _on_bus_turns_left_changed(turns: int) -> void:
	turns_left.text = "Turns Left: " + str(turns)
	#if turns <= 0:
		#get_tree().paused = true


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
