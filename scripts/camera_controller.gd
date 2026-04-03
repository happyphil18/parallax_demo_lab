extends Camera2D


@export var camera_speed: float = 320.0
@export var zoom_step: float = 0.15
@export var min_zoom: float = 0.55
@export var max_zoom: float = 1.15

var _start_position: Vector2
var _start_zoom: Vector2


func _ready() -> void:
	_start_position = position
	_start_zoom = zoom


func _process(delta: float) -> void:
	var direction := Input.get_axis("move_camera_left", "move_camera_right")
	position.x += direction * camera_speed * delta


func zoom_in() -> void:
	_set_zoom_value(clamp(zoom.x - zoom_step, min_zoom, max_zoom))


func zoom_out() -> void:
	_set_zoom_value(clamp(zoom.x + zoom_step, min_zoom, max_zoom))


func reset_to_origin() -> void:
	position = _start_position
	zoom = _start_zoom


func _set_zoom_value(value: float) -> void:
	zoom = Vector2(value, value)
