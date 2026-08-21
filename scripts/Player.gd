extends CharacterBody2D
class_name Player
## Kontrol utama karakter pemain (Kael). Menerima input dari TouchControls
## (bukan langsung dari keyboard), supaya kontrolnya sudah dirancang untuk
## touchscreen sesuai kebutuhan game ini.

const SPEED := 90.0

signal attack_performed
signal interact_pressed

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var attack_area: Area2D = $AttackArea

var move_input := Vector2.ZERO
var is_attacking := false
var nearby_interactable: Node = null

func _ready() -> void:
	add_to_group("player")
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	interact_area.area_entered.connect(_on_interact_area_area_entered)
	interact_area.area_exited.connect(_on_interact_area_area_exited)
	GameManager.player_died.connect(_on_player_died)

func _physics_process(_delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = move_input * SPEED
	move_and_slide()
	_update_animation()

func _update_animation() -> void:
	if velocity.length() < 5.0:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
		return
	if animated_sprite.animation != "walk":
		animated_sprite.play("walk")
	if abs(velocity.x) > 1.0:
		animated_sprite.flip_h = velocity.x < 0

func set_move_input(dir: Vector2) -> void:
	move_input = dir

func do_attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	animated_sprite.play("attack")
	attack_performed.emit()
	attack_area.monitoring = true
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(attack_area):
		attack_area.monitoring = false
	await get_tree().create_timer(0.2).timeout
	is_attacking = false

func do_interact() -> void:
	interact_pressed.emit()
	if nearby_interactable and nearby_interactable.has_method("interact"):
		nearby_interactable.interact()

func take_hit(amount: int) -> void:
	GameManager.take_damage(amount)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		var dmg: int = int(GameManager.player_data["attack"]) + randi_range(-2, 3)
		body.take_damage(dmg)

func _on_interact_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_interactable = area.get_parent()

func _on_interact_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("interactable") and area.get_parent() == nearby_interactable:
		nearby_interactable = null

func _on_player_died() -> void:
	print("[INFO] Player kalah. Memuat autosave terakhir jika ada...")
	if SaveSystem.has_save("autosave"):
		SaveSystem.load_game("autosave")
	GameManager.player_data["hp"] = GameManager.player_data["max_hp"]
	global_position = Vector2.ZERO
