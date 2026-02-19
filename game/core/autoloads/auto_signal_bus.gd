extends Node


signal card_gained(type: Script)
signal card_burnt(index: int)
signal card_perma_burnt(index: int)
signal use_card(index: int)
signal draw_card
signal deck_size_changed(deck_size: int)
signal discard_pile_size_changed(discard_pile_size: int)

signal move_character(character: PlayerCharacter, location: Location)
signal fetch_valid_character_movement(character: PlayerCharacter, valid_location_types: Array[Script])
signal return_valid_character_movement(character: PlayerCharacter, locations: Array[Location])
signal bandit_added
signal bandit_removed
signal add_bandit

signal character_selected(character: PlayerCharacter)
signal character_deselected(character: PlayerCharacter)
signal location_selected(location: Location)
signal location_deselected(location: Location)
# By default, all locations are disabled.
signal set_location_enabled(location: Location, enabled: bool)

signal path_scored(character: PlayerCharacter, path_score: int)
signal character_unfinished_path_score_changed(character: Character, path_score: int)
signal total_score_changed(score: int)
signal target_score_set(target_score: int)
signal turns_left_changed(turns: int)
signal take_turn
signal turn_taken
# Ignore 'won' if the game doesn't end immediately when the player reaches the required score
signal won
signal ended(score: int)
