extends Resource

class_name Buff

@export_category("HP_buffs")
@export var hp_percent_buff: float
@export var hp_buff: float
@export_category("Damage_buffs")
@export var damage_percent_buff: float
@export var damage_buff: float
@export_category("Crit_buffs")
@export var crit_rate_buff: float
@export var crit_damage_buff: float
@export_category("Elemental_buffs")
@export var element_buff: float
@export var element: elements
@export_category("Elemental_resistance")
@export var resistance_buff: float
@export var resistance_type: elements
@export_category("Defence_buff")
@export var defence_buff: float
@export var defence_percent_buff: float

enum elements {FIRE, WATER, NATURE, EARTH, ALL}
