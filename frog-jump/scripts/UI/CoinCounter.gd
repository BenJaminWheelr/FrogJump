extends CanvasLayer

@onready var label = $Label2


func _ready() -> void:
	var global_state = get_node_or_null("/root/GlobalState")
	if global_state != null:
		_update_coin_count(global_state.coin_count)
		if global_state.has_signal("coin_count_changed"):
			global_state.coin_count_changed.connect(_update_coin_count)


func _update_coin_count(new_count: int) -> void:
	if label != null:
		label.text = "Coin: %d" % new_count
