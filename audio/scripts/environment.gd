extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_sound(Location):
		print("Playing ", Location, " Sound")
		match Location:
			Grass:
				$snd_grass.play()
			Forest:
				$snd_forest.play()
			Lake:
				$snd_lake.play()
			Hill:
				$snd_hill.play()
			Swamp:
				$snd_swamp.play()
			Cave:
				$snd_cave.play()
			Inn:
				$snd_inn.play()
			Camp:
				$snd_camp.play()
			Watchtower:
				$snd_watchtower.play()
			Fountain:
				$snd_fountain.play()
			Obelisk:
				$snd_obelisk.play()
			Temple:
				$snd_temple.play()
			Ruins:
				$snd_ruins.play()
			Castle:
				$snd_castle.play()
			Library:
				$snd_library.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
