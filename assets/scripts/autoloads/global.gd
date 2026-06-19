extends Node

var player_name: String = ""
var player_gender: String = ""
var remembered_name: String = ""

var player_health: int = 100
var player_max_health: int = 100
var player_money: int = 500

var inventory = {
	"antena_parts": 0,
	"evidence": [],
	"keys": [],
	"medicines": 0
}

var flags = {}

func set_flag(key: String, value):
	flags[key] = value

func get_flag(key: String, default_value = false):
	return flags.get(key, default_value)

func add_item(item: String, amount: int = 1):
	if inventory.has(item):
		inventory[item] += amount
	else:
		inventory[item] = amount

func has_item(item: String, amount: int = 1) -> bool:
	return inventory.get(item, 0) >= amount

func heal(amount: int):
	player_health = min(player_health + amount, player_max_health)
