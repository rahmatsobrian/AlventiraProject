extends CharacterBody2D
class_name Enemy
## Musuh dasar (Fera Liar). AI sederhana: diam sampai player masuk radius
## deteksi, lalu mengejar dan menyerang saat cukup dekat.

@export var enemy_name: String = "Fera Liar"
@export var max_hp: int = 30
@export var attack_damage: int = 8
@export var exp_reward: int = 15
@export var gold_reward: int = 10
@export var move_speed: float = 40.0

var hp: int
var target: Node2D = null
var attack_cooldown: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detect_area: Area2D = $DetectArea

func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	detect_area.body_entered.connect(_on_detect_area_body_entered)
	detect_area.body_exited.connect(_on_detect_area_body_exited)

func _physics_process(delta: float) -> void:
	attack_cooldown = max(0.0, attack_cooldown - delta)

	if target and is_instance_valid(target):
		var dir: Vector2 = (target.global_position - global_position).normalized()
		velocity = dir * move_speed
		move_and_slide()
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		if abs(dir.x) > 0.1:
			animated_sprite.flip_h = dir.x < 0

		if global_position.distance_to(target.global_position) < 20.0 and attack_cooldown <= 0.0:
			_attack_target()
	else:
		velocity = Vector2.ZERO
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func _attack_target() -> void:
	attack_cooldown = 1.2
	if target.has_method("take_hit"):
		target.take_hit(attack_damage)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_die()

func _die() -> void:
	GameManager.gain_exp(exp_reward)
	GameManager.player_data["gold"] = int(GameManager.player_data["gold"]) + gold_reward
	print("[INFO] %s dikalahkan. +%d EXP, +%d Gold" % [enemy_name, exp_reward, gold_reward])
	queue_free()

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body

func _on_detect_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
