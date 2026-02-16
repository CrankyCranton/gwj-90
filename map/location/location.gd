# Might have to make a look-up dictionary/array for the textures that apply to each type.
# If that's too inconvenient, it'll probably be better to make each type it's own inherited scene,
# like with the characters.
class_name Location extends Button


enum Type {
	GRASS,
	TREE,
	LAKE,
	HILL,
	CAVE,
	INN,
	RELIC,
	OBELISK,
	TEMPLE,
}

const SPRITES: Array[Texture2D] = [
	preload("res://temp/Colored/genericItem_color_001.png"),
	preload("res://temp/Colored/genericItem_color_002.png"),
	preload("res://temp/Colored/genericItem_color_003.png"),
	preload("res://temp/Colored/genericItem_color_004.png"),
	preload("res://temp/Colored/genericItem_color_005.png"),
	preload("res://temp/Colored/genericItem_color_006.png"),
	preload("res://temp/Colored/genericItem_color_007.png"),
	preload("res://temp/Colored/genericItem_color_008.png"),
	preload("res://temp/Colored/genericItem_color_009.png"),
	preload("res://temp/Colored/genericItem_color_010.png"),
	preload("res://temp/Colored/genericItem_color_011.png"),
	preload("res://temp/Colored/genericItem_color_012.png"),
	preload("res://temp/Colored/genericItem_color_013.png"),
	preload("res://temp/Colored/genericItem_color_014.png"),
	preload("res://temp/Colored/genericItem_color_015.png"),

]

var type := (randi() % Type.size()) as Type

var character: Character = null
var claim: Character = null
var connections: Array[Connection]
var connected_locations: Array[Location]


func _ready() -> void:
	Bus.set_location_enabled.connect(_on_bus_set_location_enabled)
	icon = SPRITES[type]


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
