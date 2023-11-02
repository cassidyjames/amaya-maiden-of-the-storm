extends Node

const CONFIG_PATH : String = "user://config.ini"
const ACTIONS : Array = ["up", "down", "run_left", "run_right", "jump", "change_wind", "change_wind_left", "change_wind_right", "restart_level", "pause"]
const ACTION_NAMES : Dictionary = {
	"up": "Up", "down": "Down", "run_left": "Left", "run_right": "Right", "jump": "Jump/Confirm", "change_wind": "Change Wind/Cancel", "change_wind_left": "Quickchange Left", "change_wind_right": "Quickchange Right", "restart_level": "Restart Level", "pause": "Pause"
}
const DEFAULT_BINDINGS : Dictionary = {
	"up": KEY_UP, "down": KEY_DOWN, "run_left": KEY_LEFT, "run_right": KEY_RIGHT, "jump": KEY_X, "change_wind": KEY_C, "change_wind_left": KEY_COMMA, "change_wind_right": KEY_PERIOD, "restart_level": KEY_R, "pause": KEY_ENTER
}
const DEFAULT_BUTTONS : Dictionary = {
	"up": JOY_BUTTON_DPAD_UP, "down": JOY_BUTTON_DPAD_DOWN, "run_left": JOY_BUTTON_DPAD_LEFT, "run_right": JOY_BUTTON_DPAD_RIGHT, "jump": JOY_BUTTON_A, "change_wind": JOY_BUTTON_X, "change_wind_left": JOY_BUTTON_LEFT_SHOULDER, "change_wind_right": JOY_BUTTON_RIGHT_SHOULDER, "restart_level": JOY_BUTTON_BACK, "pause": JOY_BUTTON_START
}
const ALLOWED_BUTTONS : Array = [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y, JOY_BUTTON_BACK, JOY_BUTTON_START, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]
const BUTTON_ICON_OFFSET : Dictionary = {
	JOY_BUTTON_A: 0, JOY_BUTTON_B: 16, JOY_BUTTON_X: 32, JOY_BUTTON_Y: 48, JOY_BUTTON_BACK: 64, JOY_BUTTON_START: 80, JOY_BUTTON_LEFT_SHOULDER: 96, JOY_BUTTON_RIGHT_SHOULDER: 112, JOY_BUTTON_DPAD_UP: 128, JOY_BUTTON_DPAD_DOWN: 144, JOY_BUTTON_DPAD_LEFT: 160, JOY_BUTTON_DPAD_RIGHT: 176
}

var fullscreen : bool
var show_mouse_cursor : bool
var vibration : bool
var sfx_volume : float
var bgm_volume : float
var amb_volume : float
var ui_volume : float
var key_mappings : Dictionary
var button_mappings : Dictionary

var config : ConfigFile = ConfigFile.new()

func change_bus_volume(bus_name : String, value : float) -> void:
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func apply_action_mapping(action_name : String, keyboard_code : int, button_code : int) -> void:
	InputMap.action_erase_events(action_name)
	var event_key : InputEventKey = InputEventKey.new()
	event_key.physical_keycode = keyboard_code
	InputMap.action_add_event(action_name, event_key)
	var event_button : InputEventJoypadButton = InputEventJoypadButton.new()
	event_button.button_index = button_code
	InputMap.action_add_event(action_name, event_button)
	key_mappings[action_name] = keyboard_code
	button_mappings[action_name] = button_code

func apply_key_binding(action_name : String, keyboard_code : int) -> void:
	key_mappings[action_name] = keyboard_code
	apply_action_mapping(action_name, key_mappings[action_name], button_mappings[action_name])

func apply_button_binding(action_name : String, button_code : int) -> void:
	button_mappings[action_name] = button_code
	apply_action_mapping(action_name, key_mappings[action_name], button_mappings[action_name])

func apply_config() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if show_mouse_cursor else Input.MOUSE_MODE_HIDDEN

func apply_volumes() -> void:
	change_bus_volume("SFX", sfx_volume)
	change_bus_volume("BGM", bgm_volume)
	change_bus_volume("AMB", amb_volume)
	change_bus_volume("UI", ui_volume)

func apply_action_mappings() -> void:
	for action in ACTIONS:
		apply_action_mapping(action, key_mappings[action], button_mappings[action])

func set_mappings_from_input_map() -> void:
	for action in ACTIONS:
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				var keycode : int = config.get_value("controls", action, event.physical_keycode)
				key_mappings[action] = keycode
			elif event is InputEventJoypadButton:
				var button : int = config.get_value("buttons", action, event.button_index)
				button_mappings[action] = button

func reset_key_bindings() -> void:
	key_mappings = DEFAULT_BINDINGS.duplicate()
	Settings.save_config()

func save_config() -> void:
	config.load(CONFIG_PATH)
	config.set_value("graphics", "fullscreen", fullscreen)
	config.set_value("graphics", "show_mouse_cursor", show_mouse_cursor)
	config.set_value("misc", "vibration", vibration)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "amb_volume", amb_volume)
	config.set_value("audio", "ui_volume", ui_volume)
	for action in ACTIONS:
		config.set_value("controls", action, key_mappings[action])
	config.save(CONFIG_PATH)

func load_config() -> void:
	config.load(CONFIG_PATH)
	fullscreen = config.get_value("graphics", "fullscreen", true)
	show_mouse_cursor = config.get_value("graphics", "show_mouse_cursor", false)
	vibration = config.get_value("misc", "vibration", true)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	bgm_volume = config.get_value("audio", "bgm_volume", 1.0)
	amb_volume = config.get_value("audio", "amb_volume", 1.0)
	ui_volume = config.get_value("audio", "ui_volume", 1.0)
	set_mappings_from_input_map()

func _ready() -> void:
	load_config()
	apply_config()
	apply_volumes()
	apply_action_mappings()
