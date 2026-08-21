extends Node
## DialogueSystem (Autoload)
## Mesin dialog data-driven: membaca file JSON berisi node-node dialog
## (speaker, lines, choices, action opsional) dan mengarahkan alurnya.
## UI (DialogueBox) berlangganan signal-signal di bawah untuk menampilkan teks.

signal dialogue_started(speaker: String)
signal dialogue_line_shown(speaker: String, line: String)
signal dialogue_choices_shown(choices: Array)
signal dialogue_ended

var current_dialogue: Dictionary = {}
var current_node_id: String = ""
var current_line_index: int = 0
var is_active: bool = false

func start_dialogue(json_path: String, start_node: String = "start") -> void:
	if not FileAccess.file_exists(json_path):
		push_error("[ERROR] File dialog tidak ditemukan: " + json_path)
		return

	var file := FileAccess.open(json_path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(content) != OK:
		push_error("[ERROR] Dialog JSON tidak valid: " + json_path)
		return

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[ERROR] Root dialog JSON harus berupa object: " + json_path)
		return

	current_dialogue = data
	is_active = true

	# Fallback aman: kalau node yang diminta tidak ada di file ini
	# (misalnya quest belum sinkron), jatuh ke "start" alih-alih crash.
	var node_to_show := start_node
	if not current_dialogue.has(node_to_show):
		push_warning("[WARN] Node '%s' tidak ada di %s, fallback ke 'start'." % [start_node, json_path])
		node_to_show = "start"

	_show_node(node_to_show)

func _show_node(node_id: String) -> void:
	if not current_dialogue.has(node_id):
		push_error("[ERROR] Node dialog tidak ditemukan: " + node_id)
		end_dialogue()
		return

	current_node_id = node_id
	current_line_index = 0
	var node: Dictionary = current_dialogue[node_id]
	dialogue_started.emit(node.get("speaker", ""))
	_show_current_line()

func _show_current_line() -> void:
	var node: Dictionary = current_dialogue[current_node_id]
	var lines: Array = node.get("lines", [])
	if current_line_index < lines.size():
		dialogue_line_shown.emit(node.get("speaker", ""), lines[current_line_index])
	else:
		_resolve_node_end(node)

## Dipanggil UI saat pemain tap layar / tombol "lanjut".
func advance() -> void:
	if not is_active:
		return
	current_line_index += 1
	_show_current_line()

func _resolve_node_end(node: Dictionary) -> void:
	if node.has("action"):
		_run_action(str(node["action"]))

	var choices: Array = node.get("choices", [])
	if choices.size() > 0:
		dialogue_choices_shown.emit(choices)
	else:
		end_dialogue()

## Dipanggil UI saat pemain memilih salah satu opsi dialog.
func choose(choice_index: int) -> void:
	var node: Dictionary = current_dialogue[current_node_id]
	var choices: Array = node.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		push_error("[ERROR] Index pilihan dialog di luar jangkauan.")
		return
	var next_node: String = choices[choice_index].get("next", "")
	if next_node == "":
		end_dialogue()
	else:
		_show_node(next_node)

func _run_action(action: String) -> void:
	var parts := action.split(":")
	if parts.size() != 2:
		push_warning("[WARN] Format action dialog tidak dikenali: " + action)
		return
	var command := parts[0]
	var target := parts[1]
	match command:
		"start_quest":
			QuestSystem.start_quest(target)
		"complete_quest":
			QuestSystem.complete_quest(target)
		"set_flag":
			GameManager.set_flag(target)
		_:
			push_warning("[WARN] Action dialog tidak dikenali: " + action)

func end_dialogue() -> void:
	is_active = false
	current_dialogue = {}
	current_node_id = ""
	dialogue_ended.emit()
