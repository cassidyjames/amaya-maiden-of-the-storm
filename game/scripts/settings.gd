extends Node

const CONFIG_PATH : String = "user://config.ini"
const ACTIONS : Array = ["up", "down", "run_left", "run_right", "jump", "change_wind", "restart_level", "pause"]
const ACTION_NAMES : Dictionary = {
	"up": "Up", "down": "Down", "run_left": "Left", "run_right": "Right", "jump": "Jump/Confirm", "change_wind": "Change Wind/Cancel", "restart_level": "Restart Level", "pause": "Pause"
}
const DEFAULT_BINDINGS : Dictionary = {
	"up": 4194320, "down": 4194322, "run_left": 4194319, "run_right": 4194321, "jump": 88, "change_wind": 67, "restart_level": 82, "pause": 4194305
}

var fullscreen : bool
var show_mouse_cursor : bool
var sfx_volume : float
var bgm_volume : float
var amb_volume : float
var ui_volume : float
var mappings : Dictionary

var config : ConfigFile = ConfigFile.new()

func change_bus_volume(bus_name : String, value : float) -> void:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func apply_keybinding(action_name : String, keyboard_code : int) -> void:
	InputMap.action_erase_events(action_name)
	var event_key : InputEventKey = InputEventKey.new()
	event_key.physical_keycode = keyboard_code
	InputMap.action_add_event(action_name, event_key)
	mappings[action_name] = keyboard_code

func apply_config() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if show_mouse_cursor else Input.MOUSE_MODE_HIDDEN
	change_bus_volume("SFX", sfx_volume)
	change_bus_volume("BGM", bgm_volume)
	change_bus_volume("AMB", amb_volume)
	change_bus_volume("UI", ui_volume)
	for action in ACTIONS:
		apply_keybinding(action, mappings[action])

func set_mappings_from_input_map() -> void:
	for action in ACTIONS:
		var event : InputEventKey = InputMap.action_get_events(action)[0]
		var keycode : int = config.get_value("controls", action, event.physical_keycode)
		mappings[action] = keycode

func reset_key_bindings() -> void:
	mappings = DEFAULT_BINDINGS.duplicate()
	Settings.save_config()

func save_config() -> void:
	config.load(CONFIG_PATH)
	config.set_value("graphics", "fullscreen", fullscreen)
	config.set_value("graphics", "show_mouse_cursor", show_mouse_cursor)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "amb_volume", amb_volume)
	config.set_value("audio", "ui_volume", ui_volume)
	for action in ACTIONS:
		config.set_value("controls", action, mappings[action])
	config.save(CONFIG_PATH)

func load_config() -> void:
	config.load(CONFIG_PATH)
	fullscreen = config.get_value("graphics", "fullscreen", true)
	show_mouse_cursor = config.get_value("graphics", "show_mouse_cursor", false)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	bgm_volume = config.get_value("audio", "bgm_volume", 1.0)
	amb_volume = config.get_value("audio", "amb_volume", 1.0)
	ui_volume = config.get_value("audio", "ui_volume", 1.0)
	set_mappings_from_input_map()

func _ready() -> void:
	load_config()
	apply_config()
