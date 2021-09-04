extends KinematicBody2D

class_name Player


var MOVE_SPEED = 400
var MAX_MOVE_SPEED = 600
var JUMP_FORCE = 800
var MAX_FALL_SPEED = 800
var GRAVITY = 50
var FRICTION = 100


onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()
var Cards = {
	"BulletCard" : preload("res://src/components/cards/BulletCard.tscn"),
	"HomingMissileCard" : preload("res://src/components/cards/HomingMissileCard.tscn")
}


onready var WorldNode = get_node("/root/Game/World")


onready var Flip = $Flip
onready var Hand = $Flip/Hand
onready var Mouse = $Mouse
onready var Camera = $Camera2D
onready var AnimationPlayer = $AnimationPlayer
onready var WallClimbDebounce = $WallClimbDebounce
onready var Container = WorldNode.get_node("EntityContainer/" + str(get_network_master()))


var team_id = 0
var y_velo = 0
var x_velo = 0
var facing_right = true
var double_jump = true
var cards = ["BulletCard", "HomingMissileCard"]


onready var player_state = {
	"position" : position,
	"facing_right" : facing_right,
	"animation" : "Idle",
	"mouse_position" : get_global_mouse_position(),
}


func _ready():
	if is_network_master():
		Camera.current = true
		z_index = 2

	append_card(0)
	append_card(1)


func _physics_process(_delta):
	if not is_network_master():
		return

	var move_dir = 0

	if Input.is_action_pressed("right"):
		move_dir += 1
	if Input.is_action_pressed("left"):
		move_dir -= 1
	if Input.is_action_pressed("down"):
		y_velo = MAX_FALL_SPEED

	var x_speed = move_dir * MOVE_SPEED + x_velo

	if x_speed < 0:
		x_speed = max(x_speed, -MAX_MOVE_SPEED)
	else:
		x_speed = min(x_speed, MAX_MOVE_SPEED)

	if x_speed != 0 or y_velo != 0:
# warning-ignore:return_value_discarded
		move_and_slide(Vector2(x_speed, y_velo), Vector2(0, -1))

		player_state["position"] = position

	var grounded = is_on_floor()
	var hit_ceiling = is_on_ceiling()
	var wall_climb = (
		not grounded and
		y_velo > -FRICTION and
		is_on_wall() and (
			Input.is_action_pressed("right") or
			Input.is_action_pressed("left")
		)
	)

	if wall_climb:
		WallClimbDebounce.start()

	var enable_wall_jump = WallClimbDebounce.time_left > 0

	if grounded or wall_climb:
		double_jump = true

	y_velo += GRAVITY
	if x_velo:
		if x_velo < 0:
			x_velo += FRICTION
		else:
			x_velo -= FRICTION

	if (grounded or enable_wall_jump or double_jump) \
		and Input.is_action_just_pressed("up"):
		y_velo = -JUMP_FORCE
		if enable_wall_jump:
			if facing_right:
				x_velo = -JUMP_FORCE
			else:
				x_velo =  JUMP_FORCE

			enable_wall_jump = false
			wall_climb = false
		elif not grounded:
			y_velo += JUMP_FORCE / 2
			double_jump = false

	if wall_climb:
		y_velo = FRICTION
	if (grounded and y_velo >= 0) or hit_ceiling:
		y_velo = 5
	if y_velo > MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED

	facing_right = Mouse.global_position.x > global_position.x
	flip()

	if grounded:
		if move_dir == 0:
			player_state["animation"] = "Idle"
		else:
			player_state["animation"] = "Walk"
	elif wall_climb:
		player_state["animation"] = "Wall climb"
	elif y_velo < 0:
		if double_jump:
			player_state["animation"] = "Jump"
		else:
			player_state["animation"] = "Double jump"
	elif y_velo >= 0:
		player_state["animation"] = "Fall"

	NodeUtil.play_animation(AnimationPlayer, player_state["animation"])

	Mouse.global_position = get_global_mouse_position()

	player_state["mouse_position"] = Mouse.global_position

	ServerHandler.synchronize_unreliable(get_path(), "update_player_state", player_state)


func flip():
	if facing_right:
		Flip.scale.x = 1
	else:
		Flip.scale.x = -1

	player_state["facing_right"] = facing_right




remote func append_card(card_id):
	var CardInstance = Cards[cards[card_id]].instance()

	CardInstance.set_network_master(get_network_master())
	CardInstance.setup(Container, Mouse, Hand.position, card_id)

	Flip.add_child(CardInstance)


remote func erase_card(card_id):
	Flip.get_node(cards[card_id]).queue_free()


remote func update_player_state(state):
	if not is_network_master():
		position = state["position"]

		if state["facing_right"]:
			Flip.scale.x = 1
		else:
			Flip.scale.x = -1

		NodeUtil.play_animation(AnimationPlayer, state["animation"])

		Mouse.global_position = state["mouse_position"]
