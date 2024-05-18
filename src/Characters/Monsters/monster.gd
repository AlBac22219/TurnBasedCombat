extends Marker3D

class_name Monster

signal complete_turn
signal died(monster: Monster)

@export var character_stat: character_stats
@export var camera_marker: Marker3D
@export var test_timer: Timer
@export var iconTexture: Texture2D
@onready var hp: float = character_stat.max_hp

func init(marker_for_position: Marker3D):
	global_position = marker_for_position.global_position

func select(camera: Camera3D):
	camera.global_position = camera_marker.global_position
	test_timer.start(0.2)

func _on_timer_timeout():
	complete_turn.emit()

func attacked(damage):
	hp -= damage
	if hp<=0:
		emit_signal("died", self)
		queue_free()
