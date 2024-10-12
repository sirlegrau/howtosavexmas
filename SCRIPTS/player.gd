extends CharacterBody2D


var momevemtSpeed = 80.0

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
    velocity = mov.normalized()*momevemtSpeed
    move_and_slide()

