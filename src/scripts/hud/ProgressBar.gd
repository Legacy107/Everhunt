extends TextureProgress


export var team_id = 0

onready var UpdateTween = $UpdateTween


func _ready():
# warning-ignore:return_value_discarded
	GameEvent.connect("round_setup", self, "_on_round_setup")
# warning-ignore:return_value_discarded
	GameEvent.connect("increase_score", self, "_on_increase_score")


func _on_round_setup(winning_score):
	max_value = winning_score
	value = 0


func _on_increase_score(_team_id, score):
	if _team_id == team_id:
		print('a')
		UpdateTween.interpolate_property(
			self,
			"value",
			value,
			value + score,
			0.4,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)
		UpdateTween.start()
