extends Area2D

@export var camera_follows: bool = true  # true = sigue al jugador, false = estática
@export var one_shot: bool = false  # Si solo debe activarse una vez
@export var camera_limit_rect: Rect2 = Rect2()  # Limitar movimiento de cámara (opcional)

var has_triggered = false

func _ready():
	# Conectar la señal de cuerpo entrante
	body_entered.connect(_on_body_entered)
	
	# Configurar colisión
	collision_layer = 0
	collision_mask = 1  # Detectar al jugador

func _on_body_entered(body: Node2D):
	if body.name == "Player" and not has_triggered:
		# Cambiar modo de cámara
		body.set_camera_follows(camera_follows)
		
		# Opcional: Limitar área de cámara
		if camera_limit_rect != Rect2():
			body.camera.limit_left = camera_limit_rect.position.x
			body.camera.limit_top = camera_limit_rect.position.y
			body.camera.limit_right = camera_limit_rect.end.x
			body.camera.limit_bottom = camera_limit_rect.end.y
		
		print("📷 Cámara modo: ", "sigue al jugador" if camera_follows else "estática")
		
		if one_shot:
			has_triggered = true
