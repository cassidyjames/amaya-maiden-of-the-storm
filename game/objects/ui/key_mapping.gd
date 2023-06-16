extends Control

@onready var label_action : Label = $Label_Action
@onready var label_key : Label = $Label_Key

var action : String

func set_action(action : String, name : String) -> void:
	label_action.text = name
	self.action = action

func set_key(key : String) -> void:
	label_key.text = key
