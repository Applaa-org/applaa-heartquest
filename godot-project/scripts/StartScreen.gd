extends Control

@onready var player_name_input: LineEdit = $VBoxContainer/PlayerNameInput
@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready() -> void:
    # STEP 1: Initialize high score display to 0 immediately
    high_score_label.text = "High Score: 0"
    high_score_label.visible = true
    
    # Connect buttons
    start_button.pressed.connect(_on_start_pressed)
    close_button.pressed.connect(_on_close_pressed)
    
    # STEP 2: Load game data from localStorage
    Global.load_data_from_storage()
    
    # Set up listener for data response (via JavaScript callback simulation)
    # In Godot 4 web export, we need a way to catch the message.
    # We will set a JavaScript callback that updates a global variable Godot can poll,
    # or use the JavaScriptBridge to set up a listener.
    _setup_js_listener()

func _setup_js_listener() -> void:
    if OS.has_feature("web"):
        # Set up a global JavaScript function to handle the message
        var js_setup = """
        window.addEventListener('message', function(event) {
            if (event.data.type === 'applaa-game-data-loaded') {
                window.godotGameData = JSON.stringify(event.data.data);
            }
        });
        """
        JavaScriptBridge.eval(js_setup)
        
        # Poll for data (simple approach for this context)
        _check_for_loaded_data()

func _check_for_loaded_data() -> void:
    if OS.has_feature("web"):
        var data_str = JavaScriptBridge.eval("window.godotGameData || null")
        if data_str != null:
            var json = JSON.new()
            var parse_err = json.parse(data_str)
            if parse_err == OK:
                var data = json.data
                Global.update_high_score_from_data(data)
                # STEP 3: Update display
                high_score_label.text = "High Score: " + str(Global.high_score)
                if Global.player_name != "":
                    player_name_input.text = Global.player_name

func _on_start_pressed() -> void:
    var name = player_name_input.text.strip_edges()
    if name == "":
        name = "Friend"
    Global.player_name = name
    Global.reset_game()
    get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed() -> void:
    get_tree().quit()