extends Control

@onready var money_label: Label = $MoneyLabel
@onready var score_label: Label = $Score
@onready var title: Label = $Label

@onready var review_lables : Array[Label] = [
    $VBoxContainer/Review1,
    $VBoxContainer/Review2,
    $VBoxContainer/Review3
]

func show_report(money_earned, disliked_qualitites,liked_qualities,score,title_text):
    visible = true
    get_tree().get_first_node_in_group("MouseCaptureGroup").release_mouse()
    title.text = title_text
    var messages : Array[String] = []
    
    for i in disliked_qualitites:
        if messages.size() >= 3:
            break
        var prewritten_message = ReviewMessages.disliked_messages.pick_random()
        var adjusted_message = add_quality_to_message(prewritten_message,i)
        messages.append(adjusted_message)
        
    for i in liked_qualities:
        if messages.size() >= 3:
            break
        var prewritten_message = ReviewMessages.liked_messages.pick_random()
        var adjusted_message = add_quality_to_message(prewritten_message,i)
        messages.append(adjusted_message)
    
    for label in review_lables:
        label.text = ""
    
    for i in messages.size():
        review_lables[i].text = messages[i]
    
    money_label.text = "$" + str(money_earned)
    var score_text = xo_rating_text(score)
    score_label.text = score_text
    pass
    
func hide_report():
    visible = false
    get_tree().get_first_node_in_group("MouseCaptureGroup").capture_mouse()


func add_quality_to_message(message : String, quality : QualityEnum.Property) -> String:
    var new_message = message.replace("[QUALITY]",QualityEnum.Property.keys()[quality])
    return new_message
    
func xo_rating_text(score: int) -> String:
    score = clamp(score, 0, 5)

    var parts: Array[String] = []

    for i in range(5):
        parts.append("XO" if i < score else "--")

    return " ".join(parts)
