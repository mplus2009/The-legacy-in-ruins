extends Control

@onready var btn_interactuar = $BtnInteractuar
@onready var btn_sprint = $BtnSprint
@onready var btn_menu = $BtnMenu

func _ready():
	mouse_filter = MOUSE_FILTER_IGNORE
	focus_mode = FOCUS_NONE
	
	if btn_interactuar:
		btn_interactuar.action = "ui_accept"
		print("✅ Botón interactuar configurado")
	if btn_sprint:
		btn_sprint.action = "sprint"
		print("✅ Botón sprint configurado")
	if btn_menu:
		btn_menu.action = "ui_cancel"
		print("✅ Botón menú configurado")
	
	print("📱 Controles móviles configurados")
	visible = true
