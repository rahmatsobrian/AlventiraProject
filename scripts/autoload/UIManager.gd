extends Node
## UIManager (Autoload)
## Titik pusat untuk toggle panel-panel UI global (inventory, quest log,
## pause menu). Panel-panel itu sendiri hidup di scene UI masing-masing dan
## mendaftar diri ke sini lewat register_panel() saat _ready().

var _panels: Dictionary = {}  # nama -> node Control

func register_panel(panel_name: String, node: Control) -> void:
	_panels[panel_name] = node
	node.visible = false

func toggle_panel(panel_name: String) -> void:
	if not _panels.has(panel_name):
		push_warning("[WARN] Panel UI belum terdaftar: " + panel_name)
		return
	var panel: Control = _panels[panel_name]
	# Tutup panel lain dulu supaya tidak tumpang tindih di layar kecil.
	for key in _panels.keys():
		if key != panel_name:
			_panels[key].visible = false
	panel.visible = not panel.visible
	get_tree().paused = panel.visible and panel_name != "dialogue"

func close_all() -> void:
	for key in _panels.keys():
		_panels[key].visible = false
	get_tree().paused = false

func toggle_inventory() -> void:
	toggle_panel("inventory")

func toggle_quest_log() -> void:
	toggle_panel("quest_log")

func toggle_pause() -> void:
	toggle_panel("pause")

func is_any_panel_open() -> bool:
	for key in _panels.keys():
		if _panels[key].visible:
			return true
	return false
