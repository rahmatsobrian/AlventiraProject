extends StaticBody2D
class_name NPC
## NPC yang bisa diajak bicara. Node dialog awal otomatis disesuaikan
## dengan status quest terkait (belum mulai / sedang berjalan / selesai)
## supaya NPC tidak mengulang dialog yang sama terus-menerus.

@export var npc_name: String = "NPC"
@export var dialogue_path: String = ""
@export var quest_id: String = ""
@export_group("Node dialog per status quest (opsional)")
@export var node_not_started: String = "start"
@export var node_active_incomplete: String = "quest_reminder"
@export var node_active_complete: String = "quest_complete"
@export var node_completed: String = "after_quest"
@export var required_flag_for_complete: String = ""

func interact() -> void:
	if dialogue_path == "":
		push_warning("[WARN] NPC %s tidak punya dialogue_path." % npc_name)
		return

	var start_node := node_not_started
	if quest_id != "":
		var status := GameManager.get_quest_status(quest_id)
		if status == "active":
			if required_flag_for_complete != "" and GameManager.get_flag(required_flag_for_complete):
				start_node = node_active_complete
			else:
				start_node = node_active_incomplete
		elif status == "completed":
			start_node = node_completed

	DialogueSystem.start_dialogue(dialogue_path, start_node)
