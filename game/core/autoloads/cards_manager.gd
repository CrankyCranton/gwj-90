extends Node


@export var initial_hand_size := 5

var deck: Array[Script] = []
var hand: Array[Script] = []
var discard_pile: Array[Script] = []


func _ready() -> void:
	Bus.use_card.connect(burn_card)
	Bus.draw_card.connect(draw_card)


func init_deck() -> void:
	deck = []
	hand = []
	discard_pile = []

	for location: Location in get_tree().get_nodes_in_group(&"locations"):
		if not location is Lake:
			deck.append(location.get_script())
	deck.shuffle() # Might not be necessary if the locations are already shuffled
	for i in initial_hand_size:
		draw_card()


func draw_card() -> void:
	if deck.size() <= 0:
		deck = discard_pile.duplicate()
		discard_pile = []
		deck.shuffle()
		Bus.discard_pile_size_changed.emit(discard_pile.size())

	add_card(deck.pop_back())
	Bus.deck_size_changed.emit(deck.size())


func add_card(card: Script) -> void:
	hand.append(card)
	Bus.card_gained.emit(card)


func burn_card(index := 0) -> void:
	var card := hand[index]
	if card != null: # Wildcards (null) are burnt without returning to the discard pile
		discard_pile.append(card)
		Bus.discard_pile_size_changed.emit(discard_pile.size())
		Bus.card_burnt.emit(index)
	else:
		Bus.card_perma_burnt.emit(index)
	hand.remove_at(index)
