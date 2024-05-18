extends Resource

class_name character_stats

@export var character_name: String
@export var speed: int
@export var max_hp: int
@export var max_ult_energy: float
@export var attack_energy: float
@export var skill_energy: float
@export var attack_damage: float
@export var skill_damage: float
@export var ult_damage: float
@export_range(0.0, 100.0, 0.1) var base_crit_rate: float = 5.0
@export_range(0.0, 5000.0, 0.1) var base_crit_damage: float = 50.0
