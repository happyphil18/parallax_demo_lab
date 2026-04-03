extends Node


const CANVAS_WIDTH := 2048.0
const REPEAT_TIMES_LOW := 1
const REPEAT_TIMES_HIGH := 3

var show_scroll_scale_labels: bool = true
var show_repeat_guides: bool = false
var repeat_mode_index: int = 0
var offset_mode_index: int = 0

var _layer_specs: Array[Dictionary] = []
var _layers: Array[Dictionary] = []

@onready var parallax_root: Node2D = $"../ParallaxRoot"


func _ready() -> void:
	_layer_specs = [
		{
			"name": "Sky",
			"node_name": "LayerSky",
			"scroll_scale": Vector2(0.1, 1.0),
			"color": Color(0.494, 0.749, 0.992, 1.0),
			"outline": Color(0.322, 0.561, 0.906, 0.8),
			"height": 280.0,
			"top": 0.0,
			"repeat_size": Vector2(CANVAS_WIDTH, 0.0),
			"offset_alt": Vector2(0.0, 0.0),
			"guide_color": Color(0.376, 0.647, 0.992, 0.7)
		},
		{
			"name": "FarClouds",
			"node_name": "LayerFarClouds",
			"scroll_scale": Vector2(0.2, 1.0),
			"cloud_color": Color(0.945, 0.973, 1.0, 0.82),
			"top": 70.0,
			"repeat_size": Vector2(CANVAS_WIDTH, 0.0),
			"offset_alt": Vector2(180.0, 0.0),
			"guide_color": Color(0.741, 0.871, 1.0, 0.7)
		},
		{
			"name": "NearClouds",
			"node_name": "LayerNearClouds",
			"scroll_scale": Vector2(0.3, 1.0),
			"cloud_color": Color(1.0, 1.0, 1.0, 0.95),
			"top": 120.0,
			"repeat_size": Vector2(CANVAS_WIDTH, 0.0),
			"offset_alt": Vector2(260.0, 0.0),
			"guide_color": Color(0.898, 0.945, 1.0, 0.72)
		},
		{
			"name": "Hills",
			"node_name": "LayerHills",
			"scroll_scale": Vector2(0.5, 1.0),
			"color": Color(0.361, 0.706, 0.486, 1.0),
			"top": 355.0,
			"height": 190.0,
			"repeat_size": Vector2(CANVAS_WIDTH, 0.0),
			"offset_alt": Vector2(120.0, 0.0),
			"guide_color": Color(0.478, 0.914, 0.588, 0.68)
		},
		{
			"name": "Forest",
			"node_name": "LayerForest",
			"scroll_scale": Vector2(0.7, 1.0),
			"color": Color(0.165, 0.42, 0.243, 1.0),
			"top": 430.0,
			"height": 230.0,
			"repeat_size": Vector2(CANVAS_WIDTH, 0.0),
			"offset_alt": Vector2(90.0, 0.0),
			"guide_color": Color(0.361, 0.682, 0.424, 0.72)
		}
	]
	_build_layers()
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


func _build_layers() -> void:
	for spec in _layer_specs:
		var layer := Parallax2D.new()
		layer.name = spec["node_name"]
		layer.scroll_scale = spec["scroll_scale"]
		layer.repeat_size = spec["repeat_size"]
		layer.repeat_times = REPEAT_TIMES_LOW
		parallax_root.add_child(layer)

		var content_root := Node2D.new()
		content_root.name = "Content"
		layer.add_child(content_root)

		match spec["name"]:
			"Sky":
				_build_sky(content_root, spec)
			"FarClouds":
				_build_clouds(content_root, spec, true)
			"NearClouds":
				_build_clouds(content_root, spec, false)
			"Hills":
				_build_hills(content_root, spec)
			"Forest":
				_build_forest(content_root, spec)

		var guide := _make_repeat_guide(spec["repeat_size"].x, 680.0, spec["guide_color"])
		guide.name = "RepeatGuide"
		layer.add_child(guide)

		var label := Label.new()
		label.name = "ScaleLabel"
		label.position = Vector2(24.0, spec["top"] + 16.0)
		label.text = "%s  scroll_scale=(%.1f, %.1f)" % [spec["name"], spec["scroll_scale"].x, spec["scroll_scale"].y]
		layer.add_child(label)

		_layers.append({
			"name": spec["name"],
			"layer": layer,
			"guide": guide,
			"label": label,
			"default_offset": Vector2.ZERO,
			"offset_alt": spec["offset_alt"]
		})


func _build_sky(parent: Node2D, spec: Dictionary) -> void:
	var rect := Polygon2D.new()
	rect.color = spec["color"]
	rect.polygon = PackedVector2Array([
		Vector2(0, spec["top"]),
		Vector2(CANVAS_WIDTH, spec["top"]),
		Vector2(CANVAS_WIDTH, spec["top"] + spec["height"]),
		Vector2(0, spec["top"] + spec["height"])
	])
	parent.add_child(rect)

	for x_pos in [140.0, 640.0, 1120.0, 1620.0]:
		var ring := _make_hex_ring(Vector2(x_pos, spec["top"] + 80.0 + fmod(x_pos, 120.0) * 0.2), 28.0, spec["outline"])
		parent.add_child(ring)


func _build_clouds(parent: Node2D, spec: Dictionary, sparse: bool) -> void:
	var positions: Array = [120.0, 430.0, 820.0, 1210.0, 1620.0, 1890.0]
	var y_pos: float = spec["top"]
	var radius_x := 62.0 if sparse else 86.0
	var radius_y := 24.0 if sparse else 30.0
	for i in range(positions.size()):
		var x_pos: float = positions[i]
		var cloud := Node2D.new()
		cloud.position = Vector2(x_pos, y_pos + (i % 2) * 44.0)
		parent.add_child(cloud)
		cloud.add_child(_make_ellipse_polygon(Vector2(-radius_x * 0.45, 0), radius_x * 0.65, radius_y * 0.95, spec["cloud_color"]))
		cloud.add_child(_make_ellipse_polygon(Vector2(0, -10), radius_x * 0.85, radius_y * 1.08, spec["cloud_color"]))
		cloud.add_child(_make_ellipse_polygon(Vector2(radius_x * 0.52, 4), radius_x * 0.58, radius_y * 0.85, spec["cloud_color"]))


func _build_hills(parent: Node2D, spec: Dictionary) -> void:
	var hill_points := PackedVector2Array([
		Vector2(0, 620),
		Vector2(0, 510),
		Vector2(180, 430),
		Vector2(370, 520),
		Vector2(620, 420),
		Vector2(890, 530),
		Vector2(1160, 410),
		Vector2(1420, 520),
		Vector2(1710, 430),
		Vector2(1980, 510),
		Vector2(CANVAS_WIDTH, 620)
	])
	var hills := Polygon2D.new()
	hills.color = spec["color"]
	hills.polygon = hill_points
	parent.add_child(hills)


func _build_forest(parent: Node2D, spec: Dictionary) -> void:
	var ground := Polygon2D.new()
	ground.color = Color(0.145, 0.341, 0.204, 1.0)
	ground.polygon = PackedVector2Array([
		Vector2(0, 620),
		Vector2(0, 680),
		Vector2(CANVAS_WIDTH, 680),
		Vector2(CANVAS_WIDTH, 620)
	])
	parent.add_child(ground)

	for x_pos in [80.0, 210.0, 330.0, 470.0, 610.0, 760.0, 910.0, 1060.0, 1190.0, 1340.0, 1490.0, 1650.0, 1810.0, 1950.0]:
		var tree := Node2D.new()
		tree.position = Vector2(x_pos, 520.0 + fmod(x_pos, 60.0) * 0.15)
		parent.add_child(tree)

		var trunk := Polygon2D.new()
		trunk.color = Color(0.239, 0.161, 0.094, 1.0)
		trunk.polygon = PackedVector2Array([
			Vector2(-7, 40),
			Vector2(7, 40),
			Vector2(7, 96),
			Vector2(-7, 96)
		])
		tree.add_child(trunk)

		var crown := Polygon2D.new()
		crown.color = spec["color"]
		crown.polygon = PackedVector2Array([
			Vector2(0, -56),
			Vector2(38, 18),
			Vector2(18, 18),
			Vector2(54, 74),
			Vector2(-54, 74),
			Vector2(-18, 18),
			Vector2(-38, 18)
		])
		tree.add_child(crown)


func _make_repeat_guide(width: float, height: float, color: Color) -> Line2D:
	var line := Line2D.new()
	line.default_color = color
	line.width = 2.0
	line.closed = true
	line.points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(width, 0),
		Vector2(width, height),
		Vector2(0, height)
	])
	return line


func _make_hex_ring(center: Vector2, radius: float, color: Color) -> Line2D:
	var line := Line2D.new()
	line.default_color = color
	line.width = 2.0
	line.closed = true
	var pts := PackedVector2Array()
	for i in range(6):
		var angle := TAU * float(i) / 6.0 - PI / 2.0
		pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
	line.points = pts
	return line


func _make_ellipse_polygon(center: Vector2, radius_x: float, radius_y: float, color: Color) -> Polygon2D:
	var poly := Polygon2D.new()
	poly.color = color
	var pts := PackedVector2Array()
	for i in range(18):
		var angle := TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	poly.polygon = pts
	return poly


func _apply_modes() -> void:
	_apply_scroll_scale_visibility()
	_apply_repeat_guide_visibility()
	_apply_offset_mode()
	_apply_repeat_mode()


func _apply_scroll_scale_visibility() -> void:
	for layer_data in _layers:
		var label: Label = layer_data["label"]
		label.visible = show_scroll_scale_labels


func _apply_repeat_guide_visibility() -> void:
	for layer_data in _layers:
		var guide: Line2D = layer_data["guide"]
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
