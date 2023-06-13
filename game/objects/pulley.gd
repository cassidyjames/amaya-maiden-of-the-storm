extends Node2D

const DESCEND_SPEED : float = 100.0

@export_node_path("Node2D") var path_left_object
@export_node_path("Node2D") var path_right_object

@onready var left_object : WetPushThing = get_node(path_left_object)
@onready var right_object : WetPushThing = get_node(path_right_object)
@onready var chain_top : Sprite2D = $Chain_Top
@onready var chain_left : Sprite2D = $Chain_Left
@onready var chain_right : Sprite2D = $Chain_Right

func _physics_process(delta : float) -> void:
	var mass_difference : float = right_object.get_mass_of_self_and_top() - left_object.get_mass_of_self_and_top()
	var left_chain_length : float = left_object.global_position.y - global_position.y
	var right_chain_length : float = right_object.global_position.y - global_position.y
	var heavy_item : Node2D = right_object if mass_difference > 0.0 else left_object
	var light_item : Node2D = left_object if mass_difference > 0.0 else right_object
	var heavy_chain : Sprite2D = chain_right if mass_difference > 0.0 else chain_left
	var light_chain : Sprite2D = chain_left if mass_difference > 0.0 else chain_right
	var heavy_chain_length : float = right_chain_length if mass_difference > 0.0 else left_chain_length
	var light_chain_length : float = left_chain_length if mass_difference > 0.0 else right_chain_length

	if mass_difference != 0.0:
		var descent_amount : float = abs(mass_difference) * DESCEND_SPEED * delta
		descent_amount = min(descent_amount, clamp(light_chain_length, 0.0, 500.0))
		var remainder : float = heavy_item.descend(descent_amount)
		var amount_moved : float = descent_amount - remainder
		var ascend_remainder : float = light_item.descend(-amount_moved)
		heavy_item.descend(-ascend_remainder)
		amount_moved -= ascend_remainder
		chain_top.region_rect.position.y += amount_moved
		heavy_chain.region_rect.position.y -= amount_moved
		light_chain.region_rect.position.y += amount_moved
		heavy_chain.region_rect.size.y += amount_moved
		light_chain.region_rect.size.y -= amount_moved

func _ready() -> void:
	chain_left.region_rect.size.y = left_object.global_position.y - global_position.y
	chain_right.region_rect.size.y = right_object.global_position.y - global_position.y
