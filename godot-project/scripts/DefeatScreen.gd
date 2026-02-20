extends Control

@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/MenuButton
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready() -> void:
    message_label.text = "Adventure Paused"
    score_label.text = "Current Score: " + str(Global.score)
    
    restart_button.pressed.connect(_on_restart_pressed)
    menu_button.pressed.connect(_on_menu_pressed)
    close_button.pressed.connect(_on_close_pressed)

func _on_restart_pressed() -> void:
    Global.reset_game()
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed() -> void:
    Global.reset_game()
    get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed() -> void:
    get_tree().quit()