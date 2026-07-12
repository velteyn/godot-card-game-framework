extends "res://tests/UTcommon.gd"

var cards := []

func before_all():
	cfc.game_settings.fancy_movement = false

func after_all():
	cfc.game_settings.fancy_movement = true

func before_each():
	await setup_board()

func test_get_card_methods():
	var pile : Pile = cfc.NMAP.deck
	assert_eq(pile.get_child(4),pile.get_bottom_card(),
			'get_top_card() returns top card')
	assert_eq(pile.get_child(pile.get_child_count() - 1),pile.get_top_card(),
			'get_bottom_card returns() bottom card')
	assert_eq(pile.get_bottom_card(),pile.get_all_cards()[0],
			"get_all_cards() works without anything in viewpile")

func test_facedown_cards():
	var pile : Pile = cfc.NMAP.deck
	# We need a longer yield because we're also waiting for the richtextlabels
	# To populate, during which time, cards are left face-up
	await yield_for(0.3)
	assert_eq(pile.get_top_card().is_faceup, pile.faceup_cards,\
			"Card has to be facedown when moved into pile")

func test_faceup_cards():
	var pile : Pile = cfc.NMAP.deck
	pile.faceup_cards = true
	await yield_for(0.1)
	assert_eq(pile.get_top_card().is_faceup, pile.faceup_cards,\
			"Card has to be faceup when moved into pile")


func test_hover_shows_manipulation_buttons_when_cards_overlap():
	var pile : Pile = cfc.NMAP.deck
	var board := cfc.NMAP.board
	await yield_for(0.1)
	var collision_shape : CollisionShape2D = pile.get_node("CollisionShape2D")
	assert_eq(pile.control.get_index(), pile.get_child_count() - 1,
			"Pile control should be moved to the front after raw add_child card deployment")
	assert_almost_eq(collision_shape.position, pile.control.position + pile.control.size / 2, Vector2(1,1),
			"Pile collision shape should follow the deployed stack")
	assert_almost_eq(pile.get_top_card().position, pile.get_stack_position(pile.get_top_card()), Vector2(1,1),
			"Top card should be reorganized into stack position after startup deployment")
	assert_false(pile.get_top_card().input_pickable,
			"Pile cards should not absorb pointer input")
	pile.hide_buttons()
	board._UT_mouse_position = pile.to_global(pile.get_top_card().position + pile.get_top_card().card_size / 2)
	pile._process(0.0)
	assert_true(pile.are_buttons_visible(),
			"Pile hover should show buttons even when a card also overlaps the pointer")
	board._UT_mouse_position = Vector2(-1000, -1000)
	pile._process(0.0)
	assert_false(pile.are_buttons_visible(),
			"Pile buttons should hide again after the pointer leaves")

func test_popup_view():
	var pile : Pile = cfc.NMAP.deck
	await yield_for(0.1)
	var card_order := pile.get_all_cards()
	var ordered_cards := pile.get_all_cards()
	ordered_cards.sort_custom(Callable(CFUtils, "sort_scriptables_by_name"))
	ordered_cards.reverse()
	var ordered_card_names := []
	for o in ordered_cards:
		ordered_card_names.append(o.canonical_name)
	pile.populate_popup()
	await yield_for(0.7)
	assert_eq(pile.get_all_cards(), card_order,\
			"Retrieved card order remains when viewed in pile")
	assert_eq(pile.get_all_cards(), retieve_popup_order(pile),\
			"Viewed card order from topleft, to botright")
	pile.pile_popup.hide()
	await yield_for(0.7)
	pile.populate_popup(true)
	await yield_for(0.7)
	assert_ne(retieve_popup_order(pile), card_order,\
			"Card order changed when viewed in order")
	var popup_card_names := []
	for c in retieve_popup_order(pile):
		popup_card_names.append(c.canonical_name)
	assert_eq(popup_card_names, ordered_card_names,\
			"Cards are ordered in view popup")
	pile.pile_popup.hide()
	await yield_for(0.7)
	assert_eq(pile.get_all_cards(), card_order,\
			"Pile order resumed after being viewed ordered")


func retieve_popup_order(pile: Pile) -> Array:
	var popup_cards := []
	for obj in pile._popup_grid.get_children():
		if obj.get_child_count():
			# We have to insert instead of append because in a popup
			# window, we display the menu inverted, as in godot node hierarchy
			# the "top card" is the last node and therefore would be placed
			# on the last position in the grid.
			# But the natural way to read a card list popup, is to expect the
			# top card to be on the top right
#			popup_cards.append(obj.get_child(0))
			popup_cards.insert(0, obj.get_child(0))
	return(popup_cards)

func test_set_pile_name():
	var pile : Pile = cfc.NMAP.discard
	pile.pile_name = "GUT Test"
	assert_eq(pile.pile_name, pile.pile_name_label.text,
			"Label is renamed whe pile_name changes")


func test_shuffle_signal():
	var pile : Pile = cfc.NMAP.deck
	watch_signals(pile)
	pile.shuffle_cards(false)
	assert_signal_emitted(pile,"shuffle_completed",
			"shuffle_completed emited")
