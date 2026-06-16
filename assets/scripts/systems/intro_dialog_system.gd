extends Control

signal intro_finished

# Nodos
@onready var text_label = $Panel/RichTextLabel
@onready var continue_indicator = $Panel/ContinueLabel
@onready var panel_opciones = $PanelOpciones
@onready var btn_masculino = $PanelOpciones/VBoxContainer/ButtonMasculino
@onready var btn_femenino = $PanelOpciones/VBoxContainer/ButtonFemenino
@onready var name_input = $PanelOpciones/VBoxContainer/LineEdit
@onready var confirm_btn = $PanelOpciones/VBoxContainer/ButtonConfirmar
#@onready var typing_sound = $AudioStreamPlayer2D

# Variables de escritura
var full_text = ""
var current_display_text = ""
var typing_speed = 0.03
var is_typing = false
var can_continue = false

# Estado del diálogo
var current_step = 0
var player_gender = ""
var player_name = ""

# Secuencia de pensamientos
var thoughts = [
	"Oscuridad... Todo es oscuridad...",
	"¿Dónde estoy? No siento mi cuerpo...",
	"Un nombre... flota en mi mente...",
	"Pero primero... ¿quién soy?"
]

func _ready():
	panel_opciones.visible = false
	continue_indicator.visible = false
	text_label.visible = true
	text_label.text = ""
	
	#if typing_sound:
	#	typing_sound.volume_db = -10
	
	btn_masculino.pressed.connect(_on_masculino_pressed)
	btn_femenino.pressed.connect(_on_femenino_pressed)
	confirm_btn.pressed.connect(_on_name_confirmed)
	
	show_next_thought()

func show_typing_text(text: String, _show_continue_on_complete: bool = true):
	full_text = text
	current_display_text = ""
	text_label.text = ""
	is_typing = true
	can_continue = false
	continue_indicator.visible = false
	
	_start_typing()

func _start_typing():
	var tween = create_tween()
	tween.tween_method(_add_character, 0, full_text.length(), full_text.length() * typing_speed)
	tween.tween_callback(_on_typing_finished)

func _add_character(idx: int):
	if idx <= full_text.length():
		current_display_text = full_text.substr(0, idx)
		text_label.text = current_display_text
		
	#	if typing_sound and idx % 2 == 0:
	#		typing_sound.play()

func _on_typing_finished():
	is_typing = false
	can_continue = true
	continue_indicator.visible = true

func show_next_thought():
	if current_step >= thoughts.size():
		show_gender_choice()
		return
	
	var thought = thoughts[current_step]
	show_typing_text(thought)
	current_step += 1

func show_gender_choice():
	full_text = ""
	is_typing = false
	text_label.text = "Antes de continuar... ¿qué soy?"
	text_label.visible = true
	panel_opciones.visible = true
	continue_indicator.visible = false
	name_input.visible = false
	confirm_btn.visible = false
	btn_masculino.visible = true
	btn_femenino.visible = true

func show_name_input():
	text_label.text = "¿Cuál es mi nombre?"
	text_label.visible = true
	btn_masculino.visible = false
	btn_femenino.visible = false
	name_input.visible = true
	confirm_btn.visible = true
	name_input.grab_focus()

func _on_masculino_pressed():
	player_gender = "male"
	Global.player_gender = "male"
	Global.remembered_name = "Noa"
	show_name_input()

func _on_femenino_pressed():
	player_gender = "female"
	Global.player_gender = "female"
	Global.remembered_name = "Mox"
	show_name_input()

func _on_name_confirmed():
	var new_name = name_input.text.strip_edges()
	if new_name == "":
		new_name = "Viajero"
	
	player_name = new_name
	Global.player_name = player_name
	
	show_partner_memory()

func show_partner_memory():
	panel_opciones.visible = false
	name_input.visible = false
	confirm_btn.visible = false
	continue_indicator.visible = false
	
	var memory_text = ""
	if player_gender == "male":
		memory_text = "Un nombre surge del vacío... Noa.\n\nUna mujer... su voz... ¿compañera? ¿algo más?\n\nNo recuerdo su rostro, pero su nombre... arde en mi pecho."
	else:
		memory_text = "Un nombre surge del vacío... Mox.\n\nUn hombre... su voz... ¿compañero? ¿algo más?\n\nNo recuerdo su rostro, pero su nombre... arde en mi pecho."
	
	show_typing_text(memory_text)

func _input(event):
	if event.is_action_pressed("ui_accept") and can_continue and not is_typing:
		can_continue = false
		continue_indicator.visible = false
		
		if player_name != "" and current_step >= thoughts.size():
			end_intro()
		else:
			show_next_thought()

func end_intro():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	await tween.finished
	
	intro_finished.emit()
	get_tree().change_scene_to_file("res://assets/esenas/world.tscn")

func _exit_tree():
#	if typing_sound and typing_sound.playing:
#		typing_sound.stop()
	pass
