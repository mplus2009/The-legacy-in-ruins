extends StaticBody2D

# ============================================
# EXPORT
# ============================================
@export var door_name: String = "Puerta"  # Ej: "door_1_villa5_hospital_pasillo_door_2"
@export var required_item: String = ""  # Item necesario (opcional)
@export var is_locked: bool = false

# ============================================
# VARIABLES
# ============================================
var player_near: bool = false
var is_open: bool = false

# Datos parseados del nombre
var door_id: String = ""  # Ej: "door_1"
var target_zone: String = ""  # Ej: "villa5_hospital_pasillo"
var target_door_id: String = ""  # Ej: "door_2"

@onready var sprite = $Sprite2D
@onready var interact_area = $InteractArea

# ============================================
# READY
# ============================================
func _ready():
	print("🚪 Inicializando puerta: ", door_name)
	
	# Parsear el nombre de la puerta
	_parse_door_name()
	
	if interact_area:
		interact_area.collision_layer = 2
		interact_area.collision_mask = 1
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
		print("✅ InteractArea configurado")
	
	if is_locked:
		_set_locked_appearance()

# ============================================
# PARSEAR NOMBRE DE PUERTA
# ============================================
func _parse_door_name():
	# Ejemplo: "door_1_villa5_hospital_pasillo_door_2"
	var parts = door_name.split("_")
	
	if parts.size() >= 2 and parts[0] == "door":
		door_id = parts[0] + "_" + parts[1]  # "door_1"
		print("   🚪 ID: ", door_id)
		
		# Buscar el "door_" final que indica la puerta destino
		var target_parts = door_name.split("_door_")
		if target_parts.size() >= 2:
			target_zone = target_parts[0].replace("door_" + parts[1] + "_", "")
			target_door_id = "door_" + target_parts[1]
			print("   🎯 Zona destino: ", target_zone)
			print("   🎯 Puerta destino: ", target_door_id)
		else:
			print("   ⚠️ Formato incorrecto: falta '_door_'")
	else:
		print("   ⚠️ Formato incorrecto: debe empezar con 'door_'")

# ============================================
# DETECCIÓN DE JUGADOR
# ============================================
func _on_body_entered(body: Node2D):
	if body.name == "Player":
		player_near = true
		highlight(true)
		print("🚪 Jugador cerca de: ", door_name)

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		player_near = false
		highlight(false)
		print("🚪 Jugador lejos de: ", door_name)

# ============================================
# INTERACCIÓN
# ============================================
func on_interact():
	print("🚪 Interactuando con: ", door_name)
	
	if not player_near:
		print("❌ Acércate más a la puerta")
		return
	
	if is_locked:
		_try_unlock()
		return
	
	if is_open:
		print("🚪 La puerta ya está abierta")
		return
	
	_open_door()

func _try_unlock():
	if required_item != "" and Global.has_item(required_item):
		print("🔑 Desbloqueando puerta con: ", required_item)
		Global.remove_item(required_item)
		is_locked = false
		is_open = false
		_set_unlocked_appearance()
		print("✅ Puerta desbloqueada")
	else:
		print("🔒 La puerta está cerrada. Necesitas: ", required_item)

func _open_door():
	print("🚪 Abriendo puerta...")
	is_open = true
	
	if sprite:
		sprite.modulate = Color(0.5, 0.8, 0.5, 1)
	
	_do_transition()

func _do_transition():
	print("🚪 Transitando a: ", target_zone)
	print("   🎯 Aparecer en: ", target_door_id)
	
	var world = get_node("/root/world")
	if not world:
		print("❌ World no encontrado")
		return
	
	# Reproducir animación mov_zone
	if world.has_method("play_mov_zone_animation"):
		world.play_mov_zone_animation()
		await world.animation_finished
	
	# Teletransportar a la zona destino
	if world.has_method("teleport_to_zone_by_door"):
		world.teleport_to_zone_by_door(target_zone, target_door_id)
	else:
		print("⚠️ World no tiene teleport_to_zone_by_door")

# ============================================
# APARIENCIA
# ============================================
func highlight(active: bool):
	if active and not is_open:
		modulate = Color(1, 1, 0.7, 1)
	else:
		modulate = Color(1, 1, 1, 1)

func _set_locked_appearance():
	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5, 1)
	print("🔒 Puerta cerrada con llave")

func _set_unlocked_appearance():
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
	print("🔓 Puerta desbloqueada")

func reset_door():
	is_open = false
	is_locked = false
	modulate = Color(1, 1, 1, 1)
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
	print("🚪 Puerta reiniciada: ", door_name)
