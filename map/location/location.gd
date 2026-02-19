class_name Location extends Button


static var icons_lookup: Dictionary[Script, Texture2D] = {
	null: preload("uid://c57cnquykwost"),
}

@export var points := 1
@export var view_range := 1

var character: Character = null
var claim: PlayerCharacter = null
var connections: Array[Connection]
var connected_locations: Array[Location]
var finished := false

@onready var points_counter: Label = $PointsCounter


func _ready() -> void:
	if not icons_lookup.has(get_script()):
		icons_lookup[get_script()] = icon
	add_to_group(get_script().get_global_name().to_snake_case()) # IDK how to convert it to plural, sry
	Bus.set_location_enabled.connect(_on_bus_set_location_enabled)
	hide()


func _get_points(_path: Array) -> int:
	return points


func _activate() -> void:
	if character is PlayerCharacter:
		lift_fow()


func _draw_card() -> void:
	CardsManager.draw_card()


func clear_path() -> void:
	pass


func update_points_counter(path: Array, x2 := false) -> void:
	if path == []:
		points_counter.text = ""
		return
	var displayed_points := _get_points(path)
	if x2:
		displayed_points *= 2
	points_counter.text = str(displayed_points)


@warning_ignore("shadowed_variable")
func lift_fow(on := self, view_range := self.view_range) -> void:
	view_range -= 1
	on.show()
	for i in on.connected_locations:
		for j in i.connections:
			j.show()
			j.update_gradient()
		if view_range >= 0:
			lift_fow(i, view_range)


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
	disabled = not enabled
	focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	if not enabled:
		release_focus()


func _on_focus_entered() -> void:
	Bus.location_selected.emit(self)


func _on_focus_exited() -> void:
	Bus.location_deselected.emit(self)
