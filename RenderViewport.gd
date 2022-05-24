extends Viewport

signal done

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func new_child(child):
	$GridContainer.add_child(child)

func save_viewpoert(filename):
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_texture().get_data().save_png(filename)
	print("Save done: "+filename + " Good Bye")
	emit_signal("done")
	get_parent().remove_child(self)
	queue_free()
	pass
