extends Node


# warning-ignore:unused_signal
signal player_disconnected(player_id)


# warning-ignore:unused_signal
signal increase_score(team_id, score)
# warning-ignore:unused_signal
signal round_setup(winning_score)


# CTF singal
# warning-ignore:unused_signal
signal CTF_capture_flag(team_id)
# warning-ignore:unused_signal
signal CTF_return_flag(team_id)
