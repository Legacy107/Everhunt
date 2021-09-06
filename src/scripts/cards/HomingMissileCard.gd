extends Card


export var _CardEffect = preload("res://src/components/card_effects/HomingMissile.tscn")
export var _card_aims_at_mouse = false


func _init().(_CardEffect, _card_aims_at_mouse):
	pass


remote func activate_card(state):
	shoot_projectile_with_origin_and_direction(
		instance_card_effect(state["card_effect_instance_id"])
	)
