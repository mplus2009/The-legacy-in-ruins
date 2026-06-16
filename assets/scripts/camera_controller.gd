extends Camera2D

var target: Node2D = null
var follow_target: bool = true
var camera_limits: Rect2 = Rect2()

func _ready():
	# Buscar al jugador
	await get_tree().process_frame
	target = get_node("/root/World/Player")
	
	if target:
		print("📷 Controlador de cámara iniciado")
	else:
		print("⚠️ No se encontró el jugador")

func _process(delta):
	if not target:
		return
	
	if follow_target:
		# Seguir al jugador
		global_position = target.global_position
	else:
		# Cámara estática - no hacer nada
		pass

func set_follow(follow: bool):
	follow_target = follow
	if not follow:
		# Fijar cámara en posición actual
		position = Vector2.ZERO
		print("📷 Cámara estática")
	else:
		print("📷 Cámara sigue al jugador")

func set_camera_limits(limits: Rect2):
	camera_limits = limits
	limit_left = limits.position.x
	limit_top = limits.position.y
	limit_right = limits.end.x
	limit_bottom = limits.end.y
