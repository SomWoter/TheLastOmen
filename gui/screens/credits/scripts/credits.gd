extends Control

signal ended

onready var parallax_layer1 = $ParallaxBackground/Layer1
onready var parallax_layer2 = $ParallaxBackground/Layer2
onready var parallax_layer3 = $ParallaxBackground/Layer3
onready var parallax_layer4 = $ParallaxBackground/Layer4
## Container of titles and names
onready var scrollingText = get_node("VscrollingText")
## Titles (the text on left side)
onready var titles = get_node("VscrollingText/scrollingText/margin/Titles")
## Names (the text on right side)
onready var names = get_node("VscrollingText/scrollingText/margin2/Names")

onready var titleImg = get_node("titleImg")

## The credits file (formatted like a INI file (more info inside README.md))
export(String, FILE) var creditsFile = "res://example-CREDITS.txt"

var viewSize # The size of the window
## Speed of scrolling
export var speed = 44
var regularSpeed # To keep track of the original speed
var ended = false # True if all the credits have been scrolled off the screen
				  # (don't change this value, to end just use "end" function)

var file
var credits

## Do you want the video to be restarted once finished?
export var loopVideo = true

## Playlist of music to play during credits scroll
export(Array, AudioStream) var musicPlaylist
## Do you want the playlist to be restarted once finished?
export var loopPlaylist = false
var playlistIndex = 0


## The color of the background (covered if there is a video)


## Color of the text on left side
export(Color) var titlesColor = Color.gray
## Color of the text on right side
export(Color) var namesColor = Color.white
## Space between left and right sides
export(int) var margin = 6


## Do you want to enable go faster, go slower, pause and reverse controls with ui_actions?
export var enableControls = true
export var speedUpControl = "ui_up"
export var slowDownControl = "ui_down"
## Do you want to be able to skip all the credits by pressing ui_accept?
export var enableSkip = true
export var skipControl = "ui_accept"

## The next scene to load once the scroll ended
export(PackedScene) var nextScene
## If true and there is no nextScene selected, once the scroll ended the program will quit
export var quitOnEnd = false
## If true and there is no nextScene selected and quitOnEnd is false, once the scroll ended the node will be destroyed
export var destroyOnEnd = false

func _ready():
	$LevelAnimator.play("level_in")
	viewSize = get_viewport().size
	scrollingText.rect_position.y = viewSize.y
	regularSpeed = speed
	
	# Set background video if there is one, otherwise delete the useless node
	
	# Set the margin (the space between left and right panels)
	$VscrollingText/scrollingText/margin.add_constant_override("margin_right", margin/2)
	$VscrollingText/scrollingText/margin2.add_constant_override("margin_left", margin/2)

	# If the playlist has at list one track, play it
	if musicPlaylist.size() > 0 and musicPlaylist[playlistIndex] != null:
		playlist_track(playlistIndex)
	
	# Verify if a credits file has been provided
	if creditsFile == null or creditsFile == "":
		push_error("At least one credits file must be provided.")
		assert(false)
	
	# Verify if credits file exists
	file = File.new()
	if not file.file_exists(creditsFile):
		push_error("Credits file does not exist.")
		assert(false)
	# Well, open the credits file and read it
	file.open(creditsFile, File.READ)
	credits = file.get_as_text()
	file.close()
	
	# Parse the credits file
	var lines = credits.split("\n")
	var line
	for i in lines.size():
		line = lines[i].strip_edges()
		if line == "":
			titles.text += "\n"
			names.text += "\n"
			if i>0 and (lines[i-1].begins_with("[") and lines[i-1].ends_with("]")):
				titles.text += "\n"
				names.text += "\n"
		else:
			if line.begins_with("[") and line.ends_with("]"):
				if i>0 and (lines[i-1].begins_with("[") and lines[i-1].ends_with("]")):
					titles.text+="\n"
					names.text+="\n"
				line.erase(0,1)
				line.erase(line.length()-1,1)
				titles.text += tr(line)
			else:
				names.text += line+"\n"
				titles.text += "\n"

func _process(delta):
	move_parallax()
	if not ended:
		# If the scroll is not yet ended, keep to scroll it
		if scrollingText.rect_position.y+scrollingText.rect_size.y > 0:
			scrollingText.rect_position.y -= speed*delta
			# If there is a title image, scroll it too
		else:
			end()

func move_parallax():
	parallax_layer1.motion_offset.x += 0.1
	parallax_layer3.motion_offset.x += 0.2
	parallax_layer4.motion_offset.x += 0.3
func _input(event):
	if not ended:
		# If there is still text scrolling and controls are enabled,
		# let the gamer speed it up, slow it down, stop it or reverse it
		if enableControls:
			if event.is_action_pressed(slowDownControl):
				speed -= 10 * event.get_action_strength(slowDownControl)
			if event.is_action_pressed(speedUpControl):
				speed += 10 * event.get_action_strength(speedUpControl)
		# If skip is enable, let the gamer skip the credits
		if enableSkip:
			if event.is_action_pressed(skipControl):
				end()
				#speed *= 100

# Use this function to stop all
func end():
	emit_signal("ended") # Emit a signal to make easy for programmers to connect other things to this
	ended = true # And a var, to make things even more easy to connect
	
	# If there is a next scene to load, then load it,
	# otherwise if quitOnEnd is enabled, just quit
	if nextScene != null:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://gui/screens/main_menu/scenes/MainMenu.tscn")
	elif quitOnEnd:
		get_tree().quit()
	elif destroyOnEnd:
		self.queue_free()

func _on_backgroundVideo_finished():
	if loopVideo:
		$backgroundVideo.play()
		
func playlist_track(index):
	if 0 <= index and index < musicPlaylist.size():
		musicPlaylist[index].loop = false
		$musicPlayer.stream = musicPlaylist[index]
		$musicPlayer.play()
		playlistIndex = index

func _on_musicPlayer_finished():
	if playlistIndex+1 < musicPlaylist.size():
		playlist_track(playlistIndex+1)
	elif loopPlaylist:
			playlistIndex = 0
			playlist_track(playlistIndex)
