class_name Card

extends RigidBody2D


onready var MathUtil = preload("res://src/utils/MathUtil.gd").new()
onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()


onready var Pivot = $Pivot
onready var Origin = $Pivot/Origin
onready var Muzzle = $Pivot/Muzzle
onready var Handle = $Handle
onready var AnimationPlayer = $AnimationPlayer
onready var Tween = $Tween


var CardEffect
var card_aims_at_mouse


var Container
var Mouse
var hand_position
var card_id
var equipped = false


onready var card_state = {
	"card_effect_instance_id" : 0
}


func _init(_CardEffect, _card_aims_at_mouse):
	CardEffect = _CardEffect
	card_aims_at_mouse = _card_aims_at_mouse


func setup(_Container, _Mouse, _hand_position, _card_id):
	Container = _Container
	Mouse = _Mouse
	hand_position = _hand_position
	card_id = _card_id


func _ready():
	position = hand_position - Handle.position

	unequip(card_state)


func _physics_process(_delta):
	if not card_aims_at_mouse:
		return

	update_card()


func _input(event):
	if not is_network_master():
		return

	var just_pressed = event.is_pressed() and not event.is_echo()

	if just_pressed:
		if event.is_action_pressed("activate") and equipped:
			card_state["card_effect_instance_id"] += 1

			ServerHandler.synchronize_client(get_path(), "activate_card", card_state)

		for id in range(2):
			if event.is_action_pressed("card_" + str(id)):
				if card_id == id:
					ServerHandler.synchronize_client(get_path(), "equip", card_state)
				else:
					ServerHandler.synchronize_client(get_path(), "unequip", card_state)


func update_card():
	Tween.interpolate_property(
		Pivot, "rotation",
		Pivot.rotation, MathUtil.calculate_pivot_rotation(Pivot, Mouse, Origin),
		.03, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)

	Tween.start()


func instance_card_effect(card_effect_instance_id):
	var CardEffectInstance = CardEffect.instance()

	CardEffectInstance.set_network_master(get_network_master())
	CardEffectInstance.set_name(CardEffectInstance.name + str(card_effect_instance_id))

	Container.add_child(CardEffectInstance)

	return CardEffectInstance


func shoot_projectile_with_origin_and_direction(CardEffectInstance):
	var origin = Muzzle.global_position
	var direction = (Mouse.global_position - Muzzle.global_position).normalized()

	if (Mouse.global_position - Origin.global_position).length() \
		<= (Muzzle.global_position - Origin.global_position).length():
		direction = (Muzzle.global_position - Origin.global_position).normalized()

	CardEffectInstance.setup(origin, direction)




remote func equip(_state):
	equipped = true
	show()
	set_physics_process(true)


remote func unequip(_state):
	equipped = false
	hide()
	set_physics_process(false)


remote func activate_card(state):
	pass
