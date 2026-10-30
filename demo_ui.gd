extends VBoxContainer



@onready var panning_label: Label = $PanningLabel
@onready var interaural_label: Label = $InterauralLabel


@export var interaural_audio_stream_player: InterauralAudioStreamPlayer3D


var panning: bool = true
var interaural: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_ui_and_settings()



func _update_ui_and_settings() -> void:
	panning_label.text = str("Panning [J] : ", "enabled" if panning else "disabled")
	interaural_label.text = str("Interaural [K] : ", "enabled" if interaural else "disabled")
	
	interaural_audio_stream_player.enable_interaural = interaural
	interaural_audio_stream_player.panning_strength = int(panning)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_panning"):
		panning = not panning
		_update_ui_and_settings()
	elif event.is_action_pressed("toggle_interaural"):
		interaural = not interaural
		_update_ui_and_settings()
