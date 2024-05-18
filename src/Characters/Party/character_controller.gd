extends Control

signal attack
signal skill
signal ultimate

@export var icon: TextureRect
@export var ultimate_skill_button: TextureButton
@export var skill_button: TextureButton
@export var attack_button: TextureButton
@export var ultimate_progress_bar: ProgressBar
@export var ultimate_particles: GPUParticles2D
@export var name_label: Label

func init(icon_of_character: Texture2D, skill_textures: Skill_textures, ultimate_energy: float, ultimate_max_energy: float, char_name: String):
	icon.texture = icon_of_character
	ultimate_skill_button.texture_normal = skill_textures.ultimate_on_texture
	ultimate_skill_button.texture_pressed = skill_textures.ultimate_on_texture
	ultimate_skill_button.texture_disabled = skill_textures.ultimate_off_texture
	ultimate_progress_bar.max_value = ultimate_max_energy
	ultimate_progress_bar.value = ultimate_energy
	change_ultimate_disabled()
	attack_button.texture_normal = skill_textures.attack_texture
	attack_button.texture_pressed = skill_textures.attack_texture
	skill_button.texture_normal = skill_textures.skill_texture
	skill_button.texture_pressed = skill_textures.skill_texture
	name_label.text = char_name

func add_energy(how_much: float):
	ultimate_progress_bar.value += how_much
	change_ultimate_disabled()

func set_energy(to: float):
	ultimate_progress_bar.value = to
	change_ultimate_disabled()

func change_ultimate_disabled():
	if ultimate_progress_bar.value < ultimate_progress_bar.max_value:
		ultimate_skill_button.disabled = true
		ultimate_particles.emitting = false
		ultimate_particles.visible = false
	else :
		ultimate_skill_button.disabled = false
		ultimate_particles.emitting = true
		ultimate_particles.visible = true

func _on_ultimate_skill_button_pressed():
	ultimate.emit()

func _on_skill_button_pressed():
	skill.emit()

func _on_attack_button_pressed():
	attack.emit()
