extends RigidBody3D


@onready var propellers: Array[Propeller] = [
    $PropellerFrontRight,
    $PropellerFrontLeft,
    $PropellerBackLeft,
    $PropellerBackRight,
]


class PropellerWithActions:
    var propeller: Propeller
    var increase_action_name: StringName
    var decrease_action_name: StringName

    func _init(
        p_propeller: Propeller,
        p_increase_action_name: StringName,
        p_decrease_action_name: StringName,
    ) -> void:
        self.propeller = p_propeller
        self.increase_action_name = p_increase_action_name
        self.decrease_action_name = p_decrease_action_name


func _physics_process(_delta: float) -> void:
    print(self.position, self.rotation)

    for propeller_with_actions: PropellerWithActions in [
        PropellerWithActions.new(
            $PropellerFrontRight,
            "quadcopter_front_right_increase_power",
            "quadcopter_front_right_decrease_power",
        ),
        PropellerWithActions.new(
            $PropellerFrontLeft,
            "quadcopter_front_left_increase_power",
            "quadcopter_front_left_decrease_power",
        ),
        PropellerWithActions.new(
            $PropellerBackLeft,
            "quadcopter_back_left_increase_power",
            "quadcopter_back_left_decrease_power",
        ),
        PropellerWithActions.new(
            $PropellerBackRight,
            "quadcopter_back_right_increase_power",
            "quadcopter_back_right_decrease_power",
        ),
    ]:
        if Input.is_action_pressed(propeller_with_actions.increase_action_name):
            propeller_with_actions.propeller.desired_power = 7.5
        elif Input.is_action_pressed(propeller_with_actions.decrease_action_name):
            propeller_with_actions.propeller.desired_power = -2.5
        else:
            propeller_with_actions.propeller.desired_power = 2.5
