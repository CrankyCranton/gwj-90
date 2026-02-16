# Doesn't really need to extend Node, but being able to see it in the scene tree is nice
class_name CardsManager extends Node


@export var initial_hand_size := 5

var deck: Array[Location.Type] = []
var hand: Array[Location.Type] = []
var discard_pile: Array[Location.Type] = []


func _ready() -> void:
	Bus.use_card.connect(burn_card)
	Bus.draw_card.connect(draw_card)


func init_deck() -> void:
	for location: Location in get_tree().get_nodes_in_group(&"locations"):
		deck.append(location.type)
	deck.shuffle() # Might not be necessary if the locations are already shuffled
	for i in initial_hand_size:
		draw_card()


func draw_card() -> void:
	if deck.size() <= 0:
		deck = discard_pile.duplicate()
		discard_pile = []
		deck.shuffle()
		Bus.discard_pile_size_changed.emit(discard_pile.size())

	var card: Location.Type = deck.pop_back()
	hand.append(card)
	Bus.card_gained.emit(card)
	Bus.deck_size_changed.emit(deck.size())


func burn_card(index := 0) -> void:
	var card := hand[index]
	discard_pile.append(card)
	hand.remove_at(index)
	Bus.card_burnt.emit(index)
	Bus.discard_pile_size_changed.emit(discard_pile.size())
