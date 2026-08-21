extends Control
class_name MainMenu

@onready var new_game_button: Button = $VBox/NewGameButton
@onready var continue_button: Button = $VBox/ContinueButton
@onready var settings_button: Button = $VBox/SettingsButton
@onready var quit_button: Button = $VBox/QuitButton
@onready var settings_panel: Panel = $SettingsPanel
@onready var volume_slider: HSlider = $SettingsPanel/VBox/VolumeSlider
@onready var settings_back_button: Button = $SettingsPanel/VBox/BackButton
@onready var title_label: Label = $TitleLabel

func _ready() -> void:
	settings_panel.visible = false
	continue_button.disabled = not SaveSystem.has_save("slot1") and not SaveSystem.has_save("autosave")
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(func(): settings_panel.visible = true)
	settings_back_button.pressed.connect(func(): settings_panel.visible = false)
	quit_button.pressed.connect(func(): get_tree().quit())
	volume_slider.value_changed.connect(_on_volume_changed)
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

func _on_new_game_pressed() -> void:
	GameManager.reset_new_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_continue_pressed() -> void:
	var slot := "slot1" if SaveSystem.has_save("slot1") else "autosave"
	if SaveSystem.load_game(slot):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_volume_changed(value: float) -> void:
	var db := linear_to_db(max(value, 0.0001))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
