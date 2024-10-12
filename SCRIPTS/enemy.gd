extends CharacterBody2D

@export var movementSpeed = 20.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var animations = $AnimationPlayer

func _ready():
    animations.play("walk")


func _physics_process(_delta):
    var direction = global_position.direction_to(player.global_position)
    velocity = direction*movementSpeed
    move_and_slide()

    if direction.x > 0.2:
        sprite.flip_h = true
    elif direction.x < -0.2:
        sprite.flip_h = false

 