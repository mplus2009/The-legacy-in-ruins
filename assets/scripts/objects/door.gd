extends StaticBody2D

# ============================================
# EXPORT
# ============================================
@export var door_id: String = ""  # ID compartido con la otra puerta
@export var required_item: String = ""
@export var is_locked: bool = false

# ============================================
# VARIABLES
# ============================================
var player_near: bool = false
var is_open: bool = false

@onready var sprite = $Sprite2D
@onready var interact_area = $InteractArea
@onready var spawn_point = $SpawnPoint  # Nodo donde aparecerá el jugador

# ============================================
# READY
# ============================================
func _ready():
	print("🚪 Puerta ID: ", door_id)
	
	if interact_area:
		interact_area.collision_layer = 2
		interact_area.collision_mask = 1
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
		print("✅ InteractArea configurado")
	
	if is_locked:
		_set_locked_appearance()
	
	if spawn_point:
		print("✅ SpawnPoint encontrado en: ", spawn_point.global_position)
	else:
		print("⚠️ No hay SpawnPoint en la puerta")

# ============================================
# DETECCIÓN DE JUGADOR
# ============================================
func _on_body_entered(body: Node2D):
	if body.name == "Player":
		player_near = true
		highlight(true)
		print("🚪 Jugador CERCA de: ", door_id)

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		player_near = false
		highlight(false)
		print("🚪 Jugador LEJOS de: ", door_id)

# ============================================
# INTERACCIÓN
# ============================================
func on_interact():
	print("🚪 Interactuando con puerta: ", door_id)
	
	if not player_near:
		print("❌ Acércate más")
		return
	
	if is_locked:
		_try_unlock()
		return
	
	if is_open:
		print("🚪 Ya está abierta")
		return
	
	_open_door()

func _try_unlock():
	if required_item != "" and Global.has_item(required_item):
		print("🔑 Desbloqueando con: ", required_item)
		Global.remove_item(required_item)
		is_locked = false
		_set_unlocked_appearance()
		print("✅ Puerta desbloqueada")
	else:
		print("🔒 Necesitas: ", required_item)

func _open_door():
	print("🚪 ABRIENDO...")
	is_open = true
	
	if sprite:
		sprite.modulate = Color(0.5, 0.8, 0.5, 1)
	
	# Buscar la otra puerta con el mismo ID
	var world = get_node("/root/world")
	if world and world.has_method("teleport_via_door_id"):
		print("🚪 Buscando puerta con ID: ", door_id)
		world.teleport_via_door_id(door_id, self)
	else:
		print("❌ World no tiene teleport_via_door_id")
	
	# Cerrar puerta después
	await get_tree().create_timer(0.1).timeout
	is_open = false
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)

# ============================================
# FUNCIÓN PARA OBTENER SPAWN POINT
# ============================================
func get_spawn_position() -> Vector2:
	if spawn_point:
		return spawn_point.global_position
	else:
		return global_position + Vector2(0, 50)

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

func _set_unlocked_appearance():
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)

func reset_door():
	is_open = false
	is_locked = false
	modulate = Color(1, 1, 1, 1)
	if sprite:
		sprite.modulate = Color(1, 1, 1, 1)
	print("🚪 Puerta reiniciada: ", door_id)
