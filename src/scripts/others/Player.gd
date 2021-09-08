class_name Player

extends KinematicBody2D


export var MOVE_SPEED = 400
export var MAX_MOVE_SPEED = 600
export var JUMP_FORCE = 800
export var MAX_FALL_SPEED = 800
export var GRAVITY = 50
export var FRICTION = 100


onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()


onready var Container = get_node("/root/Game/World/EntityContainer/" + name)


onready var Flip = $Flip
onready var Hand = $Flip/Hand
onready var Mouse = $Mouse
onready var Camera = $Camera2D
onready var AnimationPlayer = $AnimationPlayer
onready var WallClimbDebounce = $WallClimbDebounce


var ready = false
var team_id = 0
var cards_size = 2
var cards = []


var y_velo = 0
var x_velo = 0
var facing_right = true
var double_jump = true


onready var player_state = {
	"position" : position,
	"facing_right" : facing_right,
	"animation" : "Idle",
	"mouse_position" : get_global_mouse_position(),
}


func _ready():
	ready = true

	for _id in range (cards_size):
		cards.append("")

	if is_network_master():
		Camera.current = true
		z_index = 2


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




remote func update_player_state(state):
	if not is_network_master():
		position = state["position"]

		if state["facing_right"]:
			Flip.scale.x = 1
		else:
			Flip.scale.x = -1

		NodeUtil.play_animation(AnimationPlayer, state["animation"])

		Mouse.global_position = state["mouse_position"]
