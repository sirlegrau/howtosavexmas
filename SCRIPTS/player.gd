extends CharacterBody2D


var momevemtSpeed = 80.0
var hp = 100
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#Attacks
var iceSpear = preload("res://SCENES/ATTACK/ice_spear.tscn")

#Attack NODES
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 1
var icespear_attackspeed = 1.5
var icespear_level = 1

#Enemy Reloted
var enemy_close = []

func _ready():
	attack()

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start();



func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()
func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -=1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()

#GET CLOSEST ENEMY
#func get_target()->Vector2:
#	if enemy_close.size() > 0:
#		return get_closest_enemy(global_position, enemy_close).global_position
#	else:
#		return Vector2.UP
#
#
#func get_closest_enemy(current_position: Vector2, enemies):
#	var closest_enemy = null
#	var closest_distance:float = 1e20  # Initialize with a large number
#	
#	for enemy in enemies:
#		var distance = current_position.distance_to(enemy.global_position)
#		if distance < closest_distance:
#			closest_distance = distance
#			closest_enemy = enemy	
#	return closest_enemy
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _physics_process(delta):
	movement()

func movement():
	#func movement():
	#	var direction = Input.get_vector("left","right","up","down")
	#velocity = direction * speed
	#move_and_slide()

	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	if x_mov > 0:
		sprite.flip_h = true
	elif x_mov < 0:
		sprite.flip_h = false

	if mov != Vector2.ZERO:
		if walkTimer.is_stopped():
			sprite.frame = (sprite.frame+1) % sprite.hframes
			#if sprite.frame >= sprite.hframes -1:
			#	sprite.frame = 0
			#else:
			#	sprite.frame +=1
			walkTimer.start()
	velocity = mov.normalized()*momevemtSpeed
	move_and_slide()



func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= damage
	print(hp)


func _on_enemy_detection_area_body_exited(body):
	if  enemy_close.has(body):
		enemy_close.erase(body)

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)
