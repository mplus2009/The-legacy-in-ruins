extends Control

signal joystick_moved(direction: Vector2)
signal joystick_released()

# ============================================
# EXPORT
# ============================================
@export var max_distance: float = 40.0
@export var dead_zone: float = 10.0

# ============================================
# VARIABLES
# ============================================
var is_dragging: bool = false
var touch_index: int = -1
var center_position: Vector2 = Vector2.ZERO
var current_direction: Vector2 = Vector2.ZERO

# ============================================
# REFERENCIAS
# ============================================
@onready var fondo = $Fondo if has_node("Fondo") else null
@onready var bola = $Bola if has_node("Bola") else null

# ============================================
# READY
# ============================================
func _ready():
	print("🔄 Inicializando joystick...")
	
	# Verificar si el nodo joystick existe y tiene tamaño
	if not self:
		print("❌ Joystick: nodo no válido")
		return
	
	# Esperar a que se calcule el tamaño
	await get_tree().process_frame
	
	# Verificar que el joystick tenga tamaño
	if size == Vector2.ZERO:
		size = Vector2(60, 60)
		print("⚠️ Joystick: tamaño ajustado a ", size)
	
	# Calcular centro
	center_position = size / 2
	print("📌 Joystick centro: ", center_position)
	
	# === CREAR FONDO SI NO EXISTE ===
	if not fondo:
		print("⚠️ Joystick: Fondo no encontrado - Creando...")
		fondo = ColorRect.new()
		fondo.name = "Fondo"
		fondo.size = size
		fondo.position = Vector2(0, 0)
		fondo.color = Color(0.5, 0.5, 0.5, 0.3)
		add_child(fondo)
	else:
		fondo.size = size
		fondo.position = Vector2(0, 0)
	
	# === CREAR BOLA SI NO EXISTE ===
	if not bola:
		print("⚠️ Joystick: Bola no encontrada - Creando...")
		bola = ColorRect.new()
		bola.name = "Bola"
		bola.size = Vector2(20, 20)
		bola.position = center_position - Vector2(10, 10)
		bola.color = Color(1, 1, 1, 0.8)
		add_child(bola)
	else:
		bola.size = Vector2(20, 20)
		bola.position = center_position - Vector2(10, 10)
	
	print("✅ Joystick listo")

# ============================================
# INPUT
# ============================================
func _input(event):
	if not visible or not is_inside_tree():
		return
	
	# Toque táctil
	if event is InputEventScreenTouch:
		if event.pressed:
			var local_pos = get_local_mouse_position()
			var dist = local_pos.distance_to(center_position)
			if dist < max_distance * 1.5:
				is_dragging = true
				touch_index = event.index
				_update_joystick(local_pos)
		else:
			if event.index == touch_index:
				_release_joystick()
	
	if event is InputEventScreenDrag:
		if is_dragging and event.index == touch_index:
			var local_pos = get_local_mouse_position()
			_update_joystick(local_pos)
	
	# Mouse (PC)
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos = get_local_mouse_position()
			var dist = local_pos.distance_to(center_position)
			if dist < max_distance * 1.5:
				is_dragging = true
				touch_index = 999
				_update_joystick(local_pos)
		else:
			if touch_index == 999:
				_release_joystick()
	
	if event is InputEventMouseMotion:
		if is_dragging and touch_index == 999:
			var local_pos = get_local_mouse_position()
			_update_joystick(local_pos)

# ============================================
# ACTUALIZAR JOYSTICK
# ============================================
func _update_joystick(local_pos: Vector2):
	if not bola:
		return
	
	var direction = local_pos - center_position
	var distance = direction.length()
	
	if distance > max_distance:
		direction = direction.normalized() * max_distance
		distance = max_distance
	
	if distance < dead_zone:
		current_direction = Vector2.ZERO
		bola.position = center_position - bola.size / 2
	else:
		current_direction = direction / max_distance
		bola.position = center_position + direction - bola.size / 2
	
	joystick_moved.emit(current_direction)

func _release_joystick():
	is_dragging = false
	touch_index = -1
	current_direction = Vector2.ZERO
	
	if bola:
		bola.position = center_position - bola.size / 2
	
	joystick_released.emit()

# ============================================
# FUNCIÓN PÚBLICA
# ============================================
func get_direction() -> Vector2:
	return current_direction
