extends Control

const _SettingsScreen : PackedScene = preload("res://objects/ui/settings_screen.tscn")
const _ControlsScreen : PackedScene = preload("res://objects/ui/keybinding_screen.tscn")

@onready var vbox_buttons : VBoxContainer = $VBox_Buttons
@onready var cursor : Control = $Cursor
@onready var arrow_left : Sprite2D = $Cursor/Arrow_Left
@onready var arrow_right : Sprite2D = $Cursor/Arrow_Right
@onready var audio_move : AudioStreamPlayer = $Audio_Move
@onready var audio_submenu_open : AudioStreamPlayer = $Audio_SubmenuOpen
@onready var audio_submenu_close : AudioStreamPlayer = $Audio_SubmenuClose
@onready var audio_pause : AudioStreamPlayer = $Audio_Pause
@onready var audio_unpause : AudioStreamPlayer = $Audio_Unpause
@onready var anim_player : AnimationPlayer = $AnimationPlayer

enum State {ANIM_IN, ACTIVE, SUBMENU, ANIM_OUT}

var subscreen : Control
var cursor_index : int = 0
var current_state : int = State.ANIM_IN

func move_cursor(change : int) -> void:
	cursor_index = wrapi(cursor_index + change, 0, vbox_buttons.get_child_count())
	for i in range(0, vbox_buttons.get_child_count()):
		vbox_buttons.get_child(i).modulate = Color("e4d793") if i == cursor_index else Color("6f673f")
	create_tween().tween_property(cursor, "position:y", 142 + (cursor_index * 20), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func goto_submenu(scene : PackedScene) -> void:
	subscreen = scene.instantiate()
	add_child(subscreen)
	subscreen.closed.connect(_on_subscreen_closed)
	subscreen.position = Vector2(0, 0)
	vbox_buttons.hide()
	cursor.hide()
	current_state = State.SUBMENU
	audio_submenu_open.play()

func _on_subscreen_closed() -> void:
	subscreen.queue_free()
	subscreen = null
	vbox_buttons.show()
	cursor.show()
	current_state = State.ACTIVE
	audio_submenu_close.play()

func _on_timer_next_frame_timeout() -> void:
	arrow_left.frame = wrapi(arrow_left.frame + 1, 0, 18)
	arrow_right.frame = wrapi(arrow_right.frame + 1, 0, 18)

func _on_animation_player_animation_finished(anim_name : String) -> void:
	if anim_name == "pause":
		current_state = State.ACTIVE
	elif anim_name == "unpause":
		get_tree().paused = false
		queue_free()

func _input(event : InputEvent) -> void:
	if current_state != State.ACTIVE:
		return
	if event.is_action_pressed("up"):
		move_cursor(-1)
		audio_move.play()
	elif event.is_action_pressed("down"):
		move_cursor(1)
		audio_move.play()
	elif event.is_action_pressed("change_wind"):
		anim_player.play("unpause")
		audio_unpause.play()
		current_state = State.ANIM_OUT
	elif event.is_action_pressed("jump"):
		match cursor_index:
			0:
				anim_player.play("unpause")
				audio_unpause.play()
				current_state = State.ANIM_OUT
			1:
				goto_submenu(_SettingsScreen)
			2:
				goto_submenu(_ControlsScreen)
			3:
				get_tree().quit()

func _ready() -> void:
	move_cursor(0)
	audio_pause.play()
	anim_player.play("pause")
