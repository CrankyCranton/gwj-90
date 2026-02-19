class_name MyBeautifulUI extends CanvasLayer


var selected_character: PlayerCharacter = null
var selected_card: MyBeautifulCard = null
var target_score := 0

@onready var card_holder: HBoxContainer = %CardHolder
@onready var score: Label = %Score
@onready var turns_left: Label = %TurnsLeft
@onready var discard_pile: Label = %DiscardPile
@onready var deck: Label = %Deck
@onready var bandits: Label = $%Bandits


func _ready() -> void:
	Bus.target_score_set.connect(func(value: int) -> void: target_score = value; _on_bus_total_score_changed(0))
	Bus.card_burnt.connect(_on_bus_card_burnt)
	Bus.card_perma_burnt.connect(_on_bus_card_burnt)
	Bus.turn_taken.connect(fetch_valid_spots)
	Bus.card_gained.connect(_on_bus_card_gained)
	Bus.deck_size_changed.connect(_on_bus_deck_size_changed)
	Bus.discard_pile_size_changed.connect(_on_bus_discard_pile_size_changed)
	Bus.return_valid_character_movement.connect(_on_bus_return_valid_character_movement)
	Bus.character_selected.connect(_on_bus_character_selected)
	Bus.location_selected.connect(_on_bus_location_selected)
	Bus.total_score_changed.connect(_on_bus_total_score_changed)
	Bus.turns_left_changed.connect(_on_bus_turns_left_changed)
	Bus.bandit_added.connect(_on_bus_bandits_changed)
	Bus.bandit_removed.connect(_on_bus_bandits_changed)
	Bus.won.connect(get_tree().set.bind(&"paused", true))


func fetch_valid_spots() -> void:
	# Ideally cards should store their type instead of looking it up by icon, but it's throw-away code
	var types: Array[Script] = [null]
	#types.append(selected_card.type)
	Bus.fetch_valid_character_movement.emit(selected_character, types)


func _on_bus_bandits_changed() -> void:
	bandits.text = "Bandits: " + str(Bandit.bandits)


func _on_bus_card_gained(type: Script) -> void:
	var card: MyBeautifulCard = preload("uid://cy6q1636h15ej").instantiate()
	card.type = type
	card.focus_entered.connect(_on_my_beautiful_card_focus_entered.bind(card))
	card_holder.add_child(card)
	card.grab_focus()


func _on_bus_card_burnt(index: int) -> void:
	card_holder.get_child(index).free()


func _on_bus_deck_size_changed(deck_size: int) -> void:
	deck.text = "Deck: " + str(deck_size)


func _on_bus_discard_pile_size_changed(discard_pile_size: int) -> void:
	discard_pile.text = "Discard Pile: " + str(discard_pile_size)


func _on_bus_return_valid_character_movement(_character: PlayerCharacter, locations: Array[Location]) -> void:
	for location: Location in get_tree().get_nodes_in_group(&"locations"):
		Bus.set_location_enabled.emit(location, location in locations)


func _on_bus_character_selected(character: Character) -> void:
	selected_character = character
	#if selected_card != null:
	fetch_valid_spots()


func _on_bus_location_selected(location: Location) -> void:
	Bus.use_card.emit(selected_card.get_index())
	Bus.move_character.emit(selected_character, location)


@warning_ignore("shadowed_variable")
func _on_bus_total_score_changed(score: int) -> void:
	self.score.text = "Score: " + str(score) + "/" + str(target_score)


func _on_bus_turns_left_changed(turns: int) -> void:
	turns_left.text = "Turns Left: " + str(turns)


func _on_my_beautiful_card_focus_entered(card: Button) -> void:
	selected_card = card
	if selected_character != null:
		fetch_valid_spots()


func _on_my_beautiful_skip_button_pressed() -> void:
	Bus.draw_card.emit()
	Bus.take_turn.emit()
