extends Node

signal coin_count_changed(new_value: int)

var coin_count: int = 0


func _ready() -> void:
	_load_coins_from_save()
	SaveManager.data_modified.connect(_on_data_reset)
	
func _on_data_reset() -> void:
	coin_count = int(SaveManager.data.player.coins)


func _load_coins_from_save() -> void:
	if SaveManager.data.has("player") and SaveManager.data["player"].has("coins"):
		coin_count = int(SaveManager.data["player"]["coins"])
	else:
		coin_count = 0

	coin_count_changed.emit(coin_count)


func _persist_coins() -> void:
	if not SaveManager.data.has("player"):
		SaveManager.data["player"] = {}

	SaveManager.data["player"]["coins"] = coin_count
	SaveManager.save_game()


func add_coin(amount: int = 1) -> void:
	coin_count += amount
	if coin_count < 0:
		coin_count = 0

	_persist_coins()
	coin_count_changed.emit(coin_count)


func set_coins(value: int) -> void:
	coin_count = max(value, 0)
	_persist_coins()
	coin_count_changed.emit(coin_count)


func reset_coins() -> void:
	coin_count = 0
	_persist_coins()
	coin_count_changed.emit(coin_count)
