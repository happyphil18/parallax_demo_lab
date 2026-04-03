extends Node2D


@export var show_detailed_hud: bool = true

var _last_focus_key: String = "scroll_scale comparison"

@onready var camera_controller: Camera2D = %Camera2D
@onready var parallax_manager: Node = %ParallaxManager
@onready var focus_value: Label = %FocusValue
@onready var status_value: Label = %StatusValue
@onready var layer_value: Label = %LayerValue
@onready var layer_card: PanelContainer = %LayerCard


func _ready() -> void:
	_apply_hud_mode()
	_update_hud()


func _process(_delta: float) -> void:
	_update_hud()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in_demo"):
		camera_controller.zoom_in()
	elif event.is_action_pressed("zoom_out_demo"):
		camera_controller.zoom_out()
	elif event.is_action_pressed("toggle_scroll_scale_demo"):
		parallax_manager.toggle_scroll_scale_labels()
		_last_focus_key = "scroll_scale comparison"
	elif event.is_action_pressed("toggle_repeat_guides_demo"):
		parallax_manager.toggle_repeat_guides()
		_last_focus_key = "repeat_size guide"
	elif event.is_action_pressed("toggle_offset_demo"):
		parallax_manager.cycle_offset_mode()
		_last_focus_key = "scroll_offset demo"
	elif event.is_action_pressed("toggle_repeat_times_demo"):
		parallax_manager.cycle_repeat_mode()
		_last_focus_key = "repeat_times zoom-out support"
	elif event.is_action_pressed("reset_demo"):
		camera_controller.reset_to_origin()
		parallax_manager.reset_demo()
		_last_focus_key = "scroll_scale comparison"
	elif event.is_action_pressed("toggle_hud_detail_demo"):
		show_detailed_hud = not show_detailed_hud
		_apply_hud_mode()
	_update_hud()


func _apply_hud_mode() -> void:
	layer_card.visible = show_detailed_hud


func _update_hud() -> void:
	focus_value.text = "\n".join([
		"目前主題: %s" % _last_focus_key,
		"建議觀察: 左右移動鏡頭，再用 W / S 調整 zoom"
	])

	status_value.text = "\n".join([
		"camera x: %.0f" % camera_controller.position.x,
		"zoom: %.2f" % camera_controller.zoom.x,
		"scroll_offset: %s" % parallax_manager.get_offset_mode_name(),
		"repeat_times: %s" % parallax_manager.get_repeat_mode_name(),
		"layer labels [1]: %s" % _on_off(parallax_manager.show_scroll_scale_labels),
		"repeat guides [2]: %s" % _on_off(parallax_manager.show_repeat_guides)
	])

	layer_value.text = "\n".join(parallax_manager.get_layer_lines())


func _on_off(value: bool) -> String:
	return "ON" if value else "OFF"
