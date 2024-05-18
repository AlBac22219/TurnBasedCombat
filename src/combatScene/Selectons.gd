extends Node3D

signal change_selected_enemies(monsters_arra: Array[Monster])

@export var monstersSpawnNode: Node3D
@export var one_selection: Node3D
@export var three_selection: Node3D
@export var all_selection: Node3D
@export var monstersNode: Node3D

enum selections_modes{ONE, THREE, ALL}

var selection_mode: selections_modes = selections_modes.ALL
var player_turn: bool = true
var selected_enemy:int = 0

func _move_to(to: Marker3D):
	match selection_mode:
		selections_modes.ONE:
			three_selection.visible = false
			all_selection.visible = false
			one_selection.visible = true
			one_selection.global_position = to.global_position
		selections_modes.THREE:
			three_selection.visible = true
			all_selection.visible = false
			one_selection.visible = false
			for i in three_selection.get_children():
				i.visible = true
			var neigborhoods_id = _get_marker_neiborhoods_id(_search_marker_id(to))
			if neigborhoods_id.size() == 1:
				selection_mode = selections_modes.ONE
				_move_to(to)
			elif neigborhoods_id.size() == 2:
				if neigborhoods_id[0] == _search_marker_id(to):
					three_selection.get_child(0).visible = false
					three_selection.get_child(1).move_to(monstersSpawnNode.get_child(neigborhoods_id[0]))
					three_selection.get_child(2).move_to(monstersSpawnNode.get_child(neigborhoods_id[1]))
				else:
					three_selection.get_child(0).move_to(monstersSpawnNode.get_child(neigborhoods_id[0]))
					three_selection.get_child(1).move_to(monstersSpawnNode.get_child(neigborhoods_id[1]))
					three_selection.get_child(2).visible = false
			else :
				var id = 0
				for i in three_selection.get_children():
					i.move_to(monstersSpawnNode.get_child(neigborhoods_id[id]))
					id += 1
		selections_modes.ALL:
			for i in all_selection.get_children():
				i.visible = true
			three_selection.visible = false
			all_selection.visible = true
			one_selection.visible = false
			for i in range(monstersSpawnNode.get_child_count()):
				if i < monstersNode.get_child_count():
					all_selection.get_child(i).move_to(monstersSpawnNode.get_child(i))
				else:
					all_selection.get_child(i).visible = false

func _search_marker_id(to: Marker3D) -> int:
	var i: int = 0
	for m in monstersSpawnNode.get_children():
		if to == m:
			break
		i += 1
	return i

func _get_marker_neiborhoods_id(marker_id: int) -> Array[int]:
	var left: int = marker_id - 1
	var right: int = marker_id + 1
	var result: Array[int] = []
	if left >= 0:
		result.append(left)
	result.append(marker_id)
	if right < monstersSpawnNode.get_child_count() and right < monstersNode.get_child_count():
		result.append(right)
	return result

func _unhandled_input(event):
	if player_turn:
		if monstersNode.get_child_count() > 0:
			if event.is_action_pressed("next_enemy"):
				if selected_enemy + 1 < monstersNode.get_child_count():
					selected_enemy += 1
				else:
					selected_enemy = 0
				_move_to(monstersSpawnNode.get_child(selected_enemy))
			elif event.is_action_pressed("last_enemy"):
				if selected_enemy - 1 > -1:
					selected_enemy -= 1
				else:
					selected_enemy = monstersNode.get_child_count() - 1
				_move_to(monstersSpawnNode.get_child(selected_enemy))

func _get_monsters_neiborhood() -> Array[int]:
	var left: int = selected_enemy - 1
	var right: int = selected_enemy + 1
	var result: Array[int] = []
	if left >= 0:
		result.append(left)
	result.append(selected_enemy)
	if right < monstersNode.get_child_count():
		result.append(right)
	return result

func get_selected_enemies():
	var result: Array[Monster] = []
	match selection_mode:
		selections_modes.ONE:
			result.append(monstersNode.get_child(selected_enemy))
		selections_modes.THREE:
			var monsters_id: Array[int] = _get_monsters_neiborhood()
			for i in monsters_id:
				result.append(monstersNode.get_child(i))
		selections_modes.ALL:
			for i in monstersNode.get_children():
				result.append(i)
	emit_signal("change_selected_enemies", result)

func monster_died():
	if selected_enemy >= monstersNode.get_child_count():
		selected_enemy -= 1
		_move_to(monstersSpawnNode.get_child(selected_enemy))

func update():
	_move_to(monstersSpawnNode.get_child(selected_enemy))
