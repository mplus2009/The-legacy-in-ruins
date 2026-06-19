extends Node2D

@export var heal_amount: int = 50

var interact_area: Area2D = null
var player_near: bool = false

func _ready():
	print("🛏️ Inicializando cama...")
	
	interact_area = _find_interact_area(self)
	
	if not interact_area:
		print("⚠️ Creando InteractArea...")
		_create_interact_area()
	
	if interact_area:
		interact_area.collision_layer = 2
		interact_area.collision_mask = 1
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)
		print("✅ InteractArea configurado (Layer: 2, Mask: 1)")

func _find_interact_area(node: Node) -> Area2D:
	for child in node.get_children():
		if child is Area2D and child.name == "InteractArea":
			return child
		var found = _find_interact_area(child)
		if found:
			return found
	return null

func _create_interact_area():
	interact_area = Area2D.new()
	interact_area.name = "InteractArea"
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 60
	interact_area.add_child(shape)
	
	add_child(interact_area)
	print("✅ InteractArea creado")

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		player_near = true
		highlight(true)
		print("🛏️ Jugador cerca")

func _on_body_exited(body: Node2D):
	if body.name == "Player":
		player_near = false
		highlight(false)
		print("🛏️ Jugador lejos")

func on_interact():
	print("🛏️ Interactuando con la cama...")
	
	if not player_near:
		print("❌ Acércate más a la cama")
		return
	
	# Curar al jugador
	Global.heal(heal_amount)
	print("💤 Has descansado. +", heal_amount, " de salud")
	
	# === EJECUTAR ANIMACIÓN RESET (OCULTA Y MUESTRA UI CON ANIMACIÓN) ===
	var world = get_node("/root/world")
	if world and world.has_method("play_reset_animation"):
		print("🎬 Ejecutando animación RESET desde la cama")
		world.play_reset_animation()
	else:
		print("❌ No se encontró World o método play_reset_animation")
	
	# Efecto visual de dormir
	_sleep_effect()

func _sleep_effect():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.3, 0.3, 0.7, 1), 0.4)
	await get_tree().create_timer(0.8).timeout
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.4)

func highlight(active: bool):
	if active:
		modulate = Color(1, 1, 0.7, 1)
	else:
		modulate = Color(1, 1, 1, 1)

func reset_bed():
	player_near = false
	highlight(false)
	modulate = Color(1, 1, 1, 1)
	print("🛏️ Cama reiniciada")
