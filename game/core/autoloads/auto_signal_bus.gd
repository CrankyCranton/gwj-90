extends Node


signal card_gained(type: Script)
signal card_burnt(index: int)
signal card_perma_burnt(index: int)
signal use_card(index: int)
signal draw_card
signal deck_size_changed(deck_size: int)
signal discard_pile_size_changed(discard_pile_size: int)

signal move_character(character: Character, location: Location)
signal fetch_valid_character_movement(character: Character, valid_location_types: Array[Script])
signal return_valid_character_movement(character: Character, locations: Array[Location])

signal character_selected(character: Character)
signal character_deselected(character: Character)
signal location_selected(location: Location)
signal location_deselected(location: Location)
# By default, all locations are disabled.
signal set_location_enabled(location: Location, enabled: bool)

signal path_scored(character: Character, path_score: int)
signal character_unfinished_path_score_changed(character: Character, path_score: int)
signal total_score_changed(score: int)
signal turns_left_changed(turns: int)
signal take_turn
# Ignore 'won' if the game doesn't end immediately when the player reaches the required score
signal won
signal ended(score: int)
