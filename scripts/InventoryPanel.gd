extends Control
class_name InventoryPanel

@onready var item_list: VBoxContainer = $Panel/VBox/ItemList
@onready var close_button: Button = $Panel/VBox/CloseButton

func _ready() -> void:
	UIManager.register_panel("inventory", self)
	close_button.pressed.connect(func(): UIManager.close_all())
	GameManager.inventory_changed.connect(_refresh)
	visibility_changed.connect(func():
		if visible:
			_refresh()
	)
	_refresh()

func _refresh() -> void:
	for child in item_list.get_children():
		child.queue_free()

	if GameManager.inventory.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Inventory masih kosong."
		item_list.add_child(empty_label)
		return

	for entry in GameManager.inventory:
		var row := HBoxContainer.new()

		var name_label := Label.new()
		name_label.text = "%s x%d" % [entry["name"], entry["quantity"]]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)

		if entry.get("type", "") == "consumable":
			var use_button := Button.new()
			use_button.text = "Gunakan"
			use_button.pressed.connect(_on_use_pressed.bind(entry["id"]))
			row.add_child(use_button)

		item_list.add_child(row)

func _on_use_pressed(item_id: String) -> void:
	GameManager.use_item(item_id)
	_refresh()
