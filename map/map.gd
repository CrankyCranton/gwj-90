class_name Map extends Control


@export var grid_size := Vector2i(18, 10)
@export var cell_size := Vector2(64.0, 64.0)
@export var randomization := 0.7
@export var connect_distance := 96.0

@onready var locations: Control = $Locations
@onready var connections: Control = $Connections


func _ready() -> void:
	generate()


func generate() -> void:
	const LOCATION := preload("res://map/location/location.tscn")
	for y in grid_size.y:
		for x in grid_size.x:
			var location: Location = LOCATION.instantiate()
			# TODO Take into account alignment
			var center := cell_size * Vector2(x, y) + cell_size / 2.0
			@warning_ignore("shadowed_global_identifier")
			var range := cell_size * randomization
			var offset := Utils.rand_vec2_range(-range, range) / 2
			location.position = center + offset

			var shortest_loc: Location = null
			var shortest_dist := INF
			var connection_count := 0
			for i: Location in locations.get_children():
				var distance := i.position.distance_to(location.position)
				# The check for null here isn't necessary, but makes it more full-proof.
				# Can be removed for performance if it loops a gazillion times or smth
				if shortest_loc == null or distance < shortest_dist:
					shortest_loc = i
					shortest_dist = distance
				if distance <= connect_distance:
					create_connection(location, i)
					connection_count += 1

			# Make sure there's at least 1 connection.
			# The null check is for the first location, when there won't be anything to connect to
			if connection_count <= 0 and shortest_loc != null:
				create_connection(location, shortest_loc)

			locations.add_child(location)


func create_connection(a: Location, b: Location) -> void:
	const CONNECTION := preload("res://map/connection/connection.tscn")
	var connection: Line2D = CONNECTION.instantiate()
	connection.add_point(a.position)
	connection.add_point(b.position)
	connections.add_child(connection)
