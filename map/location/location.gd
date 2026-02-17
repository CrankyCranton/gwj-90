class_name Location extends GraphElement


@export var points := 1
@export var view_range := 1

var character: Character = null
var claim: Character = null
var connections: Array[Connection]
var connected_locations: Array[Location]

@onready var icon: TextureRect = $Icon
@onready var disabled_color := icon.modulate


func _ready() -> void:
	add_to_group(get_script().get_global_name().to_snake_case()) # IDK how to convert it to plural, sry
	#hide()
	Bus.set_location_enabled.connect(_on_bus_set_location_enabled)


func _get_points(_path: Array) -> int:
	return points


@warning_ignore("shadowed_variable")
func lift_fow(view_range := self.view_range) -> void:
	show()
	for i in connected_locations:
		i.show()
		for j in i.connections:
			j.show()
			j.update_gradient()


func is_connected_to_location(location: Location) -> bool:
	return location in connected_locations


func get_connection_to_location(location: Location) -> Connection:
	for connection: Connection in connections:
		if location in [connection.a, connection.b]:
			return connection
	return null


func _on_bus_set_location_enabled(location: Location, enabled: bool) -> void:
	if location != self:
		return
	selectable = enabled
	icon.modulate = Color.WHITE if enabled else disabled_color


func _on_node_selected() -> void:
	Bus.location_selected.emit(self)


func _on_node_deselected() -> void:
	Bus.location_deselected.emit(self)
