extends Node


signal card_gained(type: Location.Type)
signal card_burnt(index: int)
signal use_card(index: int)
signal deck_size_changed(deck_size: int)
signal discard_pile_size_changed(discard_pile_size: int)

signal move_character(character: Character, location: Location)
signal fetch_valid_character_movement(character: Character, valid_location_types: Array[Location.Type])
signal return_valid_character_movement(character: Character, locations: Array[Location])

signal character_selected(character: Character)
signal character_deselected(character: Character)
signal location_selected(location: Location)
signal location_deselected(location: Location)
# By default, all locations are disabled.
signal set_location_enabled(location: Location, enabled: bool)

signal loop_scored(character: Character, loop_score: int)
signal total_score_changed(score: int)
signal turns_left_changed(turns: int)
# Ignore 'won' if the game doesn't end immediately when the player reaches the required score
signal won
signal ended(score: int)
