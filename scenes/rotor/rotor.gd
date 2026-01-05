extends CollisionShape3D

class_name Rotor

enum RotorDirection {FORWARDS, CENTERED, BACKWARDS}

var desired_collective_direction: RotorDirection = RotorDirection.CENTERED


func set_desired_collective_direction(direction: RotorDirection) -> void:
    self.desired_collective_direction = direction


const MAX_TILT_ANGLE: float = PI / 4
const TILT_TIME: float = 1.0
const TILT_SPEED: float = self.MAX_TILT_ANGLE / self.TILT_TIME

const ROTOR_DIRECTION_TO_DESIRED_COLLECTIVE_ANGLE: Dictionary[RotorDirection, float] = {
    RotorDirection.FORWARDS: -self.MAX_TILT_ANGLE,
    RotorDirection.CENTERED: 0,
    RotorDirection.BACKWARDS: self.MAX_TILT_ANGLE,
}


func _move_towards_desired_collective_direction(delta: float) -> void:
    var desired_angle: float = (
        self.ROTOR_DIRECTION_TO_DESIRED_COLLECTIVE_ANGLE[self.desired_collective_direction]
    )
    var tilt_delta: float = self.TILT_SPEED * delta
    if self.rotation.x < desired_angle:
        self.rotation.x += tilt_delta
        if self.rotation.x > desired_angle:
            self.rotation.x = desired_angle
    elif self.rotation.x > desired_angle:
        self.rotation.x -= tilt_delta
        if self.rotation.x < desired_angle:
            self.rotation.x = desired_angle


var tilt: float:
    get: return self.rotation.x / self.MAX_TILT_ANGLE


var desired_cyclic_direction: RotorDirection = RotorDirection.CENTERED


func set_desired_cyclic_direction(direction: RotorDirection) -> void:
    self.desired_cyclic_direction = direction


const MAX_CYCLIC_OFFSET: float = 0.5
const CYCLIC_OFFSET_TIME: float = 1
const CYCLIC_OFFSET_SPEED: float = self.MAX_CYCLIC_OFFSET / self.CYCLIC_OFFSET_TIME

const ROTOR_DIRECTION_TO_DESIRED_CYCLIC_OFFSET: Dictionary[RotorDirection, float] = {
    RotorDirection.FORWARDS: MAX_CYCLIC_OFFSET,
    RotorDirection.CENTERED: 0,
    RotorDirection.BACKWARDS: -MAX_CYCLIC_OFFSET,
}

# This is a simplified way for a rotor to generate torque,
# it's simulated by moving the rotor's force to a different position on the z-axis
var current_cyclic_offset: float = (
    self.ROTOR_DIRECTION_TO_DESIRED_CYCLIC_OFFSET[RotorDirection.CENTERED]
)


func _move_towards_desired_cyclic_offset(delta: float) -> void:
    var desired_cyclic_offset: float = (
        self.ROTOR_DIRECTION_TO_DESIRED_CYCLIC_OFFSET[self.desired_cyclic_direction]
    )
    var cyclic_offset_delta: float = self.CYCLIC_OFFSET_SPEED * delta
    if self.current_cyclic_offset < desired_cyclic_offset:
        self.current_cyclic_offset += cyclic_offset_delta
        if self.current_cyclic_offset > desired_cyclic_offset:
            self.current_cyclic_offset = desired_cyclic_offset
    elif self.current_cyclic_offset > desired_cyclic_offset:
        self.current_cyclic_offset -= cyclic_offset_delta
        if self.current_cyclic_offset < desired_cyclic_offset:
            self.current_cyclic_offset = desired_cyclic_offset


enum PoverMode {HOVER, BOOSTED, REVERSE}

var power_mode: PoverMode = PoverMode.HOVER


func set_power_mode(mode: PoverMode) -> void:
    self.power_mode = mode


const HOVER_POWER: float = 5
const MAX_POWER: float = HOVER_POWER * 2
const POVER_MODE_TO_DESIRED_POWER: Dictionary[PoverMode, float] = {
    PoverMode.HOVER: self.HOVER_POWER,
    PoverMode.BOOSTED: self.MAX_POWER,
    PoverMode.REVERSE: -self.MAX_POWER,
}
const POWER_UPDATE_SPEED: float = 40

var current_combined_power: float = self.POVER_MODE_TO_DESIRED_POWER[PoverMode.HOVER]


func _move_towards_desired_power(delta: float) -> void:
    var desired_power: float = self.POVER_MODE_TO_DESIRED_POWER[self.power_mode]
    var power_delta: float = self.POWER_UPDATE_SPEED * delta
    if self.current_combined_power < desired_power:
        self.current_combined_power += power_delta
        if self.current_combined_power > desired_power:
            self.current_combined_power = desired_power
    elif self.current_combined_power > desired_power:
        self.current_combined_power -= power_delta
        if self.current_combined_power < desired_power:
            self.current_combined_power = desired_power


func _physics_process(delta: float) -> void:
    self._move_towards_desired_collective_direction(delta)
    self._move_towards_desired_cyclic_offset(delta)
    self._move_towards_desired_power(delta)


const HORIZONTAL_POWER_COEFFICIENT: float = 0.5


func get_current_force() -> Vector3:
    var max_vertical_output = (1 - abs(self.tilt) * 0.4) * MAX_POWER
    return Vector3(
        0,
        clamp(self.current_combined_power, -max_vertical_output, max_vertical_output),
        self.current_combined_power * self.tilt * self.HORIZONTAL_POWER_COEFFICIENT,
    )


func get_current_position() -> Vector3:
    return self.position + Vector3(0, 0, self.current_cyclic_offset)
