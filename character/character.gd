class_name Character extends Button


signal moved(character: Character, location: Location)
signal loop_scored(character: Character, loop_score: int)

@export var path_color := Color()
@export_group("Movement")
@export var can_retravel_connections := false
@export var can_revisit_location_types := true
@export var can_move_onto_other_character := false
@export var can_revisit_location := true
@export var can_move_to_last_location := true
@export_group("Scoring")
@export var clear_after_loop := true
@export var connection_points := 1
@export var location_type_points := 1
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
			moved.emit(self, value)
		else:
			home = value

		# NOTICE location is only assigned to value at this point.
		# In the code above this, "location" is the old location.
		location = value
		if not visited_location_types.has(location.type):
			visited_location_types.append(location.type)
		location.character = self
		location.claim = self

		tween_movement()
		lift_fow()


func _ready() -> void:
	Bus.move_character.connect(_on_bus_move_character)
	Bus.fetch_valid_character_movement.connect(_on_bus_fetch_valid_character_movement)


# TEST
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		# Add a random offset to prevent players from moving simultaniously
		await get_tree().create_timer(randf_range(0.0, 0.2)).timeout
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
	var score := visited_location_types.size() * location_type_points

	for i: Connection in get_tree().get_nodes_in_group(&"connections").filter(
				filter_character_connections):
		score += connection_points
		if clear_after_loop:
			i.character = null
	for i: Location in get_tree().get_nodes_in_group(&"locations").filter(
			filter_character_locations):
				if clear_after_loop:
					i.claim = null

	# TODO Remove print statements after they're no longer needed
	print(self, ": Loop completed! Score: ", score)
	print("\tLocations visited: ", visited_location_types)
	visited_location_types.clear()
	Bus.loop_scored.emit(self, score)
	loop_scored.emit(self, score)


func filter_character_connections(connection: Connection) -> bool:
	return connection.character == self


@warning_ignore("shadowed_variable")
func filter_character_locations(location: Location) -> bool:
	return location.claim == self


# Made input argument "valid_types" an array, in case it needs to display the
# valid locations for all the card types you have in hand.
func get_valid_locations(valid_types: Array[Location.Type]) -> Array[Location]:
	@warning_ignore("shadowed_variable")
	return location.connected_locations.filter(
		func(location: Location) -> bool:
			# Might be about time to split this bad boy into a multi-liner
			return  location.type in valid_types \
					and (can_move_to_last_location or location != last_location) \
					and (can_move_onto_other_character or location.character == null) \
					and (can_revisit_location or location.claim == null) \
					and (can_revisit_location_types or not location.type in visited_location_types) \
					and (can_retravel_connections or
					self.location.get_connection_to_location(location).character == null)
	)


func _on_focus_entered() -> void:
	Bus.character_selected.emit(self)


func _on_focus_exited() -> void:
	Bus.character_deselected.emit(self)


@warning_ignore("shadowed_variable")
func _on_bus_move_character(character: Character, location: Location) -> void:
	if character != self:
		return
	assert(location in self.location.connected_locations)

	self.location = location


func _on_bus_fetch_valid_character_movement(character: Character,
		valid_location_types: Array[Location.Type]) -> void:
	if character != self:
		return
	Bus.return_valid_character_movement.emit(self, get_valid_locations(valid_location_types))
