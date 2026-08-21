extends CanvasLayer
class_name DialogueBox

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/VBox/SpeakerLabel
@onready var line_label: Label = $Panel/VBox/LineLabel
@onready var tap_hint: Label = $Panel/VBox/TapHint
@onready var choices_box: VBoxContainer = $Panel/ChoicesBox

func _ready() -> void:
	panel.visible = false
	choices_box.visible = false
	DialogueSystem.dialogue_started.connect(_on_dialogue_started)
	DialogueSystem.dialogue_line_shown.connect(_on_line_shown)
	DialogueSystem.dialogue_choices_shown.connect(_on_choices_shown)
	DialogueSystem.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(speaker: String) -> void:
	panel.visible = true
	choices_box.visible = false
	speaker_label.text = speaker
	get_tree().paused = true

func _on_line_shown(speaker: String, line: String) -> void:
	speaker_label.text = speaker
	line_label.text = line
	tap_hint.visible = true
	choices_box.visible = false

func _on_choices_shown(choices: Array) -> void:
	tap_hint.visible = false
	choices_box.visible = true
	for child in choices_box.get_children():
		child.queue_free()
	for i in range(choices.size()):
		var btn := Button.new()
		btn.text = str(choices[i].get("text", ""))
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choices_box.add_child(btn)

func _on_choice_pressed(index: int) -> void:
	DialogueSystem.choose(index)

func _on_dialogue_ended() -> void:
	panel.visible = false
	choices_box.visible = false
	get_tree().paused = false

## Tap di mana saja pada panel (di luar tombol pilihan) untuk lanjut baris.
func _on_panel_gui_input(event: InputEvent) -> void:
	if not DialogueSystem.is_active or choices_box.visible:
		return
	var is_tap: bool = false
	if event is InputEventScreenTouch and event.pressed:
		is_tap = true
	elif event is InputEventMouseButton and event.pressed:
		is_tap = true
	if is_tap:
		DialogueSystem.advance()
