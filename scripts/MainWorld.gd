extends Node2D
## Controller scene dunia (Desa Kayu Embun). Menghubungkan Player ke
## TouchControls & Camera, dan menjalankan autosave berkala serta
## autosave setelah event penting (quest selesai).

const AUTOSAVE_INTERVAL := 60.0

@onready var player: Player = $Player
@onready var touch_controls: TouchControls = $UILayer/TouchControls

var autosave_timer: float = 0.0

func _ready() -> void:
	touch_controls.set_player(player)
	# Catatan: Camera2D adalah anak langsung dari Player di Player.tscn
	# dengan position_smoothing_enabled = true, jadi otomatis mengikuti
	# tanpa perlu script kamera terpisah.

	# Muat kembali posisi terakhir jika ada data save yang sedang aktif.
	player.global_position = Vector2(
		float(GameManager.player_data.get("pos_x", 0.0)),
		float(GameManager.player_data.get("pos_y", 0.0))
	)

	QuestSystem.quest_completed.connect(_on_quest_completed)

func _process(delta: float) -> void:
	autosave_timer += delta
	if autosave_timer >= AUTOSAVE_INTERVAL:
		autosave_timer = 0.0
		_sync_position_and_save()

func _sync_position_and_save() -> void:
	GameManager.player_data["pos_x"] = player.global_position.x
	GameManager.player_data["pos_y"] = player.global_position.y
	SaveSystem.autosave()

func _on_quest_completed(_quest_id: String) -> void:
	_sync_position_and_save()

func _notification(what: int) -> void:
	# Simpan otomatis saat aplikasi ditaruh ke background / ditutup,
	# supaya progres tidak hilang kalau Android mematikan proses tiba-tiba.
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_sync_position_and_save()
