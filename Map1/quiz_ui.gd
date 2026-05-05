# QuizUI.gd
extends Control

@onready var q_label = $Panel/VBoxContainer/QuestionLabel
@onready var options = [
	$Panel/VBoxContainer/Opt1,
	$Panel/VBoxContainer/Opt2,
	$Panel/VBoxContainer/Opt3,
	$Panel/VBoxContainer/Opt4
]

func display(data):
	q_label.text = data["question"]
	var labels = ["A", "B", "C", "D"] # Tạo mảng chữ cái
	for i in range(4):
		# Thay str(i + 1) bằng chữ cái tương ứng trong mảng labels
		options[i].text = labels[i] + ". " + data["choices"][i]
	show()
