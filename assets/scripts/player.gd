extends CharacterBody2D

const SPEED: float = 300.0
const SPRINT_SPEED: float = 450.0

var current_speed: float = SPEED
var can_move: bool = true

# Interacción
var nearest_interactable: Node = null
var objects_in_range: Array = []

@onready var sprite = $Sprite2D
@onready var interact_area = $InteractArea

# ============================================
# READY
# ============================================
func _ready():
	print("✅ Jugador cargado")
	print("📍 Posición inicial: ", global_position)
	
	collision_layer = 1
	collision_mask = 1
	
	if interact_area:
		interact_area.collision_layer = 0
		interact_area.collision_mask = 2
		interact_area.body_entered.connect(_on_interact_area_entered)
		interact_area.body_exited.connect(_on_interact_area_exited)
		interact_area.area_entered.connect(_on_interact_area_entered)
		interact_area.area_exited.connect(_on_interact_area_exited)
		print("📌 Área de interacción configurada (Mask: 2)")
	
	_create_interact_indicator()

func _create_interact_indicator():
	var indicator = ColorRect.new()
	indicator.name = "InteractIndicator"
	indicator.size = Vector2(80, 30)
	indicator.color = Color(0, 0.8, 0, 0.7)
	indicator.position = Vector2(-40, -70)
	indicator.visible = false
	add_child(indicator)
	
	var label = Label.new()
	label.text = "[E]"
	label.position = Vector2(25, 0)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	indicator.add_child(label)

func _update_indicator(show: bool, is_ready: bool = false):
	var indicator = get_node_or_null("InteractIndicator")
	if indicator:
		indicator.visible = show
		if show and is_ready:
			indicator.color = Color(0, 0.8, 0, 0.9)
		elif show:
			indicator.color = Color(0.8, 0.8, 0, 0.7)

# ============================================
# DETECCIÓN DE INTERACTUABLES
# ============================================
func _on_interact_area_entered(body: Node2D):
	print("📌 Entró: ", body.name)
	var interactable = _find_interactable(body)
	if interactable:
		if interactable not in objects_in_range:
			objects_in_range.append(interactable)
			print("✅ Interactuable añadido: ", interactable.name)
		_update_nearest()

func _on_interact_area_exited(body: Node2D):
	print("📌 Salió: ", body.name)
	var interactable = _find_interactable(body)
	if interactable:
		if interactable in objects_in_range:
			objects_in_range.erase(interactable)
			print("✅ Interactuable removido: ", interactable.name)
		_update_nearest()

func _update_nearest():
	var nearest = null
	var min_dist = INF
	
	for obj in objects_in_range:
		if is_instance_valid(obj):
			var d = global_position.distance_to(obj.global_position)
			if d < min_dist:
				min_dist = d
				nearest = obj
	
	if nearest != nearest_interactable:
		if nearest_interactable and nearest_interactable.has_method("highlight"):
			nearest_interactable.highlight(false)
		
		nearest_interactable = nearest
		
		if nearest_interactable:
			if nearest_interactable.has_method("highlight"):
				nearest_interactable.highlight(true)
			_update_indicator(true, true)
			print("🎯 Objeto seleccionado: ", nearest_interactable.name)
		else:
			_update_indicator(false, false)
			print("🎯 Sin objeto seleccionado")

func _find_interactable(node):
	if not node:
		return null
	if node.has_method("on_interact"):
		return node
	return _find_interactable(node.get_parent())

# ============================================
# MOVIMIENTO CON DEBUG DE POSICIÓN
# ============================================
func _physics_process(_delta):
	if not can_move:
		return
	
	var input_dir = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1
	
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
	
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = SPRINT_SPEED
	else:
		current_speed = SPEED
	
	velocity = input_dir * current_speed
	move_and_slide()
	
	if input_dir.x < 0:
		sprite.scale.x = -abs(sprite.scale.x)
	elif input_dir.x > 0:
		sprite.scale.x = abs(sprite.scale.x)

# ============================================
# TELETRANSPORTE CON DEBUG
# ============================================
func teleport(pos: Vector2):
	print("========================================")
	print("🚨 TELETRANSPORTE EJECUTADO")
	print("   📍 Posición anterior: ", global_position)
	print("   📍 Nueva posición: ", pos)
	print("   📍 Diferencia: ", pos - global_position)
	print("   📍 Stack trace:")
	print_stack()
	print("========================================")
	global_position = pos

# ============================================
# INTERACCIÓN
# ============================================
func _input(event):
	if event.is_action_pressed("ui_accept") and can_move:
		interact()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if can_move:
			interact()

func interact():
	print("🔍 Interactuando...")
	
	if nearest_interactable and is_instance_valid(nearest_interactable):
		print("✅ Interactuando con: ", nearest_interactable.name)
		nearest_interactable.on_interact()
	else:
		print("❌ No hay nada para interactuar")

func set_can_move(value: bool):
	can_move = value
	print("🎮 can_move cambiado a: ", value)
