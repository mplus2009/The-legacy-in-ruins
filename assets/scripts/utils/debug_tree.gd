extends Node

# ============================================
# FUNCIÓN PRINCIPAL: Mostrar árbol completo
# ============================================
func print_tree(node: Node = null, prefix: String = "", is_last: bool = true):
	if not node:
		node = get_tree().root
	
	# Construir el texto con caracteres de árbol
	var text = prefix
	if prefix != "":
		text += "└── " if is_last else "├── "
	
	# Mostrar información del nodo
	var info = node.name
	
	# Verificar tipo de nodo
	if node is CollisionShape2D:
		var shape_info = ""
		if node.shape:
			shape_info = " (" + node.shape.get_class() + ")"
		info += shape_info
	elif node is Area2D:
		info += " [Area2D]"
	elif node is StaticBody2D:
		info += " [StaticBody2D]"
	elif node is CharacterBody2D:
		info += " [CharacterBody2D]"
	elif node is RayCast2D:
		info += " [RayCast2D]"
	
	# Mostrar capas de colisión si es relevante
	if node.has_method("get_collision_layer"):
		info += " (Layer: " + str(node.collision_layer) + ", Mask: " + str(node.collision_mask) + ")"
	
	print(text + info)
	
	# Recorrer hijos
	var children = node.get_children()
	var child_count = children.size()
	
	for i in range(child_count):
		var child = children[i]
		var is_last_child = (i == child_count - 1)
		var new_prefix = prefix + ("    " if is_last else "│   ")
		print_tree(child, new_prefix, is_last_child)

# ============================================
# FUNCIÓN: Mostrar nodos por capa específica
# ============================================
func print_nodes_by_layer(layer: int, node: Node = null):
	if not node:
		node = get_tree().root
	
	# Verificar si este nodo tiene la capa
	if node.has_method("get_collision_layer"):
		if node.collision_layer & (1 << (layer - 1)):
			print("📌 ", node.get_path(), " - Layer: ", node.collision_layer)
	
	# Recorrer hijos
	for child in node.get_children():
		print_nodes_by_layer(layer, child)

# ============================================
# FUNCIÓN: Mostrar objetos interactuables
# ============================================
func print_interactables(node: Node = null):
	if not node:
		node = get_tree().root
	
	# Verificar si este nodo tiene on_interact
	if node.has_method("on_interact"):
		print("🎯 INTERACTUABLE: ", node.get_path())
	
	# Recorrer hijos
	for child in node.get_children():
		print_interactables(child)

# ============================================
# FUNCIÓN: Verificar estructura de la cama
# ============================================
func check_bed_structure():
	print("🔍 Verificando estructura de la cama...")
	
	# Buscar la cama en toda la escena
	var root = get_tree().root
	var beds = _find_nodes_by_name(root, "Bed")
	
	if beds.size() == 0:
		# Buscar por "cama" en minúscula
		beds = _find_nodes_by_name(root, "cama")
	
	if beds.size() == 0:
		# Buscar cualquier StaticBody2D que pueda ser una cama
		beds = _find_nodes_by_class(root, "StaticBody2D")
	
	for bed in beds:
		print("🛏️ Posible cama encontrada: ", bed.get_path())
		print("   📌 Layer: ", bed.collision_layer)
		print("   📌 Mask: ", bed.collision_mask)
		print("   📌 Hijos:")
		for child in bed.get_children():
			print("      - ", child.name, " (", child.get_class(), ")")
			if child is CollisionShape2D:
				if child.shape:
					print("        📌 Shape: ", child.shape.get_class())
				else:
					print("        📌 Shape: null")

# ============================================
# FUNCIÓN AUXILIAR: Encontrar nodos por nombre
# ============================================
func _find_nodes_by_name(node: Node, name_to_find: String) -> Array:
	var results = []
	
	# Verificar si el nombre coincide (case insensitive)
	if name_to_find.to_lower() in node.name.to_lower():
		results.append(node)
	
	for child in node.get_children():
		results += _find_nodes_by_name(child, name_to_find)
	
	return results

# ============================================
# FUNCIÓN AUXILIAR: Encontrar nodos por clase
# ============================================
func _find_nodes_by_class(node: Node, class_name: String) -> Array:
	var results = []
	
	# Verificar si el nodo es de la clase buscada
	var node_class = node.get_class()
	if node_class == class_name:
		results.append(node)
	
	for child in node.get_children():
		results += _find_nodes_by_class(child, class_name)
	
	return results

# ============================================
# FUNCIÓN: Mostrar capas de colisión
# ============================================
func print_layers_info(node: Node = null):
	if not node:
		node = get_tree().root
	
	if node.has_method("get_collision_layer"):
		var layer = node.collision_layer
		var mask = node.collision_mask
		if layer != 0 or mask != 0:
			print("📌 ", node.name, " - Layer: ", layer, " | Mask: ", mask)
	
	for child in node.get_children():
		print_layers_info(child)

# ============================================
# FUNCIÓN: Mostrar solo el jugador y su RayCast
# ============================================
func print_player_info():
	print("🔍 Buscando jugador...")
	
	var root = get_tree().root
	var players = _find_nodes_by_name(root, "Player")
	
	if players.size() == 0:
		var character_bodies = _find_nodes_by_class(root, "CharacterBody2D")
		for body in character_bodies:
			if "player" in body.name.to_lower():
				players.append(body)
	
	for player in players:
		print("🎮 Jugador encontrado: ", player.get_path())
		
		# Buscar RayCast
		var raycasts = _find_nodes_by_class(player, "RayCast2D")
		for ray in raycasts:
			print("   📌 RayCast: ", ray.name)
			print("      - Enabled: ", ray.enabled)
			print("      - Target: ", ray.target_position)
			print("      - Collision Mask: ", ray.collision_mask)
			print("      - Colliding: ", ray.is_colliding())
			if ray.is_colliding():
				print("      - Collider: ", ray.get_collider().name)
		
		# Buscar Area2D
		var areas = _find_nodes_by_class(player, "Area2D")
		for area in areas:
			print("   📌 Area2D: ", area.name)
			print("      - Layer: ", area.collision_layer)
			print("      - Mask: ", area.collision_mask)
