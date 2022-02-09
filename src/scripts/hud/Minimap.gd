extends MarginContainer


export var ZOOM = 8
export var SIGHT_RADIUS = 400
export var NUMBER_OBJECTIVE = 3

onready var SightViewport = $Margin/SightContainer/SightViewport
onready var PlayerMarkerContainer = $Margin/PlayerMarkerContainer
onready var ObjectiveMarkerContainer = $Margin/ObjectiveMarkerContainer
onready var SightIndicator = $Margin/SightContainer/SightIndicator
onready var PlayerMarker = $Margin/PlayerMarkerContainer/PlayerMarker
onready var AllyMarker = $Margin/PlayerMarkerContainer/AllyMarker
onready var EnemyMarker = $Margin/PlayerMarkerContainer/EnemyMarker
onready var ObjectiveMarker = $Margin/ObjectiveMarkerContainer/ObjectiveMarker

var team_id = null
var players = []
var player_markers = {}
var sight_indicators = {}
var objective_markers = []


func _ready():
	SightIndicator.radius = SIGHT_RADIUS / ZOOM

# warning-ignore:return_value_discarded
	GameEvent.connect("player_appended", self, "_on_player_appended")
# warning-ignore:return_value_discarded
	GameEvent.connect("player_erased", self, "_on_player_erased")

	objective_markers.resize(NUMBER_OBJECTIVE)
	for id in range(NUMBER_OBJECTIVE):
		add_marker(
			id,
			ObjectiveMarkerContainer,
			ObjectiveMarker.duplicate(),
			objective_markers
		)


func _process(_delta):
	var objectives = get_tree().get_nodes_in_group("Objective")

	update_player_markers()
	update_sight_indicator()
	update_objective_markers(objectives)


func update_player_markers():
	for Player_ in players:
		if Player_.team_id != team_id:
			if is_in_sight(Player_):
				player_markers[Player_.name].show()
			else:
				player_markers[Player_.name].hide()
				continue

		player_markers[Player_.name].rect_position = (
			Player_.global_position / ZOOM
			- player_markers[Player_.name].rect_size / 2
		)


func is_in_sight(_Player):
	var is_in_sight = false

	for Player_ in players:
		if Player_.team_id == team_id \
			and (Player_.global_position - _Player.global_position).length() \
			<= SIGHT_RADIUS:

			is_in_sight = true

	return is_in_sight


func update_sight_indicator():
	for key in sight_indicators.keys():
		sight_indicators[key].position = player_markers[key].rect_position \
			+ player_markers[key].rect_size / 2


func add_marker(key, MarkerContainer, Marker, markers):
	MarkerContainer.add_child(Marker)
	Marker.show()
	markers[key] = Marker


func add_sight_indicator(key, SightIndicator_):
	SightViewport.add_child(SightIndicator_)
	SightIndicator_.show()
	sight_indicators[key] = SightIndicator_


func _on_player_appended(player_id, team_id_):
	var _players = get_tree().get_nodes_in_group("Player")

	player_id = str(player_id)

	for Player_ in _players:
		if Player_.name == player_id and not (Player_.name in player_markers.keys()):
			var Marker

			players.append(Player_)

			if Player_.is_network_master():
				Marker = PlayerMarker.duplicate()
				team_id = team_id_
				add_sight_indicator(Player_.name, SightIndicator.duplicate())
			elif team_id == null:
				continue
			elif team_id_ == team_id:
				Marker = AllyMarker.duplicate()
				add_sight_indicator(Player_.name, SightIndicator.duplicate())
			else:
				Marker = EnemyMarker.duplicate()

			add_marker(
				Player_.name,
				PlayerMarkerContainer,
				Marker,
				player_markers
			)

			break


func _on_player_erased(player_id):
	player_id = str(player_id)

	for Player_ in players:
		if Player_.name == player_id:
			players.erase(Player_)

			break

	if player_id in player_markers:
		player_markers[player_id].queue_free()
		player_markers.erase(player_id)

	if player_id in sight_indicators:
		sight_indicators[player_id].queue_free()
		sight_indicators.erase(player_id)


func update_objective_markers(objectives):
	for id in objective_markers.size():
		if id >= objectives.size():
			return objective_markers[id].hide()

		objective_markers[id].show()
		objective_markers[id].rect_position = (
			objectives[id].global_position / ZOOM
			- objective_markers[id].rect_size / 2
		)
