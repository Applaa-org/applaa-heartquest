extends Node

signal score_changed(new_score: int)

var player_name: String = ""
var score: int = 0
var high_score: int = 0
var current_level_index: int = 0
var game_id: String = "heartquest_feelings"

# Story data loaded from game_spec.json logic
var story_data: Array = []

func _ready() -> void:
    load_story_data()

func load_story_data() -> void:
    # In a real scenario, this would parse game_spec.json
    # For now, we define it here to ensure it works
    story_data = [
        {
            "title": "The Lonely Playground",
            "scenario": "Alex is standing alone while other kids play tag. No one invited Alex.",
            "choices": [
                {"text": "Invite Alex to play", "correct": true, "feedback": "Great job! Including others makes everyone happy."},
                {"text": "Ignore Alex", "correct": false, "feedback": "Alex might feel sad. It's better to include others."},
                {"text": "Laugh at Alex", "correct": false, "feedback": "That hurts feelings. Kindness is always better."}
            ],
            "feeling_question": "How do you think Alex feels?",
            "feelings": [
                {"text": "Happy", "correct": false},
                {"text": "Lonely", "correct": true},
                {"text": "Angry", "correct": false}
            ]
        },
        {
            "title": "The Broken Toy",
            "scenario": "Sam drops his favorite toy car and it breaks. He starts to cry.",
            "choices": [
                {"text": "Help Sam fix it", "correct": true, "feedback": "Helping friends when they are sad is very kind."},
                {"text": "Say 'It's just a toy'", "correct": false, "feedback": "Toys can be special. It's okay to be sad when they break."},
                {"text": "Walk away", "correct": false, "feedback": "Sam needs a friend right now."}
            ],
            "feeling_question": "How do you think Sam feels?",
            "feelings": [
                {"text": "Excited", "correct": false},
                {"text": "Sad", "correct": true},
                {"text": "Silly", "correct": false}
            ]
        },
        {
            "title": "The Lunch Table",
            "scenario": "Taylor has no one to sit with at lunch. The table is full.",
            "choices": [
                {"text": "Scoot over and make room", "correct": true, "feedback": "Making space for friends is a wonderful way to show you care."},
                {"text": "Tell Taylor to go away", "correct": false, "feedback": "That's not kind. Everyone needs a place to sit."},
                {"text": "Pretend not to see Taylor", "correct": false, "feedback": "Ignoring someone can make them feel invisible."}
            ],
            "feeling_question": "How do you think Taylor feels?",
            "feelings": [
                {"text": "Invisible", "correct": true},
                {"text": "Proud", "correct": false},
                {"text": "Sleepy", "correct": false}
            ]
        }
    ]

func add_score(points: int) -> void:
    score += points
    score_changed.emit(score)

func reset_game() -> void:
    score = 0
    current_level_index = 0
    score_changed.emit(0)

func save_score_to_storage() -> void:
    if OS.has_feature("web"):
        var js_code = """
        window.parent.postMessage({
            type: 'applaa-game-save-score',
            gameId: '%s',
            playerName: '%s',
            score: %d
        }, '*');
        """ % [game_id, player_name, score]
        JavaScriptBridge.eval(js_code)

func load_data_from_storage() -> void:
    if OS.has_feature("web"):
        var js_code = """
        window.parent.postMessage({
            type: 'applaa-game-load-data',
            gameId: '%s'
        }, '*');
        """ % game_id
        JavaScriptBridge.eval(js_code)

func update_high_score_from_data(data: Dictionary) -> void:
    if data.has("highScore"):
        high_score = data.highScore
    if data.has("lastPlayerName"):
        player_name = data.lastPlayerName