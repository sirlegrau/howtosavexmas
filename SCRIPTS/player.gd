extends CharacterBody2D


var momevemtSpeed = 80.0
var hp = 100
var maxhp = 100
var last_movement = Vector2.UP

var experience = 0
var experience_level = 1
var collected_experience = 0 

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#Attacks
var iceSpear = preload("res://SCENES/ATTACK/ice_spear.tscn")
var tornado = preload("res://SCENES/ATTACK/tornado.tscn")
var javelin = preload("res://SCENES/ATTACK/javelin.tscn")
#Attack NODES
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")

#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0 
var spell_size = 0
var additional_attacks = 0

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 1

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 1
var tornado_attackspeed = 1.5
var tornado_level = 0

#Javelin
var javelin_ammo = 0
var javelin_level = 0

#Enemy Reloted
var enemy_close = []


#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lbllevel = get_node("%LevelLabel")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://SCENES/UTILS/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelUP")

func _ready():
	upgrade_character("icespear1")
	attack()
	set_expBar(experience, calculate_experiencecap())

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1-spell_cooldown)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start();
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1-spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start();
	if javelin_level > 0:
		spawn_javelin()



func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo + additional_attacks
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
		last_movement = mov
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
	hp -= clamp(damage-armor, 1.0, 999)
	print(hp)


func _on_enemy_detection_area_body_exited(body):
	if  enemy_close.has(body):
		enemy_close.erase(body)

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo + additional_attacks
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -=1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()

func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	#Update javelin
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()



#EXPERIENCE STUFF
func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self
	


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
		
func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required-experience
		experience_level +=1
		
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
		
	set_expBar(experience, exp_required)
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level*5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level-19)*8
	else:
		exp_cap = 255 +(experience_level-39)*12
	return exp_cap
	
func set_expBar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value


func levelup():
	lbllevel.text = str("Level: ", experience_level)
	sndLevelUp.play()
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true


func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			momevemtSpeed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.05
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
	
	
	
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var dbList = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add: 
				dbList.append(i)
		else:
			dbList.append(i)
			
	if dbList.size() > 0:
		var randomItem = dbList.pick_random()
		upgrade_options.append(randomItem)
		return randomItem
	else:
		return null
