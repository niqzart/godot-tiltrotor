extends Node

# A 3rd person camera with fixed roll and pitch
#
# This flips the camera when the drone flips
# it is kinda intended, the -Z axis is always "forward", but it does look kinda weird
#
# I also haven't tested this well on combined rotation (roll + pitch),
# although it does seem fine flying around and it is intuitive to control
#
# Maybe the problem is the absence of a good environment,
# maybe roll and pitch locking won't be needed then
#
# A collision detection system is worth adding:
# https://docs.godotengine.org/en/latest/tutorials/3d/spring_arm.html
#
# Also a first-person camera is possible, but it is quite nauseating,
# at least with the current settings and without an environment


func _process(_delta: float) -> void:
    $CameraPivot.position = (
        $Quadcopter.position
        + Vector3(0, 15, 20).rotated(Vector3.UP, $Quadcopter.rotation.y)
    )
    $CameraPivot.look_at($Quadcopter.position)
