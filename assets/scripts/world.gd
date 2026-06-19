extends Node2D

# ============================================
# REFERENCIAS
# ============================================
@onready var camera = $Camera2D
@onready var player = $Player
@onready var villes = $villes
@onready var animation_player = $AnimationPlayer
@onready var ui = $UI
@onready var ui_panel = $UI/UIPanel if $UI.has_node("UIPanel") else null
@onready var transition_overlay = $Camera2D/TransitionOverlay  # ColorRect hijo de Camera2D

# ============================================
# VARIABLES
# ============================================
var current_zone = ""
var camera_follows: bool = true
var is_transitioning: bool = false

signal animation_finished

# ============================================
# READY
# ============================================
func _ready():
	print("🌍 World iniciado")
	
	if ui_panel:
		ui_panel.visible = true
		ui_panel.modulate = Color(1, 1, 1, 1)
		print("✅ UI visible")
	
	if transition_overlay:
		transition_overlay.visible = false
		transition_overlay.color = Color(0, 0, 0, 0)
		print("✅ TransitionOverlay encontrado")
	else:
		print("❌ TransitionOverlay NO encontrado")
	
	activate_zone("villa5_hospital_habitacion")
	print("🌍 World listo")

# ============================================
# CÁMARA
# ============================================
func _process(delta):
	if camera and player and camera_follows and not is_transitioning:
		camera.global_position = player.global_position

func set_camera_follows(follows: bool):
	camera_follows = follows
	print("📷 Cámara: ", "SIGUE" if follows else "ESTÁTICA")

func set_camera_position(pos: Vector2):
	if camera:
		camera.global_position = pos
		print("📷 Cámara posicionada en: ", pos)

# ============================================
# TRANSICIÓN CON OVERLAY (FADES)
# ============================================
func fade_to_black():
	if not transition_overlay:
		print("❌ TransitionOverlay no disponible")
		return
	
	print("🖤 Fade to black...")
	transition_overlay.visible = true
	transition_overlay.color = Color(0, 0, 0, 0)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 1), 0.3)
	await tween.finished
	print("🖤 Pantalla negra")

func fade_from_black():
	if not transition_overlay:
		print("❌ TransitionOverlay no disponible")
		return
	
	print("🖤 Fade from black...")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(transition_overlay, "color", Color(0, 0, 0, 0), 0.3)
	await tween.finished
	transition_overlay.visible = false
	print("🖤 Pantalla visible")

# ============================================
# ZONAS
# ============================================
func activate_zone(zone_name: String, spawn_name: String = "SpawnPoint"):
	print("📍 Activando zona: ", zone_name)
	
	for villa in villes.get_children():
		for zone in villa.get_children():
			zone.visible = false
			zone.process_mode = Node.PROCESS_MODE_DISABLED
			print("   🔒 Desactivado: ", zone.name)
	
	var zone = _find_zone(zone_name)
	if zone:
		zone.visible = true
		zone.process_mode = Node.PROCESS_MODE_INHERIT
		current_zone = zone_name
		
		var spawn = zone.get_node(spawn_name)
		if spawn:
			player.global_position = spawn.global_position
			print("📍 Jugador posicionado en SpawnPoint: ", spawn.global_position)
		else:
			player.global_position = zone.global_position
			print("⚠️ No hay SpawnPoint. Posicionado en: ", zone.global_position)
		
		_configure_camera_for_zone(zone)
		print("✅ Zona activada: ", zone_name)
	else:
		print("❌ Zona NO ENCONTRADA: ", zone_name)
		print("📋 Zonas disponibles:")
		for villa in villes.get_children():
			for zone_child in villa.get_children():
				print("   - ", zone_child.name)

func _find_zone(zone_name: String) -> Node2D:
	for villa in villes.get_children():
		var zone = villa.get_node_or_null(zone_name)
		if zone:
			print("✅ Zona encontrada en: ", villa.name, "/", zone.name)
			return zone
	return null

func _configure_camera_for_zone(zone: Node2D):
	var cam_pos = zone.get_node_or_null("CameraPosition")
	if cam_pos:
		set_camera_follows(false)
		camera.global_position = cam_pos.global_position
		print("📷 Cámara estática en: ", cam_pos.global_position)
	else:
		set_camera_follows(true)
		print("📷 Cámara sigue al jugador")

# ============================================
# SISTEMA DE PUERTAS POR ID COMPARTIDO
# ============================================
func teleport_via_door_id(door_id: String, current_door: Node2D = null):
	print("========================================")
	print("🚪 TELETRANSPORTE POR ID")
	print("   📍 Buscando puerta con ID: ", door_id)
	print("========================================")
	
	if is_transitioning:
		print("⚠️ Ya hay una transición en curso")
		return
	
	var target_door = _find_other_door(door_id, current_door)
	
	if not target_door:
		print("❌ No se encontró otra puerta con ID: ", door_id)
		return
	
	print("   → Puerta destino: ", target_door.name)
	
	is_transitioning = true
	
	# ============================================
	# FLUJO DE TRANSICIÓN (SOLO OVERLAY)
	# ============================================
	
	# 1. OCULTAR UI
	await hide_ui_animated()
	
	# 2. FADE TO BLACK
	await fade_to_black()
	
	# 3. TELETRANSPORTAR JUGADOR (en la oscuridad)
	var spawn_position = _get_door_spawn_position(target_door)
	player.global_position = spawn_position
	print("📍 Jugador teletransportado a: ", spawn_position)
	
	# Activar la zona de la puerta destino
	var parent_zone = _find_parent_zone(target_door)
	if parent_zone:
		_activate_zone_by_node(parent_zone)
		current_zone = parent_zone.name
		print("📍 Zona actual: ", current_zone)
		_configure_camera_for_zone(parent_zone)
	
	# 4. FADE FROM BLACK
	await fade_from_black()
	
	# 5. MOSTRAR UI
	await show_ui_animated()
	
	is_transitioning = false
	print("✅ Teletransporte COMPLETADO")
	print("========================================")

func _find_other_door(door_id: String, current_door: Node2D = null) -> Node2D:
	print("🔍 Buscando puertas con ID: ", door_id)
	
	var found_doors = []
	
	for villa in villes.get_children():
		for zone in villa.get_children():
			for child in zone.get_children():
				if child.has_method("on_interact") and child.has_method("get"):
					var child_door_id = child.get("door_id")
					if child_door_id == door_id:
						found_doors.append(child)
						print("   🚪 Encontrada: ", child.name, " en ", zone.name)
	
	if found_doors.size() >= 2:
		for door in found_doors:
			if door != current_door:
				print("   ✅ Seleccionada: ", door.name)
				return door
		return found_doors[1] if found_doors.size() > 1 else found_doors[0]
	elif found_doors.size() == 1:
		print("⚠️ Solo se encontró una puerta con ID: ", door_id)
		return found_doors[0]
	
	print("❌ No se encontraron puertas con ID: ", door_id)
	return null

func _get_door_spawn_position(door: Node2D) -> Vector2:
	var spawn_point = door.get_node_or_null("SpawnPoint")
	if spawn_point:
		print("📍 Usando SpawnPoint: ", spawn_point.global_position)
		return spawn_point.global_position
	else:
		print("⚠️ No hay SpawnPoint. Usando posición de puerta + offset")
		return door.global_position + Vector2(0, 50)

func _find_parent_zone(node: Node) -> Node2D:
	var current = node.get_parent()
	while current:
		if current is Node2D:
			if current.get_parent() and current.get_parent().name in ["ville5", "ville4", "ville3", "ville2", "ville1", "ville6", "ville7"]:
				print("✅ Zona padre encontrada: ", current.name)
				return current
		current = current.get_parent()
	print("⚠️ No se encontró zona padre")
	return null

func _activate_zone_by_node(zone: Node2D):
	for villa in villes.get_children():
		for z in villa.get_children():
			z.visible = false
			z.process_mode = Node.PROCESS_MODE_DISABLED
	
	zone.visible = true
	zone.process_mode = Node.PROCESS_MODE_INHERIT
	print("📍 Zona activada: ", zone.name)

# ============================================
# CONTROL DE UI
# ============================================
func hide_ui_animated():
	if not ui_panel:
		return
	
	print("🖥️ Ocultando UI...")
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(ui_panel, "modulate", Color(1, 1, 1, 0), 0.3)
	await tween.finished
	ui_panel.visible = false
	print("🖥️ UI OCULTADA")

func show_ui_animated():
	if not ui_panel:
		return
	
	print("🖥️ Mostrando UI...")
	ui_panel.visible = true
	ui_panel.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(ui_panel, "modulate", Color(1, 1, 1, 1), 0.3)
	await tween.finished
	print("🖥️ UI MOSTRADA")

# ============================================
# RESET DEL MUNDO
# ============================================
func reset_world():
	print("🔄 Reiniciando mundo...")
	
	# Usar overlay para reset también
	await hide_ui_animated()
	await fade_to_black()
	
	var zone = _find_zone(current_zone)
	if zone:
		var spawn = zone.get_node("SpawnPoint")
		if spawn:
			player.global_position = spawn.global_position
		else:
			player.global_position = zone.global_position
		print("📍 Jugador reiniciado en: ", player.global_position)
	
	var bed = _find_bed()
	if bed and bed.has_method("reset_bed"):
		bed.reset_bed()
	
	Global.player_health = Global.player_max_health
	
	await fade_from_black()
	await show_ui_animated()
	print("✅ Mundo reiniciado")

func _find_bed():
	var zone = _find_zone(current_zone)
	if zone:
		for child in zone.get_children():
			if child.has_method("on_interact"):
				return child
			for subchild in child.get_children():
				if subchild.has_method("on_interact"):
					return subchild
	return null
