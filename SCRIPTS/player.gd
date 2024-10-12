extends CharacterBody2D


var momevemtSpeed = 80.0
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

func _physics_process(delta):
    movement()

func movement():

    #func movement():
    #    var direction = Input.get_vector("left","right","up","down")
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
            #    sprite.frame = 0
            #else:
            #    sprite.frame +=1
            walkTimer.start()
    velocity = mov.normalized()*momevemtSpeed
    move_and_slide()

