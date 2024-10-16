extends CharacterBody2D

@export var movementSpeed = 40.0
@export var hp = 10
@export var knockback_recovery = 3.5
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var animations = $AnimationPlayer
@onready var snd_hit = $snd_hit

var death_anim = preload("res://SCENES/UTILS/explosion.tscn")

signal remove_from_array(object)

func _ready():
	animations.play("walk")


func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movementSpeed
	velocity += knockback
	
	move_and_slide()
	if direction.x > 0.2:
		sprite.flip_h = true
	elif direction.x < -0.2:
		sprite.flip_h = false

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
func death():
	emit_signal("remove_from_array",self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	queue_free()
	
	
