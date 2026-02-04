extends Node3D
## A 3rd person camera with fixed roll and pitch
##
## However the camera is placed initially (relative to the target_node),
## is stored and will be kept the same after target_node moves and/or rotates
##
## Initial rotation is not relevant, since the camera always looks at the target_node
##
## Right now the camera flips when the target flips (full 180 on the direction of the Z axis)
## it is kinda intended, the -Z axis is always "forward", but it does look kinda weird
##
## Maybe the problem is the absence of a good environment,
## maybe roll and pitch locking won't be needed then
##
## A collision detection system is worth adding:
## https://docs.godotengine.org/en/latest/tutorials/3d/spring_arm.html
##
## Also a first-person camera is possible, but it is quite nauseating,
## at least with the current settings and without an environment

@export var target_node: Node3D

@onready var relative_position: Vector3 = self.position - self.target_node.position


func _process(_delta: float) -> void:
    self.position = (
        self.target_node.position
        + self.relative_position.rotated(Vector3.UP, self.target_node.rotation.y)
    )
    self.look_at(self.target_node.position)
