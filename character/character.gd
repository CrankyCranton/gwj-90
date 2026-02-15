class_name Character extends TextureButton


@export var path_color := Color()
@export var clear_after_loop := true
@export var can_retravel_connections := false
@export_group("Tween", "tween")
@export var tween_time := 0.2
@export var tween_transition := Tween.TRANS_SINE
@export var tween_ease := Tween.EASE_IN_OUT

var tween: Tween
var home: Location
var last_location: Location
var visited_location_types: Array[Location.Type] = []

## Set this to move the character.
@onready var location: Location = null:
	set(value):
		assert(value != null)
		if location:
			location.get_connection_to_location(value).character = self
			location.character = null
			last_location = location
			if value == home:
				complete_loop() # Order-of-operation of when this is called matters.
		else:
			home = value

		# NOTICE location is only assigned to value at this point.
		# In the code above this, "location" is the old location.
		location = value
		if not visited_location_types.has(location.type):
			visited_location_types.append(location.type)
		location.character = self

		tween_movement()
		lift_fow()


# TEST
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		var location_types: Array[Location.Type] = []
		location_types.append_array(Location.Type.values()) # Casting array types
		var valid_locations := get_valid_locations(location_types)
		if valid_locations.size() > 0:
			location = valid_locations.pick_random()


func tween_movement() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(tween_ease).set_trans(tween_transition).tween_property(
			self, ^"position", location.position, tween_time)


func lift_fow() -> void:
	location.show()
	for i in location.connected_locations:
		i.show()
		for j in i.connected_locations:
			if j.visible:
				i.get_connection_to_location(j).show()


func complete_loop() -> void:
	var score := visited_location_types.size()

	for i: Connection in get_tree().get_nodes_in_group(&"connections").filter(
				filter_character_connections):
		score += 1
		if clear_after_loop:
			i.character = null
	print(self, ": Loop completed! Score: ", score)
	print("\tLocations visited: ", visited_location_types)
	visited_location_types.clear()


func filter_character_connections(connection: Connection) -> bool:
	return connection.character == self


# Made input argument "valid_types" an array, in case it needs to display the
# valid locations for all the card types you have in hand.
func get_valid_locations(valid_types: Array[Location.Type]) -> Array[Location]:
	@warning_ignore("shadowed_variable")
	return location.connected_locations.filter(
		func(location: Location) -> bool:
			return location != last_location and location.type in valid_types and (
				can_retravel_connections or
				self.location.get_connection_to_location(location).character == null)
	)


func _on_focus_entered() -> void:
	pass # Enable accessable locations


func _on_focus_exited() -> void:
	pass # Disable acessable locations
