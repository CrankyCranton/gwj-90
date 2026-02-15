class_name Character extends TextureButton


@export var path_color := Color()
@export_group("Tween", "tween")
@export var tween_time := 0.2
@export var tween_transition := Tween.TRANS_SINE
@export var tween_ease := Tween.EASE_IN_OUT

var tween: Tween

@onready var location: Location:
	set(value):
		if location:
			location.get_connection_to_location(value).character = self
			location.character = null
		location = value
		location.character = self

		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_ease(tween_ease).set_trans(tween_transition).tween_property(
				self, ^"position", location.position, tween_time)


func _on_timer_timeout() -> void:
	location = location.connected_locations.pick_random()


func _on_focus_entered() -> void:
	pass # Enable accessable locations


func _on_focus_exited() -> void:
	pass # Disable acessable locations
