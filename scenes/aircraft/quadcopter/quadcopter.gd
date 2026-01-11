extends RigidBody3D


@onready var propellers: Array[Propeller] = [
    $PropellerFrontRight,
    $PropellerFrontLeft,
    $PropellerBackLeft,
    $PropellerBackRight,
]


func _ready() -> void:
    for propeller in self.propellers:
        propeller.current_power = 2.5
        propeller.desired_power = 2.5


func _physics_process(_delta: float) -> void:
    print(self.position, self.rotation)

    if Input.is_action_pressed("left_rotor_collective_up"):
        for propeller in self.propellers:
            propeller.desired_power = 7.5
    elif Input.is_action_pressed("left_rotor_collective_down"):
        for propeller in self.propellers:
            propeller.desired_power = -2.5
    else:
        for propeller in self.propellers:
            propeller.desired_power = 2.5
