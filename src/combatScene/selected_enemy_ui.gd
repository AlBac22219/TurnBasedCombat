extends Control

@export var enemy_icon: TextureRect
@export var enemy_hp_bar: ProgressBar
@export var max_hp_label: Label
@export var hp_label: Label
@export var enemy_name_label: Label
@export var enemy_status_grid_container: GridContainer

func set_selected(enemy: Monster):
	clear_all()
	if enemy:
		visible = true
		enemy_icon.texture = enemy.iconTexture
		enemy_hp_bar.max_value = enemy.character_stat.max_hp
		max_hp_label.text = str(enemy.character_stat.max_hp)
		enemy_hp_bar.value = enemy.hp
		hp_label.text = str(enemy.hp)
		enemy_name_label.text = enemy.character_stat.character_name
	else :
		visible = false

func clear_all():
	enemy_icon.texture = null
	enemy_hp_bar.value = 0
	if enemy_status_grid_container.get_child_count() > 0:
		while enemy_status_grid_container.get_child_count() > 0:
			enemy_status_grid_container.get_child(0).queue_free()
			enemy_status_grid_container.remove_child(enemy_status_grid_container.get_child(0))
