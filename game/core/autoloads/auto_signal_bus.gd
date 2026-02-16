extends Node


signal card_gained(index: int, type: Location.Type)
signal card_burnt(index: int)
signal use_card(index: int)

signal move_character(character: Character, location: Location)
signal fetch_valid_character_movement(character: Character, valid_location_types: Array[Location.Type])
signal return_valid_character_movement(character: Character, locations: Array[Location])

signal character_selected(character: Character)
signal character_deselected(character: Character)
signal location_selected(location: Location)
signal location_deselected(location: Location)
# By default, all locations are disabled.
signal enable_location(location: Location)
signal disable_location(location: Location)

signal loop_scored(character: Character, loop_score: int)
signal total_score_changed(score: int)
signal won
signal lost
