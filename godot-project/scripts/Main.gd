extends Control

enum GameState { STORY, CHOICE_FEEDBACK, FEELING_QUESTION, FEELING_FEEDBACK }
var current_state: GameState = GameState.STORY

@onready var background_panel: Panel = $BackgroundPanel
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var scenario_label: Label = $VBoxContainer/ScenarioLabel
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer
@onready var feedback_label: Label = $VBoxContainer/FeedbackLabel
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var feeling_question_label: Label = $VBoxContainer/FeelingQuestionLabel
@onready var feelings_container: HBoxContainer = $VBoxContainer/FeelingsContainer
@onready var score_label: Label = $HUD/ScoreLabel
@onready var high_score_label: Label = $HUD/HighScoreLabel

var current_story: Dictionary = {}
var current_choice_correct: bool = false

func _ready() -> void:
    continue_button.pressed.connect(_on_continue_pressed)
    continue_button.visible = false
    feedback_label.visible = false
    feeling_question_label.visible = false
    feelings_container.visible = false
    
    # Initialize HUD
    score_label.text = "Score: 0"
    high_score_label.text = "Best: " + str(Global.high_score)
    
    load_level()

func load_level() -> void:
    if Global.current_level_index >= Global.story_data.size():
        end_game(true)
        return
    
    current_story = Global.story_data[Global.current_level_index]
    
    # Set visuals
    title_label.text = "Scene " + str(Global.current_level_index + 1) + ": " + current_story.title
    scenario_label.text = current_story.scenario
    
    # Set background color based on scene index for variety
    var colors = [Color("#FFD1DC"), Color("#B0E0E6"), Color("#98FB98")]
    background_panel.modulate = colors[Global.current_level_index % colors.size()]
    
    # Setup choices
    _setup_choices()
    
    # Reset UI state
    current_state = GameState.STORY
    feedback_label.visible = false
    continue_button.visible = false
    feeling_question_label.visible = false
    feelings_container.visible = false

func _setup_choices() -> void:
    # Clear existing buttons
    for child in choices_container.get_children():
        child.queue_free()
    
    await get_tree().process_frame
    
    for choice_data in current_story.choices:
        var btn = Button.new()
        btn.text = choice_data.text
        btn.custom_minimum_size = Vector2(400, 50)
        btn.pressed.connect(_on_choice_pressed.bind(choice_data))
        choices_container.add_child(btn)

func _on_choice_pressed(choice_data: Dictionary) -> void:
    current_choice_correct = choice_data.correct
    
    # Show feedback
    feedback_label.text = choice_data.feedback
    feedback_label.visible = true
    
    # Update score
    if current_choice_correct:
        Global.add_score(50)
        feedback_label.modulate = Color.GREEN
    else:
        feedback_label.modulate = Color.ORANGE
    
    _update_hud()
    
    # Hide choices, show continue
    choices_container.visible = false
    continue_button.visible = true
    current_state = GameState.CHOICE_FEEDBACK

func _on_continue_pressed() -> void:
    if current_state == GameState.CHOICE_FEEDBACK:
        _show_feeling_question()
    elif current_state == GameState.FEELING_FEEDBACK:
        _next_level()

func _show_feeling_question() -> void:
    current_state = GameState.FEELING_QUESTION
    continue_button.visible = false
    feedback_label.visible = false
    
    feeling_question_label.text = current_story.feeling_question
    feeling_question_label.visible = true
    
    # Setup feeling buttons
    for child in feelings_container.get_children():
        child.queue_free()
    
    await get_tree().process_frame
    
    for feel_data in current_story.feelings:
        var btn = Button.new()
        btn.text = feel_data.text
        btn.custom_minimum_size = Vector2(150, 80)
        btn.pressed.connect(_on_feeling_pressed.bind(feel_data))
        feelings_container.add_child(btn)
    
    feelings_container.visible = true

func _on_feeling_pressed(feel_data: Dictionary) -> void:
    if feel_data.correct:
        Global.add_score(50)
        feedback_label.text = "Correct! " + feel_data.text + " is the right feeling."
        feedback_label.modulate = Color.GREEN
    else:
        feedback_label.text = "Not quite. Let's think about it."
        feedback_label.modulate = Color.ORANGE
    
    feedback_label.visible = true
    feelings_container.visible = false
    continue_button.visible = true
    current_state = GameState.FEELING_FEEDBACK
    _update_hud()

func _next_level() -> void:
    Global.current_level_index += 1
    choices_container.visible = true
    load_level()

func _update_hud() -> void:
    score_label.text = "Score: " + str(Global.score)
    if Global.score > Global.high_score:
        Global.high_score = Global.score
    high_score_label.text = "Best: " + str(Global.high_score)

func end_game(victory: bool) -> void:
    Global.save_score_to_storage()
    if victory:
        get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
    else:
        get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")