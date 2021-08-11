extends KinematicBody2D


var MOVE_SPEED = 400
var MAX_MOVE_SPEED = 600
var JUMP_FORCE = 800
var MAX_FALL_SPEED = 800
var GRAVITY = 50
var FRICTION = 100
var LENGTH = 50


onready var Spr = $Sprite
onready var AnimPlayer = $AnimationPlayer
onready var Cam = $Camera2D
onready var WallClimbDebounce = $WallClimbDebounce
onready var Hand = $Hand
onready var Trajectory = $Trajectory
onready var Mouse = get_parent().get_node("Mouse")


var y_velo = 0
var x_velo = 0
var facing_right = true
var double_jump = true


onready var player_state = {
	"name" : name,
	"pos" : position,
	"flip" : Spr.flip_h,
	"hand_pos" : Hand.position.x,
	"anim" : "Idle",
	"dir" : (get_local_mouse_position() - Hand.position).normalized(),
	"ability" : "Bullet",
	"mouse_name" : Mouse.name,
	"mouse_pos" : Mouse.position
}


func _ready():
	if !is_network_master():
		Trajectory.hide()
	else:
		Cam.current = true
		z_index = 2


func _physics_process(_delta):
	if !is_network_master():
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
		move_and_slide(Vector2(x_speed, y_velo), Vector2(0, -1))
		
		player_state["pos"] = position
	
	var grounded = is_on_floor()
	var hit_ceiling = is_on_ceiling()
	var wall_climb = (
		!grounded && 
		y_velo > -FRICTION && 
		is_on_wall() && (
			Input.is_action_pressed("right") || 
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
	
	if (grounded or enable_wall_jump or double_jump) and Input.is_action_just_pressed("up"):
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
	
	if facing_right and move_dir < 0:
		flip()
	if !facing_right and move_dir > 0:
		flip()
	
	if grounded:
		if move_dir == 0:
			player_state["anim"] = "Idle"
		else:
			player_state["anim"] = "Walk"
	elif wall_climb:
		player_state["anim"] = "Wall climb"
	elif y_velo < 0:
		if double_jump:
			player_state["anim"] = "Jump"
		else:
			player_state["anim"] = "Double jump"
	elif y_velo >= 0:
		player_state["anim"] = "Fall"
	
	play_anim(player_state["anim"])
	
	update_trajectory()
	
	EntityHandler.synchronize("update_player_state", player_state)


func _input(event):
	if !is_network_master():
		return
	
	var just_pressed = event.is_pressed() and not event.is_echo()
	
	if event.is_action_pressed("activate") and just_pressed:
		EntityHandler.synchronize("activate_ability", player_state)
	if event.is_action_pressed("ability_1") and just_pressed:
		player_state["ability"] = "Bullet"
	if event.is_action_pressed("ability_2") and just_pressed:
		player_state["ability"] = "HomingMissile"


func flip():
	facing_right = !facing_right
	Spr.flip_h = !Spr.flip_h
	Hand.position.x *= -1
	
	player_state["flip"] = Spr.flip_h
	player_state["hand_pos"] = Hand.position.x


func play_anim(anim_name):
	if AnimPlayer.is_playing() and AnimPlayer.current_animation == anim_name:
		return
	
	AnimPlayer.play(anim_name)


func update_trajectory():
	var direction = (get_local_mouse_position() - Hand.position).normalized()
	
	player_state["dir"] = direction
	player_state["mouse_pos"] = get_global_mouse_position()
	
	Trajectory.clear_points()
	Trajectory.add_point(Hand.position)
	Trajectory.add_point(Hand.position + direction * LENGTH)
