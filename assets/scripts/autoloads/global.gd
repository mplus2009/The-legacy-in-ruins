extends Node

# ============================================
# DATOS DEL JUGADOR
# ============================================
var player_name: String = ""
var player_gender: String = ""  # "male" o "female"
var remembered_name: String = ""  # "Noa" o "Mox"

# ============================================
# ESTADO DEL JUGADOR
# ============================================
var player_health: int = 100
var player_max_health: int = 100
var player_money: int = 500

# ============================================
# PROGRESO DEL JUEGO
# ============================================
var current_villa: int = 1
var completed_missions: Array = []
var active_missions: Array = []

# ============================================
# INVENTARIO
# ============================================
var inventory = {
	"antena_parts": 0,
	"evidence": [],
	"keys": [],
	"medicines": 0
}

# ============================================
# FLAGS DE HISTORIA (decisiones del jugador)
# ============================================
var flags = {}

# ============================================
# MÉTODOS PÚBLICOS
# ============================================

# Gestionar flags
func set_flag(flag: String, value) -> void:
	flags[flag] = value
	print("🔖 Flag actualizado: ", flag, " = ", value)

func get_flag(flag: String, default = false):
	return flags.get(flag, default)

# Gestionar inventario
func add_item(item: String, amount: int = 1) -> void:
	if inventory.has(item):
		inventory[item] += amount
	else:
		inventory[item] = amount
	print("📦 Añadido ", amount, "x ", item)

func remove_item(item: String, amount: int = 1) -> bool:
	if inventory.has(item) and inventory[item] >= amount:
		inventory[item] -= amount
		print("🗑️ Eliminado ", amount, "x ", item)
		return true
	print("❌ No hay suficiente ", item)
	return false

func has_item(item: String, amount: int = 1) -> bool:
	return inventory.get(item, 0) >= amount

func get_item_count(item: String) -> int:
	return inventory.get(item, 0)

# Gestionar dinero
func add_money(amount: int) -> void:
	player_money += amount
	print("💰 +", amount, " monedas. Total: ", player_money)

func subtract_money(amount: int) -> bool:
	if player_money >= amount:
		player_money -= amount
		print("💰 -", amount, " monedas. Total: ", player_money)
		return true
	print("❌ No hay suficiente dinero")
	return false

# Gestionar salud
func heal(amount: int) -> void:
	player_health = min(player_health + amount, player_max_health)
	print("❤️ +", amount, " salud. Salud actual: ", player_health, "/", player_max_health)

func take_damage(amount: int) -> bool:
	player_health -= amount
	print("💔 -", amount, " salud. Salud actual: ", player_health, "/", player_max_health)
	
	if player_health <= 0:
		player_health = 0
		print("💀 GAME OVER - El jugador ha muerto")
		return true  # Game over
	return false

# Gestionar misiones
func start_mission(mission_id: String) -> void:
	if mission_id not in active_missions and mission_id not in completed_missions:
		active_missions.append(mission_id)
		print("📜 Misión iniciada: ", mission_id)

func complete_mission(mission_id: String) -> void:
	if mission_id in active_missions:
		active_missions.erase(mission_id)
		completed_missions.append(mission_id)
		print("✅ Misión completada: ", mission_id)

func is_mission_active(mission_id: String) -> bool:
	return mission_id in active_missions

func is_mission_completed(mission_id: String) -> bool:
	return mission_id in completed_missions

# Gestionar villas
func travel_to_villa(villa_id: int) -> void:
	current_villa = villa_id
	print("🚂 Viajando a Villa ", villa_id)

# Evidencias (para el Proyecto Leteo)
func add_evidence(evidence_id: String) -> void:
	if evidence_id not in inventory["evidence"]:
		inventory["evidence"].append(evidence_id)
		print("🔍 Evidencia encontrada: ", evidence_id)

func has_evidence(evidence_id: String) -> bool:
	return evidence_id in inventory["evidence"]

# ============================================
# RESET DEL JUEGO (para nuevas partidas)
# ============================================
func reset_game() -> void:
	player_name = ""
	player_gender = ""
	remembered_name = ""
	player_health = 100
	player_money = 500
	current_villa = 1
	completed_missions = []
	active_missions = []
	inventory = {
		"antena_parts": 0,
		"evidence": [],
		"keys": [],
		"medicines": 0
	}
	flags = {}
	print("🔄 Juego reiniciado completamente")
