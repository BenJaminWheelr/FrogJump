extends Node

signal coin_count_changed(new_value: int)

var coin_count: int = 0

func add_coin(amount: int = 1) -> void:
	coin_count += amount
	coin_count_changed.emit(coin_count)

func reset_coins() -> void:
	coin_count = 0
	coin_count_changed.emit(coin_count)
