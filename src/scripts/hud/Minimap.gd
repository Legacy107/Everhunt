extends MarginContainer

export var ZOOM = 8
export var SIGHT_RADIUS = 400

onready var SightViewport = $Margin/SightContainer/SightViewport
onready var MarkerContainer = $Margin/MarkerContainer
onready var SightIndicator = $Margin/SightContainer/SightIndicator
onready var PlayerMarker = $Margin/MarkerContainer/PlayerMarker
onready var AllyMarker = $Margin/MarkerContainer/AllyMarker
onready var EnemyMarker = $Margin/MarkerContainer/EnemyMarker

var markers = {}
var sight_indicators = {}
var team_id = null
var delete_buffer = []


func _ready():
	SightIndicator.radius = SIGHT_RADIUS / ZOOM
# warning-ignore:return_value_discarded
	GameEvent.connect("player_disconnected", self, "_on_object_removed")


func _process(_delta):
	var players = get_tree().get_nodes_in_group("Player")

	remove_disconnected_players(players)
	check_new_players(players)
	update_markers(players)
	update_sight_indicator()


func remove_disconnected_players(players):
	for Player_ in players:
		if delete_buffer.has(Player_.name):
			players.erase(Player_)

	delete_buffer.clear()


func check_new_players(players):
	for Player_ in players:
		# Add a marker if a new player joins
		if not (Player_.name in markers.keys()):
			var Marker
			if Player_.is_network_master():
				Marker = PlayerMarker.duplicate()
				team_id = Player_.team_id
				add_sight_indicator(Player_.name, SightIndicator.duplicate())
			elif team_id == null:
				continue
			elif Player_.team_id == team_id:
				Marker = AllyMarker.duplicate()
				add_sight_indicator(Player_.name, SightIndicator.duplicate())
			else:
				Marker = EnemyMarker.duplicate()

			add_marker(Player_.name, Marker)


func update_markers(players):
	for Player_ in players:
		if Player_.team_id != team_id:
			if is_in_sight(players, Player_):
				markers[Player_.name].show()
			else:
				markers[Player_.name].hide()
				continue

		markers[Player_.name].rect_position = Player_.global_position / ZOOM \
			- markers[Player_.name].rect_size / 2


func is_in_sight(players, _Player):
	var is_in_sight = false

	for Player_ in players:
		if Player_.team_id == team_id \
			and (Player_.global_position - _Player.global_position).length() \
			<= SIGHT_RADIUS:

			is_in_sight = true

	return is_in_sight


func update_sight_indicator():
	for key in sight_indicators.keys():
		sight_indicators[key].position = markers[key].rect_position \
			+ markers[key].rect_size / 2


func add_marker(key, Marker):
	MarkerContainer.add_child(Marker)
	Marker.show()
	markers[key] = Marker


func add_sight_indicator(key, SightIndicator_):
	SightViewport.add_child(SightIndicator_)
	SightIndicator_.show()
	sight_indicators[key] = SightIndicator_


func _on_object_removed(key):
	key = str(key)
	delete_buffer.append(key)

	if key in markers:
		markers[key].queue_free()
		markers.erase(key)

	if key in sight_indicators:
		sight_indicators[key].queue_free()
		sight_indicators.erase(key)
