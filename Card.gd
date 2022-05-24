extends NinePatchRect


var card_text=""


# Called when the node enters the scene tree for the first time.
func _ready():
	#get_node("RichTextLabel").text="card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text card_text das ist noch mehr text "
#	print(get_node("RichTextLabel").scroll_active)
#	print(get_node("RichTextLabel").get_total_character_count ( ))
	pass # Replace with function body.

func set_cardtext(text):
	card_text=text
	get_node("RichTextLabel").text=card_text
	
