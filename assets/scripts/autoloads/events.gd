extends Node

# Señales que sí se usan
signal dialog_started(dialog_id)
signal dialog_finished

# Señales para sistema de radio (se usarán después)
signal radio_message(message_id)

# Señales para sistema de misiones (se usarán después)
signal mission_started(mission_id)
signal mission_completed(mission_id)
