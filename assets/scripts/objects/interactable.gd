extends StaticBody2D

@export var object_name: String = "Objeto"
@export var interaction_type: String = "examine"  # examine, pickup, talk, use, open
@export var requires_item: String = ""  # Item necesario para interactuar
@export var dialog_id: String = ""  # ID del diálogo a mostrar
@export var target_zone: String = ""  # Zona a la que teletransportar
@export var target_spawn: String = "SpawnPoint"  # Spawn point en la zona destino
@export var animation_player: AnimationPlayer  # Referencia al AnimationPlayer

# Señal que se emite cuando se interactúa
signal interaction_triggered(interaction_type, object_name)

# Variables internas
var is_interactable: bool = true
var has_been_interacted: bool = false
var player_reference: Node = null

@onready var interact_area = $InteractArea
@onready var sprite = $Sprite2D

func _ready():
	# Configurar el área de interacción
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)

# ============================================
# DETECCIÓN DE JUGADOR
# ============================================
func _on_body_entered(body: Node2D):
	if body.name == "Player":
		player_reference = body
		# Mostrar indicador de interacción (opcional)
		_show_interact_hint(true)

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		player_reference = null
		_show_interact_hint(false)

# ============================================
# FUNCIÓN PRINCIPAL DE INTERACCIÓN
# ============================================
func on_interact():
	if not is_interactable:
		print("⛔ ", object_name, " no se puede interactuar ahora")
		return
	
	# Verificar si necesita un item
	if requires_item != "" and not Global.has_item(requires_item):
		print("🔒 Necesitas: ", requires_item, " para interactuar con ", object_name)
		_show_requirement_message(requires_item)
		return
	
	# Emitir señal
	interaction_triggered.emit(interaction_type, object_name)
	
	# Ejecutar la interacción según el tipo
	_handle_interaction()
	
	# Marcar como interactuado (si es de un solo uso)
	if _is_one_time_interaction():
		is_interactable = false
		has_been_interacted = true

# ============================================
# MANEJADOR DE INTERACCIONES
# ============================================
func _handle_interaction():
	match interaction_type:
		"examine":
			_examine()
		"pickup":
			_pickup()
		"talk":
			_talk()
		"use":
			_use()
		"open":
			_open()
		"teleport":
			_teleport()
		"custom":
			_custom_interaction()
		_:
			print("⚠️ Tipo de interacción desconocido: ", interaction_type)

# ============================================
# TIPOS DE INTERACCIÓN
# ============================================

# 1. EXAMINAR - Mirar el objeto
func _examine():
	print("🔍 Examinando: ", object_name)
	_show_dialog("examine")
	_play_animation("examine")

# 2. RECOGER - Añadir al inventario
func _pickup():
	print("📦 Recogiendo: ", object_name)
	Global.add_item(object_name.to_lower())
	_play_animation("pickup")
	# Ocultar el objeto después de recogerlo
	if sprite:
		sprite.visible = false
	if interact_area:
		interact_area.monitoring = false

# 3. HABLAR - Diálogo con NPC
func _talk():
	print("💬 Hablando con: ", object_name)
	if dialog_id != "":
		_show_dialog(dialog_id)
	_play_animation("talk")

# 4. USAR - Usar un objeto (requiere item)
func _use():
	print("🔧 Usando: ", object_name)
	if requires_item != "":
		Global.remove_item(requires_item)
		print("✅ Usaste ", requires_item, " en ", object_name)
	_play_animation("use")

# 5. ABRIR - Abrir puertas, cofres, etc.
func _open():
	print("🚪 Abriendo: ", object_name)
	# Cambiar sprite a estado abierto
	if sprite and sprite.has_method("set_frame"):
		sprite.set_frame(1)
	_play_animation("open")

# 6. TELETRANSPORTE - Cambiar de zona
func _teleport():
	print("🚂 Teletransportando a: ", target_zone)
	if player_reference and target_zone != "":
		var world = get_node("/root/World")
		if world:
			_play_animation("teleport")
			world.teleport_to_zone(target_zone, target_spawn)

# 7. INTERACCIÓN PERSONALIZADA
func _custom_interaction():
	print("⚡ Interacción personalizada para: ", object_name)
	# Aquí puedes añadir lógica específica para cada objeto
	_play_animation("custom")

# ============================================
# FUNCIONES AUXILIARES
# ============================================

# Reproducir animación
func _play_animation(animation_name: String):
	if animation_player:
		if animation_player.has_animation(animation_name):
			animation_player.play(animation_name)
			print("🎬 Reproduciendo animación: ", animation_name)
		else:
			print("⚠️ Animación no encontrada: ", animation_name)

# Mostrar diálogo (conectar con sistema de diálogos después)
func _show_dialog(dialog_key: String):
	print("📝 Diálogo: ", dialog_key)
	# Aquí llamarás al sistema de diálogos
	# DialogSystem.start_dialog(dialog_key)

# Mostrar mensaje de requisito
func _show_requirement_message(item: String):
	print("🔒 Se necesita: ", item)
	# Mostrar en UI después

# Mostrar/ocultar indicador de interacción
func _show_interact_hint(show: bool):
	# Cambiar color del sprite o mostrar icono
	if sprite:
		if show:
			sprite.modulate = Color(1, 1, 0.8, 1)  # Resaltar
		else:
			sprite.modulate = Color(1, 1, 1, 1)  # Normal

# Verificar si es interacción de un solo uso
func _is_one_time_interaction() -> bool:
	return interaction_type in ["pickup", "use", "open"]

# ============================================
# FUNCIONES PÚBLICAS
# ============================================

# Activar/desactivar interacción
func set_interactable(value: bool):
	is_interactable = value
	if not value:
		print("🔒 ", object_name, " ahora no es interactuable")

# Cambiar tipo de interacción en tiempo real
func set_interaction_type(new_type: String):
	interaction_type = new_type
	print("🔄 ", object_name, " ahora tiene interacción: ", new_type)
