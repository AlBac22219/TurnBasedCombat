extends Control

@export var char_stats_packed_scene: PackedScene
@export var hbox_cont: HBoxContainer

func init(party_array: Array):
	if party_array.size() > 0:
		for i in party_array:
			var char_stat = char_stats_packed_scene.instantiate()
			char_stat.init(i.hp, i.character_stat.max_hp, i.shield, i.ultimate_energy, i.character_stat.max_ult_energy, i.character_stat.character_name, i.iconTexture, i.skill_textures.ultimate_on_texture)
			hbox_cont.add_child(char_stat)

func update(party_array: Array):
	if party_array.size() > 0:
		for i in range(party_array.size()):
			hbox_cont.get_child(i).update(party_array[i].hp, party_array[i].shield, party_array[i].ultimate_energy)
