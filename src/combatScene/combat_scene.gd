extends Node3D

signal victory

@export_subgroup("Test_groups")
@export var test_party: Array[PackedScene]
@export var test_monsters: Array[PackedScene]
@export var level_floor: MeshInstance3D
@export_category("Parties_nodes")
@export_subgroup("Parties_groups")
@export var partyNode: Node3D
@export var monstersNode: Node3D
@export_subgroup("Parties_spawngroups")
@export var partySpawnMarkers: Node3D
@export var monstersSpawnMarkers: Node3D
@export_category("UI")
@export_subgroup("UI")
@export var battle_queue_ui: Control
@export var party_stats: Control
@export var camera: Camera3D
@export_category("Selection_node")
@export_subgroup("Selection_node")
@export var selection_manager: Node3D

var action_queu: Dictionary
var player_turn: bool = false
var selected_char: PartyCharacter = null

# Called when the node enters the scene tree for the first time.
func _ready():
	init(test_party, test_monsters)
	make_queue()
	select_active_char()

func init(party: Array[PackedScene], monsters: Array[PackedScene]):
	var party_spawn_markers = partySpawnMarkers.get_children()
	var monsters_spawn_markers = monstersSpawnMarkers.get_children()
	if party.size()>0:
		for i in range(party.size()):
			var player_character = party[i]
			var character = player_character.instantiate()
			character.init(party_spawn_markers[i])
			character.connect("change_state", _change_selection_mode)
			partyNode.add_child(character)
	party_stats.init(partyNode.get_children())
	if monsters.size()>0:
		for i in range(monsters.size()):
			var monster_inst = monsters[i]
			var monster = monster_inst.instantiate()
			monster.init(monsters_spawn_markers[i])
			monster.connect("died", monster_died)
			monstersNode.add_child(monster)
	monstersNode.global_position.x = partyNode.get_child(0).global_position.x
	level_floor.global_position.x = partyNode.get_child(0).global_position.x

func make_queue():
	var monsters_array: Array = monstersNode.get_children()
	var party_array: Array = partyNode.get_children()
	for i in party_array:
		var speed = randi_range(0, 20)
		if speed != 0:
			speed += i.character_stat.speed
		action_queu[i] = speed
	for i in monsters_array:
		var speed = randi_range(0, 20)
		if speed != 0:
			speed += i.character_stat.speed
		action_queu[i] = speed
	bubble_sort_dict()

func bubble_sort_dict():
	var action_queue_speeds: Array = action_queu.values()
	var action_queue_keys: Array = action_queu.keys()
	var swapped = true
	while swapped:
		swapped = false
		for i in range(action_queue_speeds.size()-1):
			if action_queue_speeds[i] > action_queue_speeds[i+1]:
				var t = action_queue_speeds[i]
				action_queue_speeds[i] = action_queue_speeds[i+1]
				action_queue_speeds[i+1] = t
				t = action_queue_keys[i]
				action_queue_keys[i] = action_queue_keys[i+1]
				action_queue_keys[i+1] = t
				swapped = true
	var new_dict: Dictionary
	for i in range(action_queue_keys.size()):
		new_dict[action_queue_keys[i]] = action_queue_speeds[i]
	action_queu = new_dict

func select_active_char():
	var queue_keys: Array = action_queu.keys()
	while true:
		selected_char = null
		battle_queue_ui.update(queue_keys)
		if queue_keys[-1] is PartyCharacter:
			monstersNode.global_position.x = queue_keys[-1].global_position.x
			level_floor.global_position.x = queue_keys[-1].global_position.x
			monstersSpawnMarkers.global_position.x = queue_keys[-1].global_position.x
			selected_char = queue_keys[-1]
			selection_manager.get_selected_enemies()
			selection_manager.change_ui_visibiliti(true)
			_change_selection_mode(selected_char.last_button)
			player_turn = true
		else :
			monstersNode.global_position.x = 0
			level_floor.global_position.x = 0
			monstersSpawnMarkers.global_position.x = 0
			player_turn = false
			selection_manager.change_ui_visibiliti(false)
		selection_manager.update()
		queue_keys[-1].select(camera)
		await queue_keys[-1].complete_turn
		party_stats.update(partyNode.get_children())
		if monstersNode.get_child_count() == 0:
			victory.emit()
			break
		if partyNode.get_child_count() == 0:
			break
		queue_keys = move_queue(queue_keys)

func move_queue(queue: Array):
	var new_queue: Array
	var updated_queue: Array = action_queu.keys()
	new_queue.append(queue[-1])
	for i in range(queue.size()-1):
		if queue[i] in updated_queue:
			new_queue.append(queue[i])
	return new_queue

func monster_died(monster: Monster):
	var i = 0
	for m in monstersNode.get_children():
		if monster == m:
			break
		i += 1
	action_queu.erase(monstersNode.get_child(i))
	monstersNode.remove_child(monstersNode.get_child(i))
	selection_manager.monster_died()
	if monstersNode.get_child_count()>0:
		reposition_enemies()
	else:
		victory.emit()

func reposition_enemies():
	for i in range(monstersNode.get_child_count()):
		monstersNode.get_child(i).init(monstersSpawnMarkers.get_child(i))

func _on_selectons_change_selected_enemies(monsters_array: Array[Monster]):
	if selected_char:
		selected_char.selected_enemy_arr = monsters_array

func _change_selection_mode(mode: PartyCharacter.buttons_states):
	selection_manager.change_selection_mode(mode)
