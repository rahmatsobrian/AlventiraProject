extends Node
## SaveSystem (Autoload)
## Save/load lokal berbasis JSON di user://saves/.
## Penulisan dilakukan secara atomik (tulis ke .tmp lalu rename) supaya
## save tidak corrupt kalau aplikasi ditutup paksa di tengah proses simpan.

const SAVE_DIR := "user://saves/"
const AUTOSAVE_SLOT := "autosave"
const SAVE_FORMAT_VERSION := 1

signal save_completed(slot: String)
signal load_completed(slot: String)
signal save_failed(slot: String, reason: String)
signal load_failed(slot: String, reason: String)

func _ready() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
		print("[INFO] Folder save dibuat: " + SAVE_DIR)

func save_game(slot: String = "slot1") -> bool:
	var save_data := {
		"version": SAVE_FORMAT_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"player_data": GameManager.player_data,
		"inventory": GameManager.inventory,
		"quest_log": GameManager.quest_log,
		"flags": GameManager.flags,
	}
	var json_string := JSON.stringify(save_data, "\t")
	var tmp_path := SAVE_DIR + slot + ".save.tmp"
	var final_name := slot + ".save"

	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		var reason := "Gagal membuka file sementara: " + tmp_path
		push_error("[ERROR] " + reason)
		save_failed.emit(slot, reason)
		return false
	file.store_string(json_string)
	file.close()

	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		var reason2 := "Folder save tidak dapat diakses: " + SAVE_DIR
		push_error("[ERROR] " + reason2)
		save_failed.emit(slot, reason2)
		return false

	# Tulis atomik: hapus save lama baru rename .tmp -> final, supaya
	# tidak pernah ada state "setengah tertulis" di file final.
	if dir.file_exists(final_name):
		dir.remove(final_name)
	dir.rename(slot + ".save.tmp", final_name)

	print("[INFO] Save berhasil: " + slot)
	save_completed.emit(slot)
	return true

func load_game(slot: String = "slot1") -> bool:
	var path := SAVE_DIR + slot + ".save"
	if not FileAccess.file_exists(path):
		var reason := "Save tidak ditemukan: " + path
		push_warning("[WARN] " + reason)
		load_failed.emit(slot, reason)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var reason2 := "Gagal membuka save: " + path
		push_error("[ERROR] " + reason2)
		load_failed.emit(slot, reason2)
		return false

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(content)
	if parse_result != OK:
		var reason3 := "Save corrupt / JSON tidak valid: " + path
		push_error("[ERROR] " + reason3)
		load_failed.emit(slot, reason3)
		return false

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY or not data.has("player_data"):
		var reason4 := "Format save tidak dikenali: " + path
		push_error("[ERROR] " + reason4)
		load_failed.emit(slot, reason4)
		return false

	GameManager.player_data = data.get("player_data", GameManager.player_data)
	GameManager.inventory = data.get("inventory", [])
	GameManager.quest_log = data.get("quest_log", {})
	GameManager.flags = data.get("flags", {})

	print("[INFO] Save berhasil dimuat: " + slot)
	load_completed.emit(slot)
	return true

func has_save(slot: String = "slot1") -> bool:
	return FileAccess.file_exists(SAVE_DIR + slot + ".save")

func autosave() -> void:
	save_game(AUTOSAVE_SLOT)

func list_save_slots() -> Array:
	var slots: Array = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".save"):
				slots.append(file_name.replace(".save", ""))
			file_name = dir.get_next()
		dir.list_dir_end()
	return slots

func delete_save(slot: String) -> void:
	var dir := DirAccess.open(SAVE_DIR)
	if dir and dir.file_exists(slot + ".save"):
		dir.remove(slot + ".save")
		print("[INFO] Save dihapus: " + slot)
