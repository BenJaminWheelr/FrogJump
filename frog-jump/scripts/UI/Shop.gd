extends CanvasLayer

signal item_purchased(item_id: String)
signal item_equipped(item_id: String)

@export_group("Settings")
@export var shop_window_scene: PackedScene
@export var select_sfx: AudioStream

@export_group("Shop Items")
@export var shop_items: Array[ShopItem] = []

@onready var scroll_container = $ScrollContainer
@onready var hbox = $ScrollContainer/MarginContainer/HBoxContainer

var player: Player = null


func _ready() -> void:
    _ensure_shop_data()
    _sync_item_states()
    _build_shop_ui()


func _build_shop_ui() -> void:
    for child in hbox.get_children():
        child.queue_free()

    var equipped_item_id := _get_equipped_item_id()

    for item in shop_items:
        if not item:
            continue

        var inst = shop_window_scene.instantiate()
        hbox.add_child(inst)

        var item_image = inst.get_node("MarginContainer/VBoxContainer/ItemImage") as TextureRect
        var item_name = inst.get_node("MarginContainer/VBoxContainer/ItemName") as Label
        var price_button = inst.get_node("MarginContainer/VBoxContainer/PriceButton") as Button

        item_image.texture = item.thumbnail
        item_name.text = item.name

        if item.is_coming_soon:
            price_button.text = "Coming Soon"
            price_button.disabled = true
            continue

        var is_owned := _is_item_owned(item.item_id)
        if not is_owned:
            price_button.text = "%d coins" % item.price
            price_button.disabled = false
            price_button.pressed.connect(_on_item_purchase_pressed.bind(item))
            continue

        price_button.disabled = false
        if equipped_item_id == item.item_id:
            price_button.text = "Unequip"
        else:
            price_button.text = "Equip"
        price_button.pressed.connect(_on_item_equip_toggled.bind(item))

    await get_tree().process_frame
    _scroll_to_first()


func _scroll_to_first() -> void:
    if hbox.get_child_count() > 0:
        scroll_container.scroll_horizontal = 0


func _sync_item_states() -> void:
    player = get_tree().get_first_node_in_group("player") as Player


func _ensure_shop_data() -> void:
    if not SaveManager.data.has("shop"):
        SaveManager.data["shop"] = {}
    if not SaveManager.data["shop"].has("owned_items"):
        SaveManager.data["shop"]["owned_items"] = []
    if not SaveManager.data["shop"].has("equipped_item"):
        SaveManager.data["shop"]["equipped_item"] = ""


func _is_item_owned(item_id: String) -> bool:
    return item_id in SaveManager.data["shop"]["owned_items"]


func _get_equipped_item_id() -> String:
    return str(SaveManager.data["shop"].get("equipped_item", ""))


func _on_item_purchase_pressed(item: ShopItem) -> void:
    var global_state = get_node_or_null("/root/GlobalState")
    if not global_state:
        return

    if global_state.coin_count < item.price:
        if select_sfx:
            GlobalAudio.play_sfx(select_sfx)
        return

    global_state.add_coin(-item.price)

    if not _is_item_owned(item.item_id):
        SaveManager.data["shop"]["owned_items"].append(item.item_id)

    SaveManager.data["shop"]["equipped_item"] = item.item_id
    SaveManager.save_game()

    _sync_item_states()
    _update_player_hat_sprite()
    item_purchased.emit(item.item_id)
    item_equipped.emit(item.item_id)
    _build_shop_ui()

    if select_sfx:
        GlobalAudio.play_sfx(select_sfx)


func _on_item_equip_toggled(item: ShopItem) -> void:
    var equipped_item_id := _get_equipped_item_id()
    if equipped_item_id == item.item_id:
        SaveManager.data["shop"]["equipped_item"] = ""
    else:
        SaveManager.data["shop"]["equipped_item"] = item.item_id

    SaveManager.save_game()
    _sync_item_states()
    _update_player_hat_sprite()
    item_equipped.emit(_get_equipped_item_id())
    _build_shop_ui()

    if select_sfx:
        GlobalAudio.play_sfx(select_sfx)


func _update_player_hat_sprite() -> void:
    if not player:
        return
    if player.has_method("refresh_hat_from_save"):
        player.refresh_hat_from_save()

