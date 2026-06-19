# ============================================
# TELETRANSPORTE POR PUERTA
# ============================================
func teleport_to_zone_by_door(zone_name: String, target_door_id: String):
	print("🚪 Teletransportando a zona: ", zone_name, " → Puerta: ", target_door_id)
	
	is_transitioning = true
	
	# Buscar la zona
	var zone = _find_zone(zone_name)
	if not zone:
		print("❌ Zona no encontrada: ", zone_name)
		is_transitioning = false
		return
	
	# Buscar la puerta destino dentro de la zona
	var target_door = _find_door_in_zone(zone, target_door_id)
	
	if target_door:
		# Posicionar al jugador en la puerta destino
		player.global_position = target_door.global_position + Vector2(0, 50)
		print("📍 Jugador posicionado en: ", target_door.name)
	else:
		# Si no encuentra la puerta, usar SpawnPoint
		print("⚠️ Puerta destino no encontrada: ", target_door_id, " - Usando SpawnPoint")
		var spawn = zone.get_node("SpawnPoint")
		if spawn:
			player.global_position = spawn.global_position
		else:
			print("❌ No hay SpawnPoint en la zona")
			is_transitioning = false
			return
	
	# Configurar cámara según la zona
	_configure_camera_for_zone(zone)
	
	# Actualizar zona actual
	current_zone = zone_name
	
	is_transitioning = false
	print("✅ Transición completada a: ", zone_name)

func _find_door_in_zone(zone: Node2D, door_id: String) -> Node2D:
	# Buscar recursivamente en la zona
	for child in zone.get_children():
		if child.name == door_id:
			return child
		# Buscar en hijos del hijo
		for subchild in child.get_children():
			if subchild.name == door_id:
				return subchild
	return null
