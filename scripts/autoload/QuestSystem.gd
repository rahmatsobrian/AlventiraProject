extends Node
## QuestSystem (Autoload)
## Membaca definisi quest dari data/quests/*.json saat game start,
## lalu mengatur status quest (not_started / active / completed) lewat GameManager.

const QUEST_DATA_DIR := "res://data/quests/"

signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)

var quest_defs: Dictionary = {}

func _ready() -> void:
	_load_all_quest_defs()

func _load_all_quest_defs() -> void:
	var dir := DirAccess.open(QUEST_DATA_DIR)
	if dir == null:
		push_warning("[WARN] Folder data quest tidak ditemukan: " + QUEST_DATA_DIR)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			_load_quest_def(QUEST_DATA_DIR + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	print("[INFO] %d quest definition dimuat." % quest_defs.size())

func _load_quest_def(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[ERROR] Gagal membaca quest: " + path)
		return
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(content) != OK:
		push_error("[ERROR] Quest JSON tidak valid: " + path)
		return
	var data = json.data
	if typeof(data) == TYPE_DICTIONARY and data.has("id"):
		quest_defs[data["id"]] = data
	else:
		push_error("[ERROR] Quest tanpa field 'id': " + path)

func start_quest(quest_id: String) -> void:
	if not quest_defs.has(quest_id):
		push_error("[ERROR] Quest tidak dikenali: " + quest_id)
		return
	if GameManager.get_quest_status(quest_id) != "not_started":
		return
	GameManager.set_quest_status(quest_id, "active")
	quest_started.emit(quest_id)
	print("[INFO] Quest dimulai: " + quest_id)

func complete_quest(quest_id: String) -> void:
	if not quest_defs.has(quest_id):
		push_error("[ERROR] Quest tidak dikenali: " + quest_id)
		return
	if GameManager.get_quest_status(quest_id) != "active":
		return
	var def: Dictionary = quest_defs[quest_id]
	GameManager.player_data["gold"] = int(GameManager.player_data["gold"]) + int(def.get("reward_gold", 0))
	for item in def.get("reward_items", []):
		GameManager.add_item(item["id"], item["name"], item["type"], item.get("quantity", 1))
	GameManager.set_quest_status(quest_id, "completed")
	quest_completed.emit(quest_id)
	print("[INFO] Quest selesai: " + quest_id)

func get_quest_title(quest_id: String) -> String:
	if quest_defs.has(quest_id):
		return quest_defs[quest_id].get("title", quest_id)
	return quest_id

func get_quest_description(quest_id: String) -> String:
	if quest_defs.has(quest_id):
		return quest_defs[quest_id].get("description", "")
	return ""

func get_active_quest_ids() -> Array:
	var result: Array = []
	for qid in GameManager.quest_log.keys():
		if GameManager.quest_log[qid]["status"] == "active":
			result.append(qid)
	return result
