extends AudioStreamPlayer3D
class_name InterauralAudioStreamPlayer3D


const MAX_INTERAURAL_MOVEMENT_PER_STEP: float = 0.005

@export var listener: Node3D


@export var enable_interaural: bool = true:
	set(val):
		if enable_interaural and not val:
			_disable_interaural()
		enable_interaural = val


var interaural_delay_effect: AudioEffectDelay
var bus_idx: int



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not listener:
		listener = get_viewport().get_camera_3d()
	bus_idx = _create_bus()
	bus = AudioServer.get_bus_name(bus_idx)






## Returns a name for the audio bus created for this node
func _get_bus_name() -> String:
	return str("Interaural_", get_instance_id())


## Returns the index of the created bus
func _create_bus() -> int:
	var i: int = AudioServer.bus_count
	AudioServer.add_bus()
	AudioServer.set_bus_name(i, _get_bus_name())
	AudioServer.set_bus_send(i, bus)
	interaural_delay_effect = AudioEffectDelay.new()
	AudioServer.add_bus_effect(i, interaural_delay_effect)
	interaural_delay_effect.dry = 0.0
	interaural_delay_effect.tap1_active = true
	interaural_delay_effect.tap2_active = true
	interaural_delay_effect.tap1_level_db = 0.0
	interaural_delay_effect.tap2_level_db = 0.0
	interaural_delay_effect.tap1_pan = -1
	interaural_delay_effect.tap2_pan = 1
	interaural_delay_effect.tap1_delay_ms = 0.0
	interaural_delay_effect.tap2_delay_ms = 0.0
	return i

func _disable_interaural() -> void:
	if not is_node_ready():
		await ready
	interaural_delay_effect.tap1_delay_ms = 0.0
	interaural_delay_effect.tap2_delay_ms = 0.0


var left_ear_delay: float
var right_ear_delay: float

## Update the interaural_delay_effect with the current delays for each ear.
## Note that in an effort to reduce artifacts, this implementation always pins the closer ear to 0.0 milliseconds of delay,
## but a physically accurate effect should actually just apply the full delay to each ear
## (and doing that would also give you a physically accurate doppler effect for free).
func _update_interaural() -> void:
	const SPEED_OF_SOUND: float = 340.29
	const SOUND_SECONDS_PER_METER: float = 1.0 / SPEED_OF_SOUND
	const SOUND_MS_PER_METER: float = SOUND_SECONDS_PER_METER * 1000
	
	var relative_sound_pos: Vector3 = listener.to_local(global_position)
	var left_ear_travel_time: float = Vector3(-0.11, 0, 0).distance_to(relative_sound_pos) * SOUND_MS_PER_METER
	var right_ear_travel_time: float = Vector3(0.11, 0, 0).distance_to(relative_sound_pos) * SOUND_MS_PER_METER
	
	#var left_ear_delay: float
	#var right_ear_delay: float
	if left_ear_travel_time < right_ear_travel_time:
		 # Right ear delay is longer, remove left delay, add delay to right.
		left_ear_delay = 0.0
		right_ear_delay = right_ear_travel_time - left_ear_travel_time
	else:
		# Left ear delay is longer, remove right delay, add delay to left.
		right_ear_delay = 0.0
		left_ear_delay = left_ear_travel_time - right_ear_travel_time
	
	interaural_delay_effect.tap1_delay_ms = move_toward(interaural_delay_effect.tap1_delay_ms, left_ear_delay, MAX_INTERAURAL_MOVEMENT_PER_STEP)
	interaural_delay_effect.tap2_delay_ms = move_toward(interaural_delay_effect.tap2_delay_ms, right_ear_delay, MAX_INTERAURAL_MOVEMENT_PER_STEP)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if enable_interaural:
		_update_interaural()


#func _physics_process(_delta: float) -> void:
#	print(interaural_delay_effect.tap1_delay_ms)
