extends Control
class_name TouchJoystick
## Virtual joystick untuk Android. "Base" adalah lingkaran diam di posisi
## tetap (pojok kiri bawah layar), "Knob" adalah lingkaran kecil yang
## mengikuti jari pemain, dibatasi radius knob_max_distance.

signal direction_changed(dir: Vector2)

@export var knob_max_distance: float = 40.0

@onready var base: Control = $Base
@onready var knob: Control = $Base/Knob

var touch_index: int = -1
var base_center: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	base.mouse_filter = Control.MOUSE_FILTER_STOP
	base_center = base.size / 2.0
	_reset_knob()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			touch_index = event.index
			_update_knob(event.position)
			accept_event()
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			_reset_knob()
			accept_event()
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_knob(event.position)
			accept_event()

func _update_knob(local_pos: Vector2) -> void:
	var offset: Vector2 = local_pos - base_center
	if offset.length() > knob_max_distance:
		offset = offset.normalized() * knob_max_distance
	knob.position = base_center + offset - knob.size / 2.0
	var dir := Vector2.ZERO
	if knob_max_distance > 0.0:
		dir = offset / knob_max_distance
	direction_changed.emit(dir)

func _reset_knob() -> void:
	knob.position = base_center - knob.size / 2.0
	direction_changed.emit(Vector2.ZERO)
