extends Control

@onready var label_action : Label = $Label_Action
@onready var label_key : Label = $Label_Key
@onready var texture_button : TextureRect = $Texture_Button

var action : String

func set_action(action : String, name : String) -> void:
	label_action.text = name
	self.action = action

func set_key(key : String) -> void:
	label_key.text = key

func set_button_texture_offset(offset : int) -> void:
	texture_button.texture.region.position.x = offset

func set_button_visible(on : bool) -> void:
	texture_button.visible = on

func _ready() -> void:
	texture_button.texture = texture_button.texture.duplicate()
