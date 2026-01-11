extends RigidBody3D

class_name Propeller


var _rigid_body: RigidBody3D


func _attach_to_parent() -> void:
    var parent = self.get_parent()
    if not is_instance_of(parent, RigidBody3D):
        push_warning("Invalid parent, skipping attachment process")
        self._rigid_body = self
        return

    self._rigid_body = parent

    for child_node in self.get_children():
        child_node.call_deferred("reparent", self._rigid_body)

    self.freeze = true

    # TODO: move parent's center of gravity & update the mass based on the rigid body


func _ready() -> void:
    self._attach_to_parent()


const POWER_UPDATE_SPEED: float = 40

@export var initial_power: float = 0
@onready var desired_power: float = self.initial_power
@onready var _current_power: float = self.initial_power


func _update_power_output(delta: float) -> void:
    var power_delta: float = self.POWER_UPDATE_SPEED * delta
    if self._current_power < self.desired_power:
        self._current_power += power_delta
        if self._current_power > self.desired_power:
            self._current_power = self.desired_power
    elif self._current_power > self.desired_power:
        self._current_power -= power_delta
        if self._current_power < self.desired_power:
            self._current_power = self.desired_power


@onready var _blades: CollisionShape3D = $Blades


func _apply_thrust() -> void:
    self._rigid_body.apply_force(
        self._rigid_body.basis * Vector3(0, self._current_power, 0),
        self._rigid_body.basis * self._blades.position,
    )


enum RotationDirection {CLOCKWISE = -1, COUNTER_CLOCKWISE = 1}

const YAW_COEFFICIENT: float = 0.2
@export var rotation_direction: RotationDirection = RotationDirection.CLOCKWISE


func _apply_yaw_force() -> void:
    var yaw_force_position: Vector3 = (
        self._rigid_body.basis
        * Vector3(self._blades.position.x, 0, self._blades.position.z)
    )
    self._rigid_body.apply_force(
        yaw_force_position.rotated(
            self._rigid_body.basis.y,
            self.rotation_direction * PI / 2
        ) * self.YAW_COEFFICIENT * self._current_power,
        yaw_force_position,
    )


func _physics_process(delta: float) -> void:
    self._update_power_output(delta)
    self._apply_thrust()
    self._apply_yaw_force()
