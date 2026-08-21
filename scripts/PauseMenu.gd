extends Control
class_name PauseMenu

@onready var resume_button: Button = $Panel/VBox/ResumeButton
@onready var save_button: Button = $Panel/VBox/SaveButton
@onready var settings_button: Button = $Panel/VBox/SettingsButton
@onready var main_menu_button: Button = $Panel/VBox/MainMenuButton
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var settings_panel: Panel = $SettingsPanel
@onready var volume_slider: HSlider = $SettingsPanel/VBox/VolumeSlider
@onready var settings_back_button: Button = $SettingsPanel/VBox/BackButton

func _ready() -> void:
	UIManager.register_panel("pause", self)
	settings_panel.visible = false
	resume_button.pressed.connect(func(): UIManager.close_all())
	save_button.pressed.connect(_on_save_pressed)
	settings_button.pressed.connect(func(): settings_panel.visible = true)
	settings_back_button.pressed.connect(func(): settings_panel.visible = false)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

func _on_save_pressed() -> void:
	var ok := SaveSystem.save_game("slot1")
	status_label.text = "Game disimpan." if ok else "Gagal menyimpan!"

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_volume_changed(value: float) -> void:
	var db := linear_to_db(max(value, 0.0001))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
