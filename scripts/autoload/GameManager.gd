extends Node
## GameManager (Autoload)
## Menyimpan seluruh state runtime pemain: stats, inventory, quest log, flags.
## Dibaca/ditulis oleh SaveSystem, dipakai oleh UI dan sistem combat.

signal player_stats_changed
signal inventory_changed
signal player_died

var player_data: Dictionary = {
	"name": "Kael",
	"level": 1,
	"exp": 0,
	"exp_to_next": 100,
	"hp": 100,
	"max_hp": 100,
	"mp": 30,
	"max_mp": 30,
	"attack": 10,
	"defense": 5,
	"gold": 50,
	"pos_x": 0.0,
	"pos_y": 0.0,
	"current_scene": "res://scenes/Main.tscn",
}

var inventory: Array = []       # [{id, name, type, quantity}]
var quest_log: Dictionary = {}  # quest_id -> {status, step}
var flags: Dictionary = {}      # story flags (mis. "found_goat")

func reset_new_game() -> void:
	player_data = {
		"name": "Kael", "level": 1, "exp": 0, "exp_to_next": 100,
		"hp": 100, "max_hp": 100, "mp": 30, "max_mp": 30,
		"attack": 10, "defense": 5, "gold": 50,
		"pos_x": 0.0, "pos_y": 0.0,
		"current_scene": "res://scenes/Main.tscn",
	}
	inventory.clear()
	quest_log.clear()
	flags.clear()
	print("[INFO] New game state diinisialisasi.")

# --- Inventory ---

func add_item(item_id: String, item_name: String, item_type: String, quantity: int = 1) -> void:
	for entry in inventory:
		if entry["id"] == item_id:
			entry["quantity"] += quantity
			inventory_changed.emit()
			return
	inventory.append({"id": item_id, "name": item_name, "type": item_type, "quantity": quantity})
	inventory_changed.emit()

func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in range(inventory.size()):
		if inventory[i]["id"] == item_id:
			inventory[i]["quantity"] -= quantity
			if inventory[i]["quantity"] <= 0:
				inventory.remove_at(i)
			inventory_changed.emit()
			return true
	return false

func has_item(item_id: String) -> bool:
	for entry in inventory:
		if entry["id"] == item_id:
			return true
	return false

func use_item(item_id: String) -> void:
	if not has_item(item_id):
		return
	match item_id:
		"potion_small":
			heal(30)
			remove_item(item_id, 1)
		_:
			push_warning("[WARN] Item tidak punya efek use terdaftar: " + item_id)

# --- Stats / Combat ---

func take_damage(amount: int) -> void:
	var reduced: int = max(1, amount - player_data["defense"])
	player_data["hp"] = max(0, int(player_data["hp"]) - reduced)
	player_stats_changed.emit()
	if player_data["hp"] <= 0:
		player_died.emit()

func heal(amount: int) -> void:
	player_data["hp"] = min(int(player_data["max_hp"]), int(player_data["hp"]) + amount)
	player_stats_changed.emit()

func gain_exp(amount: int) -> void:
	player_data["exp"] = int(player_data["exp"]) + amount
	while int(player_data["exp"]) >= int(player_data["exp_to_next"]):
		player_data["exp"] = int(player_data["exp"]) - int(player_data["exp_to_next"])
		_level_up()
	player_stats_changed.emit()

func _level_up() -> void:
	player_data["level"] = int(player_data["level"]) + 1
	player_data["max_hp"] = int(player_data["max_hp"]) + 15
	player_data["max_mp"] = int(player_data["max_mp"]) + 5
	player_data["attack"] = int(player_data["attack"]) + 3
	player_data["defense"] = int(player_data["defense"]) + 2
	player_data["hp"] = player_data["max_hp"]
	player_data["mp"] = player_data["max_mp"]
	player_data["exp_to_next"] = int(int(player_data["exp_to_next"]) * 1.25)
	print("[INFO] Level up! Sekarang level %d" % player_data["level"])

# --- Quest state ---

func set_quest_status(quest_id: String, status: String, step: int = 0) -> void:
	quest_log[quest_id] = {"status": status, "step": step}

func get_quest_status(quest_id: String) -> String:
	if quest_log.has(quest_id):
		return quest_log[quest_id]["status"]
	return "not_started"

# --- Flags ---

func set_flag(flag_id: String, value: bool = true) -> void:
	flags[flag_id] = value

func get_flag(flag_id: String) -> bool:
	return flags.get(flag_id, false)
