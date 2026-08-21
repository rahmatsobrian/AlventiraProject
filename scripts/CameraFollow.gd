extends Camera2D
class_name CameraFollow

@export var target_path: NodePath
@export var follow_speed: float = 5.0

var target: Node2D = null

func _ready() -> void:
	if target_path != NodePath(""):
		target = get_node(target_path)

func set_target(node: Node2D) -> void:
	target = node

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	global_position = global_position.lerp(target.global_position, clamp(follow_speed * delta, 0.0, 1.0))
