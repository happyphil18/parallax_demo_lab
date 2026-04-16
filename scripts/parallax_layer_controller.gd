extends Node


const REPEAT_TIMES_LOW := 1
const REPEAT_TIMES_HIGH := 3

var show_scroll_scale_labels: bool = true
var show_repeat_guides: bool = false
var repeat_mode_index: int = 0
var offset_mode_index: int = 0

var _layers: Array[Dictionary] = []

@onready var layer_sky: Parallax2D = $"../ParallaxRoot/LayerSky"
@onready var layer_far_clouds: Parallax2D = $"../ParallaxRoot/LayerFarClouds"
@onready var layer_near_clouds: Parallax2D = $"../ParallaxRoot/LayerNearClouds"
@onready var layer_hills: Parallax2D = $"../ParallaxRoot/LayerHills"
@onready var layer_forest: Parallax2D = $"../ParallaxRoot/LayerForest"


func _ready() -> void:
	_layers = [
		_make_layer_data("Sky", layer_sky, Vector2.ZERO),
		_make_layer_data("FarClouds", layer_far_clouds, Vector2(180.0, 0.0)),
		_make_layer_data("NearClouds", layer_near_clouds, Vector2(260.0, 0.0)),
		_make_layer_data("Hills", layer_hills, Vector2(120.0, 0.0)),
		_make_layer_data("Forest", layer_forest, Vector2(90.0, 0.0))
	]
	_apply_modes()


func toggle_scroll_scale_labels() -> void:
	show_scroll_scale_labels = not show_scroll_scale_labels
	_apply_scroll_scale_visibility()


func toggle_repeat_guides() -> void:
	show_repeat_guides = not show_repeat_guides
	_apply_repeat_guide_visibility()


func cycle_offset_mode() -> void:
	offset_mode_index = (offset_mode_index + 1) % 2
	_apply_offset_mode()


func cycle_repeat_mode() -> void:
	repeat_mode_index = (repeat_mode_index + 1) % 2
	_apply_repeat_mode()


func reset_demo() -> void:
	show_scroll_scale_labels = true
	show_repeat_guides = false
	offset_mode_index = 0
	repeat_mode_index = 0
	_apply_modes()


func get_focus_summary() -> String:
	if show_repeat_guides:
		return "repeat_size guide"
	if offset_mode_index == 1:
		return "scroll_offset demo"
	if repeat_mode_index == 1:
		return "repeat_times zoom-out support"
	if show_scroll_scale_labels:
		return "scroll_scale comparison"
	return "camera movement"


func get_repeat_mode_name() -> String:
	return "HIGH (3)" if repeat_mode_index == 1 else "LOW (1)"


func get_offset_mode_name() -> String:
	return "ALT offset" if offset_mode_index == 1 else "Default offset"


func get_layer_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	for layer_data in _layers:
		var layer: Parallax2D = layer_data["layer"]
		lines.append("%s  scale=(%.1f, %.1f)  repeat_x=%.0f" % [
			layer_data["name"],
			layer.scroll_scale.x,
			layer.scroll_scale.y,
			layer.repeat_size.x
		])
	return lines


func _make_layer_data(name: String, layer: Parallax2D, alt_offset: Vector2) -> Dictionary:
	return {
		"name": name,
		"layer": layer,
		"guide": layer.get_node("RepeatGuide") as CanvasItem,
		"label": layer.get_node("ScaleLabel") as CanvasItem,
		"default_offset": Vector2.ZERO,
		"offset_alt": alt_offset
	}


func _apply_modes() -> void:
	_apply_scroll_scale_visibility()
	_apply_repeat_guide_visibility()
	_apply_offset_mode()
	_apply_repeat_mode()


func _apply_scroll_scale_visibility() -> void:
	for layer_data in _layers:
		var label: CanvasItem = layer_data["label"]
		label.visible = show_scroll_scale_labels


func _apply_repeat_guide_visibility() -> void:
	for layer_data in _layers:
		var guide: CanvasItem = layer_data["guide"]
		guide.visible = show_repeat_guides


func _apply_offset_mode() -> void:
	for layer_data in _layers:
		var layer: Parallax2D = layer_data["layer"]
		layer.scroll_offset = layer_data["offset_alt"] if offset_mode_index == 1 else layer_data["default_offset"]


func _apply_repeat_mode() -> void:
	var repeat_times := REPEAT_TIMES_HIGH if repeat_mode_index == 1 else REPEAT_TIMES_LOW
	for layer_data in _layers:
		var layer: Parallax2D = layer_data["layer"]
		layer.repeat_times = repeat_times
