extends Node2D


onready var file ="res://testcards.txt"
var calls_block="calls\":"
var responses_block="responses\":"
var name_block="name\":\""
var calls =[]
var responses=[]
var deck_name=""
var viewports={}

var card_render=preload("res://Card.tscn")
var render_viewport=preload("res://RenderViewport.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	


# goes through the file and locates all the text blocks
func new_parser(line):
	var calls_end_pos=line.find(calls_block)+calls_block.length()
	var responses_end_pos=line.find(responses_block)+responses_block.length()
	var name_end_pos=line.find(name_block)+name_block.length()
	
	deck_name=get_deck_name(line,name_end_pos)
	var block =get_text_block(line,calls_end_pos)
	split_text_block(block)
	block =get_text_block(line,responses_end_pos)
	responses=split_responses(block)

#finds out what's the name of the deck
func get_deck_name(line,start):
	for c in range(start,line.length()):
		if line[c]=="\"":
			return (line.substr(start,c-(start)))
		

#returns the next text between [[[ and ]]] 
func get_text_block(line,start):
	var klammer=0
	for c in range(start,line.length()):
		if line[c]=="[":
			klammer=klammer+1
			#print("character: "+str(c)+" klammer count: "+str(klammer))
		if line[c]=="]":
			klammer=klammer-1
			#print("character: "+str(c)+" klammer count: "+str(klammer))
			if klammer==0:
				return (line.substr(start,c-(start-1)))

# segments the text block in is own segments
func split_text_block(block):
	var klammer=0
	var temp=""
	for c in range (0,block.length()):
		if block[c]=="[":
			klammer=klammer+1
			continue
		if block[c]=="]":
			klammer=klammer-1
		if klammer==3:
			temp+=block[c]
		if klammer<3 && temp!="":
			#print(temp)
			clean_calls_line(temp)
			temp=""

#sortiert den gelieferten calls abschnitt und macht ihn nutzbar indem alle Zeichen entfernt werden die unnötig sind
func clean_calls_line(line):
	#Text ist immer in ""
	#blöcke sind mit , getrennt
	line=line.replace("{}","\"______\"") #Entfernt die {} Klammer die im Code angebibt das hier ein ____ Begriff eingesetzt wird
	line=line.replace("\\\"","öööö") #Hier wird das mit \" bezeichnete Anführungszeichen in öööö umbenannt damit es nicht mit den im Code verwendeten " durcheinander gibt
	var in_block=false
	var temp=""
	for c in range (0,line.length()): #Entfernt alle Restlichen " aus der Calls Line
		if line[c]=="\"" && !in_block:
			in_block=true
			continue
		if line[c]=="\"" && in_block:
			in_block=false
		if in_block:
			temp+=line[c]
	line=temp
	#line=line.replace("öööö","\"") #Wandelt die temporären öööö wieder in ein anführungszeichen " zurück um.
	calls.append(line)

func split_responses(block):
	block=block.trim_prefix("[\"")
	block=block.trim_suffix("\"]")
	block=block.replace("\\\"","\"") #Hier wird das mit \" bezeichnete Anführungszeichen in " umbenannt
	var splitted=block.split("\",\"")
	return splitted

func _on_request_completed(result, response_code, headers, body):
	#print(body.get_string_from_utf8())
	new_parser(body.get_string_from_utf8())
	yield(render_cards(calls,"calls"),"completed")
	yield(render_cards(responses,"responses"),"completed")

	print("Done!!!")


func _on_Button_pressed():
	if $VBoxContainer/LineEdit.text!="":
		calls =[]
		responses=[]
		$HTTPRequest.request("https://decks.rereadgames.com/api/decks/"+$VBoxContainer/LineEdit.text)
	else:
		OS.alert('Please enter Code like 1ZBD6', 'Nothing entered')

func render_cards(card_list,bezeichnung):
	for c in $Viewport/GridContainer.get_children():
		$Viewport/GridContainer.remove_child(c)
		c.queue_free()
	var counter=0
	var page=1
	for d in card_list:
		var card = card_render.instance()
		card.set_cardtext(d)
		$Viewport/GridContainer.add_child(card)
		counter=counter+1
		if counter==24:
			yield(save_viewpoert("res://"+deck_name+"-"+bezeichnung+str(page)+".png"),"completed")
			page=page+1
			counter=0
			for c in $Viewport/GridContainer.get_children():
				$Viewport/GridContainer.remove_child(c)
				c.queue_free()
	yield(save_viewpoert("res://"+deck_name+"-"+bezeichnung+str(page)+".png"),"completed")

func save_viewpoert(filename):
	var vp = $Viewport
	#vp.render_target_update_mode = Viewport.UPDATE_ONCE
	yield(VisualServer, "frame_post_draw")
	yield(VisualServer, "frame_post_draw")
	vp.get_texture().get_data().save_png(filename)
	#vp.render_target_update_mode =Viewport.UPDATE_DISABLED



