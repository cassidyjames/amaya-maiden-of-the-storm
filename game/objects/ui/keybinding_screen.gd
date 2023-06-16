extends Control

const _KeyMapping : PackedScene = preload("res://objects/ui/key_mapping.tscn")

@onready var vbox_actions : VBoxContainer = $VBox_Actions
@onready var label_prompt : Label = $Label_Prompt
@onready var arrow : TextureRect = $Arrow

enum State {INACTIVE, ACTIVE, BINDING}

var current_state : int = State.ACTIVE
var rebinding_action : String
var cursor_index : int = 0
var rebind_hold : float = 0.0
var rebind_done : bool = false

signal closed

func _input(event : InputEvent) -> void:
	match current_state:
		State.ACTIVE:
			if event.is_action_pressed("jump"):
				rebinding_action = vbox_actions.get_child(cursor_index).action
				label_prompt.text = "Press a button for " + Settings.ACTION_NAMES[rebinding_action] + "..."
				vbox_actions.get_child(cursor_index).set_key("...")
				current_state = State.BINDING
			elif event.is_action_pressed("up"):
				cursor_index = wrapi(cursor_index - 1, 0, vbox_actions.get_child_count())
				arrow.position.y = 100 + (20 * cursor_index)
			elif event.is_action_pressed("down"):
				cursor_index = wrapi(cursor_index + 1, 0, vbox_actions.get_child_count())
				arrow.position.y = 100 + (20 * cursor_index)
			elif event.is_action_pressed("change_wind"):
				current_state = State.INACTIVE
				emit_signal("closed")
				get_viewport().set_input_as_handled()
				
		State.BINDING:
			if event is InputEventKey and event.is_pressed():
				Settings.apply_keybinding(rebinding_action, event.physical_keycode)
				Settings.save_config()
				var key_name : String = OS.get_keycode_string(Settings.mappings[rebinding_action])
				vbox_actions.get_child(cursor_index).set_key(key_name)
				label_prompt.text = "Hold F12 to reset all bindings."
				current_state = State.ACTIVE

func _process(delta : float) -> void:
	if Input.is_action_pressed("rebind_all") and current_state == State.ACTIVE:
		rebind_hold += delta
	else:
		rebind_hold = 0.0
		rebind_done = false
	if rebind_hold >= 1.0 and !rebind_done:
		Settings.reset_key_bindings()
		for child in vbox_actions.get_children():
			var key_name : String = OS.get_keycode_string(Settings.mappings[child.action])
			child.set_key(key_name)
		label_prompt.text = "All bindings reset to default."
		rebind_done = true

func _ready() -> void:
	for action in Settings.ACTIONS:
		var mapping : Control = _KeyMapping.instantiate()
		vbox_actions.add_child(mapping)
		var action_name : String = Settings.ACTION_NAMES[action]
		var key_name : String = OS.get_keycode_string(Settings.mappings[action])
		mapping.set_action(action, action_name)
		mapping.set_key(key_name)
