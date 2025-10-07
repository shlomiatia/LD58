class_name TypingLabel extends Label

@export var characters_per_second: float = 30.0
@export var sounds_per_second: float = 10.0

var _target_visible_chars: int = 0
var _current_visible_chars: float = 0.0
var _sound_timer: float = 0.0
var _sound_interval: float = 0.0
var _is_typing: bool = false

var _audio_players: Array[AudioStreamPlayer] = []
var _sound_streams: Array[AudioStream] = []

func _ready() -> void:
	_sound_streams = [
		preload("res://Sounds/confirm1.wav"),
		preload("res://Sounds/confirm2.wav"),
		preload("res://Sounds/confirm3.wav")
	]

	for i in range(3):
		var player = AudioStreamPlayer.new()
		add_child(player)
		_audio_players.append(player)

	_sound_interval = 1.0 / sounds_per_second if sounds_per_second > 0 else 0.0

	if text != "":
		visible_characters = 0
		_start_typing()

func _process(delta: float) -> void:
	if not _is_typing:
		return

	_current_visible_chars += characters_per_second * delta
	var new_visible = int(_current_visible_chars)

	if new_visible != visible_characters:
		visible_characters = new_visible

	if visible_characters >= _target_visible_chars:
		visible_characters = _target_visible_chars
		_is_typing = false
		return

	_sound_timer += delta
	if _sound_timer >= _sound_interval:
		_play_random_sound()
		_sound_timer = 0.0

func _start_typing() -> void:
	_target_visible_chars = text.length()
	_current_visible_chars = 0.0
	visible_characters = 0
	_sound_timer = 0.0
	_is_typing = true

func _play_random_sound() -> void:
	if _sound_streams.is_empty():
		return

	for player in _audio_players:
		if not player.playing:
			player.stream = _sound_streams[randi() % _sound_streams.size()]
			player.pitch_scale = randf_range(0.9, 1.1)
			player.play()
			return

func _set(property: StringName, value: Variant) -> bool:
	if property == "text":
		text = value
		if is_node_ready() and text != "":
			_start_typing()
		return true
	return false
