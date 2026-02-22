extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func play_sound(character):
	match character:
		"Monk":
			$snd_monk.play()
		"Fighter":
			$snd_fighter.play()
		"Ranger":
			$snd_ranger.play()
		"Merchant":
			$snd_merchant.play()
		"Alchemist":
			$snd_alchemist.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
