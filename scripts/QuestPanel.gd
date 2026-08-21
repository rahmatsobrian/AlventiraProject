extends Control
class_name QuestPanel

@onready var quest_list: VBoxContainer = $Panel/VBox/QuestList
@onready var close_button: Button = $Panel/VBox/CloseButton

func _ready() -> void:
	UIManager.register_panel("quest_log", self)
	close_button.pressed.connect(func(): UIManager.close_all())
	QuestSystem.quest_started.connect(func(_id): _refresh())
	QuestSystem.quest_completed.connect(func(_id): _refresh())
	visibility_changed.connect(func():
		if visible:
			_refresh()
	)
	_refresh()

func _refresh() -> void:
	for child in quest_list.get_children():
		child.queue_free()

	var has_any := false
	for quest_id in GameManager.quest_log.keys():
		has_any = true
		var status: String = GameManager.quest_log[quest_id]["status"]
		var label := Label.new()
		var status_text := "Selesai" if status == "completed" else "Sedang berjalan"
		label.text = "[%s] %s\n%s" % [status_text, QuestSystem.get_quest_title(quest_id), QuestSystem.get_quest_description(quest_id)]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		quest_list.add_child(label)

	if not has_any:
		var empty_label := Label.new()
		empty_label.text = "Belum ada quest yang diterima."
		quest_list.add_child(empty_label)
