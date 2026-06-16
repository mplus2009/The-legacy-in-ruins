extends CharacterBody2D

const SPEED: float = 300.0
const SPRINT_SPEED: float = 450.0

var current_speed: float = SPEED
var can_move: bool = true
var move_to_target: Vector2 = Vector2.ZERO
var use_move_to_click: bool = false
var click_marker: ColorRect = null

@onready var sprite = $Sprite2D
@onready var interact_area = $InteractArea

func _ready():
	_load_gender_sprite()
	print("✅ Jugador cargado - Género: ", Global.player_gender)

# ============================================
# CARGA DE SPRITE SEGÚN GÉNERO
# ============================================
func _load_gender_sprite():
	var texture_path = "res://assets/sprites/player/" + Global.player_gender + ".png"
	
	if ResourceLoader.exists(texture_path):
		var texture = load(texture_path)
		sprite.texture = texture
		print("📁 Sprite cargado desde: ", texture_path)
	else:
		_create_placeholder_sprite()
	
	sprite.scale = Vector2(2.0, 2.0)

func _create_placeholder_sprite():
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	
	if Global.player_gender == "male":
		image.fill(Color(0.29, 0.56, 0.89, 1.0))
	else:
		image.fill(Color(0.89, 0.29, 0.56, 1.0))
	
	var texture = ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.scale = Vector2(2.0, 2.0)
	print("🎨 Sprite placeholder creado para género: ", Global.player_gender)

# ============================================
# MOVIMIENTO
# ============================================
func _physics_process(_delta):
	if not can_move:
		return
	
	var input_dir = Vector2.ZERO
	var use_keyboard = false
	
	# Movimiento con teclado (WASD o Flechas)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
		use_keyboard = true
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1
		use_keyboard = true
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1
		use_keyboard = true
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1
		use_keyboard = true
	
	# Movimiento con click izquierdo (sin pathfinding)
	if use_move_to_click and not use_keyboard:
		var direction = (move_to_target - global_position).normalized()
		velocity = direction * current_speed
		move_and_slide()
		
		# Si choca con algo, cancelar
		if velocity.length() > 0 and get_last_slide_collision():
			_cancel_navigation()
			print("🚫 Obstáculo encontrado, movimiento cancelado")
		
		# Si llegó al destino
		if global_position.distance_to(move_to_target) < 10:
			_arrive_at_destination()
	
	# Movimiento con teclado
	if use_keyboard:
		if input_dir != Vector2.ZERO:
			input_dir = input_dir.normalized()
		
		# Sprint
		if Input.is_key_pressed(KEY_SHIFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			current_speed = SPRINT_SPEED
		else:
			current_speed = SPEED
		
		velocity = input_dir * current_speed
		move_and_slide()
	
	# Voltear sprite
	if input_dir.x < 0:
		sprite.scale = Vector2(-2.0, 2.0)
	elif input_dir.x > 0:
		sprite.scale = Vector2(2.0, 2.0)
	
	# Actualizar marcador visual
	_update_marker_position()

func _input(event):
	# Click izquierdo: mover hacia posición
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if can_move:
			_remove_click_marker()
			move_to_target = get_global_mouse_position()
			_create_click_marker()
			use_move_to_click = true
			print("🖱️ Mover hacia: ", move_to_target)
	
	# Click derecho: cancelar movimiento
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_cancel_navigation()
	
	# Tecla E: interactuar
	if event.is_action_pressed("ui_accept") and can_move:
		interact()

# ============================================
# NAVEGACIÓN POR CLICK
# ============================================
func _cancel_navigation():
	if use_move_to_click:
		_remove_click_marker()
		use_move_to_click = false
		velocity = Vector2.ZERO
		print("🖱️ Movimiento cancelado")

func _arrive_at_destination():
	_remove_click_marker()
	use_move_to_click = false
	velocity = Vector2.ZERO
	print("📍 Destino alcanzado")

# ============================================
# INDICADOR VISUAL (MARCADOR DE DESTINO)
# ============================================
func _create_click_marker():
	click_marker = ColorRect.new()
	click_marker.size = Vector2(16, 16)
	click_marker.color = Color(1, 0, 0, 0.8)
	click_marker.position = move_to_target - Vector2(8, 8)
	get_parent().add_child(click_marker)
	print("🔴 Marcador de destino creado")

func _update_marker_position():
	if click_marker and use_move_to_click:
		click_marker.position = move_to_target - Vector2(8, 8)
		# Efecto de parpadeo
		var alpha = (sin(Time.get_ticks_msec() * 0.01) + 1) / 2
		click_marker.color = Color(1, 0, 0, 0.5 + alpha * 0.3)

func _remove_click_marker():
	if click_marker:
		click_marker.queue_free()
		click_marker = null
		print("🔴 Marcador de destino eliminado")

# ============================================
# INTERACCIÓN
# ============================================
func interact():
	print("🔍 Buscando con qué interactuar...")
	var overlapping_bodies = interact_area.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.has_method("on_interact"):
			print("✅ Interactuando con: ", body.name)
			body.on_interact()
			return
	
	print("❌ No hay nada para interactuar aquí")

# ============================================
# FUNCIONES PÚBLICAS
# ============================================
func set_can_move(value: bool):
	can_move = value
	if not value:
		_cancel_navigation()
		velocity = Vector2.ZERO
	print("🎮 Movimiento: ", "activado" if value else "desactivado")

func teleport(new_position: Vector2):
	global_position = new_position
	_cancel_navigation()
