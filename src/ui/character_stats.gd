extends Control

class_name CharacterStatsUI

@export var hp_bar: ProgressBar
@export var shieldBar: ProgressBar
@export var ultBar: ProgressBar
@export var ult_icon: TextureRect
@export var name_label: Label
@export var char_icon: TextureRect

func init(hp: float, hp_max: float, shield: float, ult_energy: float, max_ult_energy: float, char_name: String, char_icon_texture: Texture2D, ult_icon_text: Texture2D):
	hp_bar.max_value = hp_max
	hp_bar.value = hp
	shieldBar.value = shield
	ultBar.max_value = max_ult_energy
	ultBar.value = ult_energy
	name_label.text = char_name
	char_icon.texture = char_icon_texture
	ult_icon.texture = ult_icon_text

func update(hp: float, shield:float, ult_energy: float):
	hp_bar.value = hp
	shieldBar.value = shield
	ultBar.value = ult_energy
	if ultBar.value >= ultBar.max_value:
		ult_icon.material.set_shader_parameter("Enable", true)
	else:
		ult_icon.material.set_shader_parameter("Enable", false)
