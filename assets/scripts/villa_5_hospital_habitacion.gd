extends Node2D

func _ready():
	await get_tree().process_frame
	
	# Buscar la cámara
	var world = get_node("/root/World")
	if world and world.has_node("GameCamera"):
		var camera = world.get_node("GameCamera")
		camera.set_follow(false)  # Desactivar seguimiento
		print("📷 Cámara ESTÁTICA en la habitación")
	else:
		print("⚠️ No se encontró la cámara")

func _exit_tree():
	# Restaurar seguimiento al salir
	var world = get_node("/root/World")
	if world and world.has_node("GameCamera"):
		var camera = world.get_node("GameCamera")
		camera.set_follow(true)
		print("📷 Cámara restaurada a SEGUIMIENTO")
