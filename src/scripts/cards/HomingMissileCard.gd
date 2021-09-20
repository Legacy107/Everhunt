extends Card


export var card_settings = {
	"CardEffect" : preload("res://src/components/cardEffects/HomingMissile.tscn"),
	"card_aims_at_mouse" : true,
	"card_only_activate_on_click" : false,
	"card_can_be_dropped" : false,
	"card_charges" : 5000,
	"card_cooldown" : 0.001,
	"card_swivel_dampening" : 0.3,
}


func _init().(card_settings):
	pass


remote func activate_card(state):
	var CardEffectInstance = instance_card_effect(state["card_effect_instance_id"])
	var origin = Muzzle.global_position
	var direction = (Mouse.global_position - Muzzle.global_position).normalized()

	if (Mouse.global_position - Origin.global_position).length() \
		<= (Muzzle.global_position - Origin.global_position).length():
		direction = (Muzzle.global_position - Origin.global_position).normalized()

	CardEffectInstance.setup(origin, direction)

	.activate_card(state)
