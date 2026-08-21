extends CanvasLayer
class_name TouchControls
## Menghubungkan seluruh input touch (joystick + tombol) ke Player aktif
## dan ke UIManager. Dipasang sebagai CanvasLayer terpisah di atas dunia
## game supaya selalu terlihat & responsif di berbagai ukuran layar.

@onready var joystick: TouchJoystick = $Joystick
@onready var button_attack: Button = $ButtonAttack
@onready var button_interact: Button = $ButtonInteract
@onready var button_inventory: Button = $TopBar/ButtonInventory
@onready var button_quest: Button = $TopBar/ButtonQuest
@onready var button_pause: Button = $TopBar/ButtonPause

var player: Player = null

func _ready() -> void:
	joystick.direction_changed.connect(_on_direction_changed)
	button_attack.pressed.connect(_on_attack_pressed)
	button_interact.pressed.connect(_on_interact_pressed)
	button_inventory.pressed.connect(_on_inventory_pressed)
	button_quest.pressed.connect(_on_quest_pressed)
	button_pause.pressed.connect(_on_pause_pressed)

func set_player(p: Player) -> void:
	player = p

func _on_direction_changed(dir: Vector2) -> void:
	if player and is_instance_valid(player):
		player.set_move_input(dir)

func _on_attack_pressed() -> void:
	if player and is_instance_valid(player) and not UIManager.is_any_panel_open():
		player.do_attack()

func _on_interact_pressed() -> void:
	if player and is_instance_valid(player) and not UIManager.is_any_panel_open():
		player.do_interact()

func _on_inventory_pressed() -> void:
	UIManager.toggle_inventory()

func _on_quest_pressed() -> void:
	UIManager.toggle_quest_log()

func _on_pause_pressed() -> void:
	UIManager.toggle_pause()
