extends Node2D

@onready var characterName
@onready var locationName
@onready var goal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	Bus.character_selected.connect(character_sound)
	Bus.location_selected.connect(location_sound)
	Bus.path_scored.connect(path_finished)
	Bus.bandit_removed.connect(bandit_sound)
	Bus.target_score_set.connect(set_goal)
	Bus.won.connect(game_over)
	$Music.themes()
	
func set_goal(target_score: int):
	
	goal = target_score
	print(goal)

# Called when a character is selected.
func character_sound(character: Character):	
	if character.name != characterName:
		characterName = character.name
		$Character.play_sound(characterName)
	

func location_sound(location: Location):
	if location is Library: 	
		$Environment.play_sound("Library")
	if location is Swamp: 	
		$Environment.play_sound("Swamp")
	if location is Inn: 	
		$Environment.play_sound("Inn")
	if location is Grass:
		$Environment.play_sound("Grass")
	if location is Hill: 	
		$Environment.play_sound("Hill")
	if location is Fountain: 	
		$Environment.play_sound("Fountain")
	if location is Castle: 	
		$Environment.play_sound("Castle")
	if location is Ruins:
		$Environment.play_sound("Ruins")
	if location is Camp:
		$Environment.play_sound("Camp")
	if location is Watchtower:
		$Environment.play_sound("Watchtower")
	if location is Forest:
		$Environment.play_sound("Forest")
	if location is Obelisk:
		$Environment.play_sound("Obelisk")
	if location is Temple:
		$Environment.play_sound("Temple")
	if location is Lake:
		$Environment.play_sound("Lake")
	if location is Cave:
		$Environment.play_sound("Cave")
	$UI/snd_button_click.play()


func path_finished(character: PlayerCharacter, path_score: int):
	if path_score > 0:
		print("path finished")
		$Event/snd_finish_path.play()
		
func bandit_sound():
	$Object/snd_bandit.play()
	print("Bandit removed!")
		
func game_over():
	$Event/snd_win.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
