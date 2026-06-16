extends Label

var visible_time = 0

func _ready():
	modulate.a = 1.0

func _process(delta):
	visible_time += delta
	# Parpadeo cada 0.8 segundos
	var alpha = (sin(visible_time * 8) + 1) / 2
	modulate.a = 0.4 + alpha * 0.6
