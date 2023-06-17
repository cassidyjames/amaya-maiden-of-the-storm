extends Control

const _KeyMapping : PackedScene = preload("res://objects/ui/key_mapping.tscn")

@onready var vbox_settings : VBoxContainer = $VBox_Settings
@onready var arrow : TextureRect = $Arrow

enum State {INACTIVE, ACTIVE}

var current_state : int = State.ACTIVE
var rebinding_action : String
var cursor_index : int = 0
var rebind_hold : float = 0.0
var rebind_done : bool = false

signal closed

func add_boolean_option(label : String, action : String, value : bool) -> void:
	var mapping : Control = _KeyMapping.instantiate()
	vbox_settings.add_child(mapping)
	mapping.set_action(action, label)
	mapping.set_key("On" if value else "Off")

func add_volume_option(label : String, action : String, value : float) -> void:
	var mapping : Control = _KeyMapping.instantiate()
	vbox_settings.add_child(mapping)
	mapping.set_action(action, label)
	mapping.set_key(str(int(value * 100.0)) + "%")

func handle_button_pressed() -> void:
	var action : String = vbox_settings.get_child(cursor_index).action
	match action:
		"fullscreen":
			Settings.fullscreen = !Settings.fullscreen
			Settings.apply_config()
			Settings.save_config()
			vbox_settings.get_child(cursor_index).set_key("On" if Settings.fullscreen else "Off")
		"show_mouse_cursor":
			Settings.show_mouse_cursor = !Settings.show_mouse_cursor
			Settings.apply_config()
			Settings.save_config()
			vbox_settings.get_child(cursor_index).set_key("On" if Settings.show_mouse_cursor else "Off")

func handle_volume_change(change : float) -> void:
	var action : String = vbox_settings.get_child(cursor_index).action
	match action:
		"bgm":
			Settings.bgm_volume = clamp(Settings.bgm_volume + change, 0.0, 1.0)
			Settings.bgm_volume = round(Settings.bgm_volume * 10.0) / 10.0
			Settings.apply_volumes()
			Settings.save_config()
			vbox_settings.get_child(cursor_index).set_key(str(int(Settings.bgm_volume * 100.0)) + "%")
		"sfx":
			Settings.sfx_volume = clamp(Settings.sfx_volume + change, 0.0, 1.0)
			Settings.sfx_volume = round(Settings.sfx_volume * 10.0) / 10.0
			Settings.apply_volumes()
			Settings.save_config()
			vbox_settings.get_child(cursor_index).set_key(str(int(Settings.sfx_volume * 100.0)) + "%")
		"amb":
			Settings.amb_volume = clamp(Settings.amb_volume + change, 0.0, 1.0)
			Settings.amb_volume = round(Settings.amb_volume * 10.0) / 10.0
			Settings.apply_volumes()
			Settings.save_config()
			vbox_settings.get_child(cursor_index).set_key(str(int(Settings.amb_volume * 100.0)) + "%")
		"ui":
			Settings.ui_volume = clamp(Settings.ui_volume + change, 0.0, 1.0)
			Settings.ui_volume = round(Settings.ui_volume * 10.0) / 10.0
			Settings.apply_volumes()
			Settings.save_config()
			vbox_settings.get_child(cursor_index).set_key(str(int(Settings.ui_volume * 100.0)) + "%")

func _input(event : InputEvent) -> void:
	match current_state:
		State.ACTIVE:
			if event.is_action_pressed("up"):
				cursor_index = wrapi(cursor_index - 1, 0, vbox_settings.get_child_count())
				arrow.position.y = 120 + (20 * cursor_index)
			elif event.is_action_pressed("down"):
				cursor_index = wrapi(cursor_index + 1, 0, vbox_settings.get_child_count())
				arrow.position.y = 120 + (20 * cursor_index)
			elif event.is_action_pressed("jump"):
				handle_button_pressed()
			elif event.is_action_pressed("run_left"):
				handle_volume_change(-0.1)
			elif event.is_action_pressed("run_right"):
				handle_volume_change(0.1)
			elif event.is_action_pressed("change_wind"):
				current_state = State.INACTIVE
				emit_signal("closed")
				get_viewport().set_input_as_handled()

func _ready() -> void:
	add_boolean_option("Fullscreen", "fullscreen", Settings.fullscreen)
	add_boolean_option("Show Mouse Cursor", "show_mouse_cursor", Settings.show_mouse_cursor)
	add_volume_option("BGM", "bgm", Settings.bgm_volume)
	add_volume_option("SFX", "sfx", Settings.sfx_volume)
	add_volume_option("AMB", "amb", Settings.amb_volume)
	add_volume_option("UI", "ui", Settings.ui_volume)
