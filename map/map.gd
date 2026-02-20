# Not going big on the node hierarchy, accessing things by groups.
class_name Map extends Node2D


@export var max_turns := 25
@export_group("Generation")
@export var max_radius := 2048.0
@export var min_distance := 80.0
@export var max_distance := 240.0
# I have no idea what this does, so I just exported it and used the demo value
@export var retries := 30
@export var bandit_count := 3
@export var bandit_add_interval := 5
@export var character_count := 5
@export var characters: Array[PackedScene]
@export var locations_distribution: Dictionary[PackedScene, int] = {}

var map_rect := Rect2i()
var score := 0:
	set(value):
		score = value
		Bus.total_score_changed.emit(score)
		if score >= location_count:
			Bus.won.emit()
var location_count: int:
	set(_value):
		pass
	get:
		var total := 0
		for count: int in locations_distribution.values():
			total += count
		return total

@onready var camera: Camera = $Camera
# Must be @onready because of when @export variables are assigned
@onready var turns_left := max_turns:
	set(value):
		turns_left = value
		Bus.turns_left_changed.emit(turns_left)
		if turns_left <= 0:
			Bus.ended.emit(score)


func _ready() -> void:
	Bus.add_bandit.connect(add_bandit)
	generate_locations()
	generate_connections()
	spawn_characters()
	spawn_bandits()
	CardsManager.init_deck()
	init_camera()
	turns_left = turns_left # Call setter
	Bus.target_score_set.emit(location_count)


func init_camera() -> void:
	camera.position = map_rect.get_center()
	camera.limits = map_rect


func generate_locations() -> void:
	var available_points: Array = PoissonDiscSampling.generate_points_for_circle(Vector2.ZERO,
			max_radius, min_distance, 30, Vector2.ZERO, location_count)
	available_points.shuffle()

	var i := 0
	for TYPE: PackedScene in locations_distribution:
		for j in locations_distribution[TYPE]:
			var location: Location = TYPE.instantiate()
			location.position = available_points[i] - location.size / 2.0
			add_child(location)
			map_rect = map_rect.expand(available_points[i])
			i += 1


func generate_connections() -> void:
	var locations: Array[Location] = Array(get_tree().get_nodes_in_group(&"locations"),
			TYPE_OBJECT, &"Button", preload("uid://kttdtllwq2rh"))
	var locations_positions: PackedVector2Array = []
	for location: Location in locations:
		locations_positions.append(location.position)

	var indicies := Geometry2D.triangulate_delaunay(locations_positions)
	const STEP := 3
	for i in range(0, indicies.size() - (STEP - 1), STEP):
		for j in range(i, i + STEP):
			var connect_index := wrapi(j + 1, i, i + STEP)
			var from := locations[indicies[j]]
			var to := locations[indicies[connect_index]]
			if from.position.distance_to(to.position) <= max_distance \
					and not from.is_connected_to_location(to):
				create_connection(from, to)


func create_connection(a: Location, b: Location) -> void:
	assert(a != b)
	const CONNECTION := preload("res://map/connection/connection.tscn")
	var connection: Connection = CONNECTION.instantiate()
	connection.a = a
	connection.b = b
	add_child(connection)
	move_child(connection, 0)

	a.connected_locations.append(b)
	b.connected_locations.append(a)
	a.connections.append(connection)
	b.connections.append(connection)
	connection.update()


func spawn_characters() -> void:
	var inns := get_tree().get_nodes_in_group(&"inn")
	inns.shuffle()
	characters.shuffle()
	assert(character_count <= characters.size())
	for i in character_count:
		var character: PlayerCharacter = characters[i].instantiate()
		#character.offset = character.offset.rotated(float(i) / character_count * TAU)
		character.path_scored.connect(_on_character_path_scored)
		character.moved.connect(_on_character_moved)
		add_child(character)
		character.set_location(inns.pop_back())


func spawn_bandits() -> void:
	for i in bandit_count:
		add_bandit()


func add_bandit() -> void:
	var bandit: Bandit = preload("res://character/bandit/bandit.tscn").instantiate()
	add_child(bandit)
	var spawn_locations := get_tree().get_nodes_in_group(&"obelisk").filter(
			func(obelisk: Obelisk) -> bool: return obelisk.character == null)
	if spawn_locations.size() > 0:
		bandit.set_location(spawn_locations.pick_random())


func _on_character_path_scored(_character: Character, path_score: int) -> void:
	score += path_score


func _on_character_moved(_character: PlayerCharacter) -> void:
	turns_left -= 1
	# I'm probably using these filter and lambda functions way too much
	var bandits := get_tree().get_nodes_in_group(&"bandits").filter(
			func(bandit: Bandit) -> bool: return not bandit.just_added)
	print(bandits.size())
	if bandits.size() > 0:
		await bandits.pick_random().random_walk()

	if (max_turns - turns_left) % bandit_add_interval == 0:
		add_bandit()
	print("Turn taken")
	Bus.turn_finished.emit()
