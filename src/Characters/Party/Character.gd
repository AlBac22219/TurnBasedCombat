extends Marker3D

class_name PartyCharacter

signal complete_turn
signal change_state(state: buttons_states)

@export var mesh: MeshInstance3D
@export var playerController: CanvasLayer
@export var iconTexture: Texture2D
@export var character_controller: Control
@export var camera_marker: Marker3D
@export var skill_textures: Skill_textures
@export var character_stat: character_stats

enum buttons_states {ATACK, SKILL, ULT, NULL}

var last_button: buttons_states = buttons_states.NULL
var selected_enemy: Monster = null
var selected_enemy_arr: Array[Monster] = []
var can_fight: bool = false
var ultimate_energy: float = 0.0
var buffs_array: Array[Array]

# Called when the node enters the scene tree for the first time.
func _ready():
	playerController.visible = false
	character_controller.init(iconTexture, skill_textures, ultimate_energy, character_stat.max_ult_energy, character_stat.character_name)

func init(position_marker: Marker3D):
	self.global_position = position_marker.global_position
	playerController.visible = false
	can_fight = false

func select(camera: Camera3D):
	can_fight = true
	last_button = buttons_states.NULL
	_update_buffs()
	var mesh_material: ShaderMaterial = mesh.get_surface_override_material(0)
	mesh_material.set_shader_parameter("IsSelectd", true)
	playerController.visible = true
	camera.global_position = camera_marker.global_position

func finished_turn():
	last_button = buttons_states.NULL
	can_fight = false
	playerController.visible = false
	var mesh_material: ShaderMaterial = mesh.get_surface_override_material(0)
	mesh_material.set_shader_parameter("IsSelectd", false)

func _atack_enemy(damage: float):
		randomize()
		var final_damage: float = _final_damage_formula(damage)
		var final_crit_rate: float = _final_crit_rate()
		var final_crit_damage: float = _final_crit_damage()
		if selected_enemy_arr.size() > 0:
			for i in selected_enemy_arr:
				if randf_range(0, 1) <= final_crit_rate:
					i.attacked(final_damage * final_crit_damage)
				else:
					i.attacked(final_damage)
			selected_enemy_arr = []

func _final_damage_formula(damage: float) -> float:
	var final_damage: float = damage
	if buffs_array.size() > 0:
		for i in buffs_array:
			final_damage += i[1].damage_buff
		var timed_damag = final_damage
		for i in buffs_array:
			final_damage += timed_damag * (i[1].damage_percent_buff/100)
	return final_damage

func _final_crit_rate() -> float:
	var crit_rate: float = character_stat.base_crit_rate
	if buffs_array.size() > 0:
		for i in buffs_array:
			crit_rate += i[1].crit_rate_buff
	return crit_rate/100

func _final_crit_damage():
	var crit_damage = character_stat.base_crit_damage
	if buffs_array.size() > 0:
		for i in buffs_array:
			crit_damage += i[1].crit_damage_buff
	return (crit_damage/100) + 1.0

func _on_character_controller_attack():
	if last_button == buttons_states.ATACK:
		_atack_enemy(character_stat.attack_damage)
		change_energy(character_stat.attack_energy)
		finished_turn()
		complete_turn.emit()
	else : 
		last_button = buttons_states.ATACK
		emit_signal("change_state", buttons_states.ATACK)

func _on_character_controller_skill():
	if last_button == buttons_states.SKILL:
		_atack_enemy(character_stat.skill_damage)
		change_energy(character_stat.skill_energy)
		finished_turn()
		complete_turn.emit()
	else : 
		last_button = buttons_states.SKILL
		emit_signal("change_state", buttons_states.SKILL)

func _on_character_controller_ultimate():
	if last_button == buttons_states.ULT:
		_atack_enemy(character_stat.ult_damage)
		character_controller.set_energy(0)
		ultimate_energy = 0
		finished_turn()
		complete_turn.emit()
	else:
		last_button = buttons_states.SKILL
		emit_signal("change_state", buttons_states.SKILL)

func change_energy(how_much_add: float):
	character_controller.add_energy(how_much_add)
	if ultimate_energy + how_much_add < character_stat.max_ult_energy:
		ultimate_energy += how_much_add
	else:
		ultimate_energy = character_stat.max_ult_energy

func add_buff(count_of_turns: int, buff: Buff):
	var new_buff = [count_of_turns, buff]
	buffs_array.append(new_buff)

func _update_buffs():
	if buffs_array.size() > 0:
		for i in buffs_array:
			i[0] -= 1
		var i = 0
		while true:
			if buffs_array[i][0] <= 0:
				buffs_array.remove_at(i)
			else:
				i += 1
			if i >= buffs_array.size():
				break
