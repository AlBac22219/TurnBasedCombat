extends Control

@export var vbox_container: VBoxContainer

func update(queue: Array):
	clear_queue()
	var queue_size = queue.size() - 1
	while queue_size >= 0:
		var textureRect: TextureRect = TextureRect.new()
		textureRect.texture = queue[queue_size].iconTexture
		textureRect.expand_mode =TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		vbox_container.add_child(textureRect)
		queue_size -= 1

func clear_queue():
	while vbox_container.get_child_count() > 0:
		vbox_container.get_child(0).queue_free()
		vbox_container.remove_child(vbox_container.get_child(0))
