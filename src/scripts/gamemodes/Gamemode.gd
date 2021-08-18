extends Node2D
class_name Gamemode


var current_score = [0, 0]
var winning_score = 0


func _init(_winning_score = 0).():
	winning_score = _winning_score


func setup():
	get_parent().connect("increase_score", self, "_on_GameHandler_increase_score")
	$Timer.connect("timeout", self, "_on_Timer_timeout")


func _on_GameHandler_increase_score(team_id):
	current_score[team_id] += 1
	check_winning_condition()


func _on_Timer_timeout():
	winning_score = current_score.max()
	check_winning_condition()


func check_winning_condition():
	if current_score[0] == current_score[1]:
		if current_score[0] >= winning_score:
			handle_draw()
		return

	for team_id in current_score.size():
		if current_score[team_id] >= winning_score:
			handle_win(team_id)


func handle_win(team_id):
	print('Team %s win the round' % team_id)
	queue_free()


func handle_draw():
	print('Draw round')
	queue_free()
