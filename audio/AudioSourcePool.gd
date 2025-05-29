extends Node

var i : int
func play(audio_source: String) -> void:
	var node = get_node(audio_source)
	var count = node.get_child_count()
	i = (i + 1) % count
	var source = node.get_child(i)
	source.playing = true

