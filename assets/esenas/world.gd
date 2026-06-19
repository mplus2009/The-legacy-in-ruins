func _ready():
	# ... tu código existente
	
	# Esperar a que todo cargue
	await get_tree().process_frame
	
	# Cargar el debug
	var debug = preload("res://scripts/utils/debug_tree.gd").new()
	
	print("\n=== ÁRBOL COMPLETO ===")
	debug.print_tree(get_tree().root)
	
	print("\n=== INFO DEL JUGADOR ===")
	debug.print_player_info()
	
	print("\n=== INTERACTUABLES ===")
	debug.print_interactables(get_tree().root)
	
	print("\n=== VERIFICANDO CAMA ===")
	debug.check_bed_structure()
