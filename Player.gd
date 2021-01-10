extends KinematicBody2D

const MOVE_SPEED = 500
const JUMP_FORCE = 1000
const GRAVITY = 50
const FRICTION = 100
const MAX_FALL_SPEED = 1000
const MAX_MOVE_SPEED = 600

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite
onready var wall_climb_debounce = $WallClimbDebounce

var y_velo = 0
var x_velo = 0
var facing_right = true
var double_jump = true

func _physics_process(delta):
	var move_dir = 0
	if Input.is_action_pressed("right"):
		move_dir += 1
	if Input.is_action_pressed("left"):
		move_dir -= 1
	if Input.is_action_pressed("down"):
		y_velo = MAX_FALL_SPEED
	
	move_and_slide(Vector2(move_dir * MOVE_SPEED + x_velo, y_velo), Vector2(0, -1))
	
	var grounded = is_on_floor()
	var hit_ceiling = is_on_ceiling()
	var wall_climb = !grounded && y_velo>0 && is_on_wall() && (Input.is_action_pressed("right") || Input.is_action_pressed("left"))
	if wall_climb:
		wall_climb_debounce.start()
	var enable_wall_jump = wall_climb_debounce.time_left > 0
	if grounded:
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
			play_anim("Idle")
		else:
			play_anim("Walk")
	elif wall_climb:
		play_anim("Wall climb")
	elif y_velo < 0:
		if double_jump:
			play_anim("Jump")
		else:
			play_anim("Double jump")
	elif y_velo>=0:
		play_anim("Fall")

func flip():
	facing_right = !facing_right
	sprite.flip_h = !sprite.flip_h

func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	anim_player.play(anim_name)
