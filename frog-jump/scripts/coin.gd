extends Area2D

@export var player_group_name := "player"
var _collected := false


func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")


func _on_body_entered(body: Node) -> void:
	if _collected:
		return
	if body == null or not body.is_in_group(player_group_name):
		return

	_collected = true
	_add_coin_to_global_state(1)
	queue_free()


func _add_coin_to_global_state(amount: int) -> void:
	var global_state = get_node_or_null("/root/GlobalState")
	if global_state != null and global_state.has_method("add_coin"):
		global_state.call("add_coin", amount)
