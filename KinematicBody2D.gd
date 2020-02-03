extends KinematicBody2D

const UP = Vector2(0, -1)
var velocity = Vector2()
export var speed = 600
export var gravity = 700
export var jump_velocity = -550
var canMove = true
var is_grounded
var is_falling
var is_ascending
var is_on_wall
var wallJumpDirection = "left"
var isWallJumping = false

onready var floorRays = $FloorRays
onready var landRays = $LandRays
onready var wallRays = $WallRays
onready var wallJumpTimer = $WallJumpTimer

func _physics_process(delta):
	var movement_direction = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))
	if canMove:
		getInput(movement_direction)
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, UP)
		is_grounded = _check_is_grounded()


func _input(event):
	if event.is_action_pressed("jump") && is_grounded:
		$Sprite.play("startJump")
		velocity.y = jump_velocity

func getInput(movement_direction):
#	var movement_direction = -int(Input.is_action_pressed("ui_left")) + int(Input.is_action_pressed("ui_right"))	
	velocity.x = lerp(velocity.x, speed * movement_direction, 0.2)
	# In the air
	if !is_grounded:
		if _check_is_on_wall():
			if !isWallJumping:
				wallJump(movement_direction)
		if _check_is_falling():
			$Sprite.play("land")
		else:
			$Sprite.play("jump")
			
	# On the ground
	if movement_direction != 0:
		$Sprite.scale.x = movement_direction
		if _check_is_grounded():		
			$Sprite.play("run")
	elif _check_is_grounded():
		$Sprite.play("idle")
		
func _check_is_grounded():
	for raycast in floorRays.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func _check_is_falling():
	for raycast in landRays.get_children():
		if !_check_is_grounded():
			if raycast.is_colliding():
				return true
	return false
	
func _check_is_on_wall():
	for raycast in wallRays.get_children():
		if !isWallJumping:
			if raycast.is_colliding():
				return true
	return false

func wallJump(movement_direction):
	for raycast in wallRays.get_children():
		if raycast.is_colliding():
			if raycast.name == "LeftWall" && Input.is_action_pressed("jump"):
				if movement_direction > 0:
					isWallJumping = true
					canMove = false
					isWallJumping = true
					wallJumpDirection = "right"
					wallJumpTimer.start()
			if raycast.name == "RightWall" && Input.is_action_pressed("jump"):
				if movement_direction < 0:
					isWallJumping = true
					canMove = false
					wallJumpDirection = "left"
					wallJumpTimer.start()					

func _on_WallJumpTimer_timeout():
	canMove = true
	velocity.y = jump_velocity
	if wallJumpDirection == "left":
		velocity.x = -2000
	elif wallJumpDirection == "right":
		velocity.x = 2000
	else:
		velocity.x = 0
	isWallJumping = false
