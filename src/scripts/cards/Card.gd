class_name Card

extends RigidBody2D


onready var MathUtil = preload("res://src/utils/MathUtil.gd").new()
onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()


onready var Pivot = $Pivot
onready var Area = $Pivot/Area2D
onready var Origin = $Pivot/Origin
onready var Muzzle = $Pivot/Muzzle
onready var Handle = $Handle
onready var AnimationPlayer = $AnimationPlayer
onready var Tween = $Tween
onready var CoolDownDebounce = $CoolDownDebounce
onready var PickUpDebounce = $PickUpDebounce


var Player_
var Container
var Mouse
var team_id = -1
var card_id = -1


var ready = false
var equipped = false


var CardEffect
var card_aims_at_mouse
var card_only_activate_on_click
var card_can_be_dropped
var card_charges
var card_cooldown
var card_swivel_dampening


onready var card_state = {
	"card_effect_instance_id" : 0
}


func _init(card_info):
	for variable in card_info:
		set(variable, card_info[variable])


func _ready():
	ready = true

	CoolDownDebounce.wait_time = card_cooldown


func _physics_process(_delta):
	if card_aims_at_mouse:
		aim_at_mouse()

	if is_network_master():
		update_trajectory()

		if not card_only_activate_on_click:
			handle_activate_card_event(Input)


func _input(event):
	if not is_network_master():
		return

	var just_pressed = event.is_pressed() and not event.is_echo()

	if not just_pressed:
		return

	if card_only_activate_on_click:
		handle_activate_card_event(event)

	if card_can_be_dropped:
		handle_drop_card_event(event)

	handle_equip_card_event(event, 0)
	handle_equip_card_event(event, 1)


func aim_at_mouse():
	Tween.stop(Pivot, "rotation")

	Tween.interpolate_property(
		Pivot, "rotation",
		Pivot.rotation, MathUtil.calculate_pivot_rotation(Pivot, Mouse, Origin),
		card_swivel_dampening, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)

	Tween.start()


func update_trajectory():
	pass


func handle_activate_card_event(event):
	if event.is_action_pressed("activate") and equipped and CoolDownDebounce.time_left <= 0:
		ServerHandler.synchronize_client(get_path(), "activate_card", card_state)


func handle_drop_card_event(event):
	if event.is_action_pressed("drop") and equipped:
		ServerHandler.synchronize_client(get_path(), "unsetup", card_state)


func handle_equip_card_event(event, id):
	if event.is_action_pressed("card_" + str(id)):
		if card_id == id:
			ServerHandler.synchronize_client(get_path(), "equip", card_state)
		else:
			ServerHandler.synchronize_client(get_path(), "unequip", card_state)


func instance_card_effect(card_effect_instance_id):
	var CardEffectInstance = CardEffect.instance()

	CardEffectInstance.set_network_master(get_network_master())
	CardEffectInstance.set_name(CardEffectInstance.name + str(card_effect_instance_id))

	Container.add_child(CardEffectInstance)

	return CardEffectInstance


func change_physics(mode):
	set_deferred("mode", mode)


func _on_touchdown(_body):
	change_physics(MODE_KINEMATIC)


func _on_body_entered(body):
	if not (body is Player):
		return

	if (body == Player_) and PickUpDebounce.time_left > 0:
		return

	if card_charges <= 0:
		return

	setup(body)




remote func setup(_Player):
	for id in range (_Player.cards_size):
		if _Player.cards[id] == "":
			_Player.cards[id] = name
			card_id = id
			break

	if card_id == -1:
		return

	set_network_master(int(_Player.name))

	Player_ = _Player
	Container = _Player.Container
	Mouse = _Player.Mouse
	team_id = _Player.team_id

	if not ready:
		yield(self, "ready")

	NodeUtil.reparent(self, _Player.Flip)
	change_physics(MODE_KINEMATIC)
	set_deferred("position", _Player.Hand.position - Handle.position)

	if self.is_connected("body_entered", self, "_on_touchdown"):
		self.disconnect("body_entered", self, "_on_touchdown")
	if Area.is_connected("body_entered", self, "_on_body_entered"):
		Area.disconnect("body_entered", self, "_on_body_entered")

	unequip(card_state)


remote func unsetup(_state):
	Player_.cards[card_id] = ""
	card_id = -1

	set_network_master(-1)

	if not ready:
		yield(self, "ready")

	NodeUtil.reparent(self, Container)
	change_physics(MODE_RIGID)
	set_deferred("global_position", global_position)
	set_deferred("linear_velocity", Vector2(0, 0))
# warning-ignore:return_value_discarded
	self.connect("body_entered", self, "_on_touchdown")
	Area.connect("body_entered", self, "_on_body_entered")

	unequip(card_state)
	show()

	PickUpDebounce.start()


remote func equip(_state):
	equipped = true
	show()
	set_physics_process(true)


remote func unequip(_state):
	equipped = false
	hide()
	set_physics_process(false)


remote func activate_card(_state):
	card_state["card_effect_instance_id"] += 1
	card_charges -= 1

	CoolDownDebounce.start()

	if card_charges <= 0:
		unsetup(card_state)
		yield(get_tree().create_timer(4), "timeout")
		queue_free()
