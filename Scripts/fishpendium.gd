extends AnimatedSprite2D
var open = false
var bonus = "open]"
var page = 1
var page3fix = false
var is_changing_page = false
var inshop = false
var toggle = false

signal opened
signal closed
signal cursormode

func _process(delta):
	if %Fishpendium.is_playing(): return
	if inshop:
		%Cursor.visible = true
		emit_signal("cursormode")
		return
	else:
		%Cursor.visible = false
	_roll()
	_unroll()
	if open:
		if Input.is_action_just_pressed("menu_right") and page <= 2 and not is_changing_page:
			is_changing_page = true
			page += 1
			if page == 3:
				page3fix = true
			arrowupdate()
			await _write_fishpendium()
			await get_tree().create_timer(0.5).timeout
			is_changing_page = false
		if Input.is_action_just_pressed("menu_left") and page >= 2 and not is_changing_page:
			page3fix = false
			is_changing_page = true
			page -= 1
			arrowupdate()
			await _write_fishpendium()
			await get_tree().create_timer(0.5).timeout
			is_changing_page = false


func _unroll():
	if (Input.is_action_just_pressed("info") and open == false) and not is_changing_page:
		is_changing_page = true
		%Fishpendium.play("shutter")
		open = true
		await _erase_header()
		bonus = "close]"
		_type_text($Header, bonus, 0.02)
		await get_tree().create_timer(0.2).timeout
		emit_signal("opened")
		$ListLeft.visible = true
		$ListRight.visible = true
		$UI.visible = true
		$Note.visible = true
		arrowupdate()
		_write_fishpendium()
		await get_tree().create_timer(0.5).timeout
		is_changing_page = false

func _roll():
	if ((Input.is_action_just_pressed("info") and open == true) or toggle) and not is_changing_page:
		is_changing_page = true
		toggle = false
		%Fishpendium.play_backwards("shutter")
		open = false
		page3fix = false
		$UI.visible = false
		$Note.visible = false
		await _erase_header()
		bonus = "open]"
		_type_text($Header, bonus, 0.02)
		$ListLeft.visible = false
		$ListRight.visible = false
		await get_tree().create_timer(0.2).timeout
		emit_signal("closed")
		page = 1
		is_changing_page = false

func _type_text(zone, text, speed):
	for i in text.length():
		zone.text += text[i]
		await get_tree().create_timer(speed).timeout

func _erase_header():
	while $Header.text.length() > 19:
		$Header.text = $Header.text.left($Header.text.length() - 1)
		await get_tree().create_timer(0.03).timeout

func _write_fishpendium():
	var page_fish = []
	if page == 1:
		page_fish = ["Fish", "Sea Bass", "Clownfish", "Cod", "Pinko",
		 "Rainbow Trout", "Bread", "Halibut", "Skrimp", "Blahaj"]
	elif page == 2:
		page_fish = ["Crab", "John Dory", "Pufferfish", "Cool Fish", "Bryson",
		 "Creature", "Angler Fish", "Rat Boy Genius", "Blooper", "This Guy"]
	else:
		page_fish = ["Fisherman", "Big Fish Boss", "Unfathomable Horror", "Dev Fish", "Invisifish",
		 "Old Boot", "The Looker"]
	populate_lists(page_fish)
	

func populate_lists(known_fish):
	$ListLeft.text = ""
	$ListRight.text = ""
	var side = false
	if page3fix == false:
		_type_list($ListLeft, known_fish.slice(0, min(5, known_fish.size())), side)
		side = true
		_type_list($ListRight, known_fish.slice(5, min(10, known_fish.size())), side)
	else:
		_type_list($ListLeft, known_fish.slice(0, min(4, known_fish.size())), side)
		side = true
		_type_list($ListRight, known_fish.slice(4, min(8, known_fish.size())), side)

func _type_list(list_node, items, side):
	list_node.text = ""
	var j = 0
	if side == false:
		if page == 2:
			j += 10
		elif page == 3:
			j += 20
		for i in range(items.size()):
			j += 1
			await _type_text(list_node, str(j) + ". " + items[i] + "\n\n", 0.001)
	if side == true:
		j += 5
		if page == 2:
			j += 10
		elif page == 3:
			j += 19
		for i in range(items.size()):
			j += 1
			await _type_text(list_node, str(j) + ". " + items[i] + "\n\n", 0.001)
		
func arrowupdate():
		$UI.text = "<---       " + str(page) + "/3       --->"

func _on_ui_boxes_in_shop():
	inshop = true
	if open == true:
		toggle = true
		_roll()
		await get_tree().create_timer(0.5).timeout
		open = false
	fptogoff()
	

func fptogoff():
	%Fishpendium.play("becomepoint")
	%Header.visible = false
	await get_tree().create_timer(0.2).timeout
	%Fishpendium.visible = false

func _on_ui_boxes_out_shop():
	inshop = false
	toggle = false
	%Cursor.visible = false
	%Fishpendium.visible = true
	%Fishpendium.play_backwards("becomepoint")
	await get_tree().create_timer(0.3).timeout
	%Header.visible = true
	page = 1
	await _unroll()
	await get_tree().create_timer(0.2).timeout
	%Activity.text = " idle"
