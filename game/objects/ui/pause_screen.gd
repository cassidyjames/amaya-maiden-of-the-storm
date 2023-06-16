extends Control

const _SettingsScreen : PackedScene = preload("res://objects/ui/settings_screen.tscn")
const _ControlsScreen : PackedScene = preload("res://objects/ui/keybinding_screen.tscn")

@onready var vbox_buttons : VBoxContainer = $VBox_Buttons
@onready var cursor : Control = $Cursor

enum State {ACTIVE, SUBMENU}

var subscreen : Control
var cursor_index : int = 0
var current_state : int = State.ACTIVE

func move_cursor(change : int) -> void:
	cursor_index = wrapi(cursor_index + change, 0, vbox_buttons.get_child_count())
	cursor.position.y = 142 + (cursor_index * 20)

func goto_submenu(scene : PackedScene) -> void:
	subscreen = scene.instantiate()
	add_child(subscreen)
	subscreen.closed.connect(_on_subscreen_closed)
	subscreen.position = Vector2(0, 0)
	vbox_buttons.hide()
	cursor.hide()
	current_state = State.SUBMENU

func _on_subscreen_closed() -> void:
	subscreen.queue_free()
	subscreen = null
	vbox_buttons.show()
	cursor.show()
	current_state = State.ACTIVE

func _input(event : InputEvent) -> void:
	if current_state != State.ACTIVE:
		return
	if event.is_action_pressed("up"):
		move_cursor(-1)
	elif event.is_action_pressed("down"):
		move_cursor(1)
	elif event.is_action_pressed("change_wind"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		queue_free()
	elif event.is_action_pressed("jump"):
		match cursor_index:
			0:
				get_tree().paused = false
				queue_free()
			1:
				goto_submenu(_SettingsScreen)
			2:
				goto_submenu(_ControlsScreen)
			3:
				get_tree().quit()
