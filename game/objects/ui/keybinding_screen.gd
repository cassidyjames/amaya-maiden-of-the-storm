extends Control

const _KeyMapping : PackedScene = preload("res://objects/ui/key_mapping.tscn")

@onready var vbox_actions : VBoxContainer = $VBox_Actions
@onready var label_prompt : Label = $Label_Prompt
@onready var cursor : Control = $Cursor
@onready var arrow_left : Sprite2D = $Cursor/Arrow_Left
@onready var arrow_right : Sprite2D = $Cursor/Arrow_Right
@onready var audio_move : AudioStreamPlayer = $Audio_Move
@onready var audio_click : AudioStreamPlayer = $Audio_Click

enum State {INACTIVE, ACTIVE, BINDING}

var current_state : int = State.ACTIVE
var rebinding_action : String
var cursor_index : int = 0
var rebind_hold : float = 0.0
var rebind_done : bool = false

signal closed

func move_cursor(change : int) -> void:
	cursor_index = wrapi(cursor_index + change, 0, vbox_actions.get_child_count())
	for i in range(0, vbox_actions.get_child_count()):
		vbox_actions.get_child(i).modulate = Color("e4d793") if i == cursor_index else Color("6f673f")
	create_tween().tween_property(cursor, "position:y", 100 + (cursor_index * 20), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _on_timer_next_frame_timeout() -> void:
	arrow_left.frame = wrapi(arrow_left.frame + 1, 0, 18)
	arrow_right.frame = wrapi(arrow_right.frame + 1, 0, 18)

func _input(event : InputEvent) -> void:
	match current_state:
		State.ACTIVE:
			if event.is_action_pressed("jump"):
				rebinding_action = vbox_actions.get_child(cursor_index).action
				label_prompt.text = "Press a button for " + Settings.ACTION_NAMES[rebinding_action] + "..."
				vbox_actions.get_child(cursor_index).set_key("...")
				current_state = State.BINDING
				audio_click.play()
			elif event.is_action_pressed("up"):
				move_cursor(-1)
				audio_move.play()
			elif event.is_action_pressed("down"):
				move_cursor(1)
				audio_move.play()
			elif event.is_action_pressed("change_wind") or event.is_action_pressed("escape"):
				current_state = State.INACTIVE
				emit_signal("closed")
				get_viewport().set_input_as_handled()
				
		State.BINDING:
			if event is InputEventKey and event.is_pressed() and event.physical_keycode != KEY_ESCAPE:
				Settings.apply_keybinding(rebinding_action, event.physical_keycode)
				Settings.save_config()
				var key_name : String = OS.get_keycode_string(Settings.mappings[rebinding_action])
				vbox_actions.get_child(cursor_index).set_key(key_name)
				label_prompt.text = "Hold F12 to reset all bindings."
				current_state = State.ACTIVE
				audio_click.play()

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
	move_cursor(0)
