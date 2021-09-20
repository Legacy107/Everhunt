class_name Gamemode

extends Node


var current_scores = [0, 0]
var winning_score = 0


func _init(_winning_score = 0).():
	winning_score = _winning_score


func setup():
# warning-ignore:return_value_discarded
	GameEvent.connect("increase_score", self, "_on_GameEvent_increase_score")
# warning-ignore:return_value_discarded
	$Timer.connect("timeout", self, "_on_Timer_timeout")


func _on_GameEvent_increase_score(team_id, score):
	current_scores[team_id] += score
	check_win_condition()


func _on_Timer_timeout():
	winning_score = current_scores.max()
	check_win_condition()


func check_win_condition():
	if current_scores[0] == current_scores[1]:
		if current_scores[0] >= winning_score:
			handle_draw()
		return

	for team_id in current_scores.size():
		if current_scores[team_id] >= winning_score:
			handle_win(team_id)


func handle_win(team_id):
	print("Team %s wins the round" % team_id)
	queue_free()


func handle_draw():
	print("Draw round")
	queue_free()
