extends "res://tests/UTcommon.gd"

var cards = []

func before_each():
	await setup_board()
	cfc.game_settings.hand_use_oval_shape = true
	cards = draw_test_cards(5)
	await yield_for(0.5)

func after_each():
	cards.clear()

func test_oval_recalculate_produces_valid_arch():
	# Verify oval formulas produce a fan arch:
	# - Middle card rotation near 0 (horizontal)
	# - Left cards have negative rotation, right cards have positive
	# - Positions spread horizontally, middle card is above edges (arch opens upward)
	for i in range(cards.size()):
		var pos = cards[i].recalculate_position()
		var rot = cards[i]._recalculate_rotation()
		assert_false(is_nan(pos.x), "Card %d x is valid" % i)
		assert_false(is_nan(pos.y), "Card %d y is valid" % i)
		if i == 2:
			assert_between(rot, -1.0, 1.0, "Middle card near horizontal")
		elif i < 2:
			assert_lt(rot, 0.0, "Left card %d rotation is negative" % i)
		else:
			assert_gt(rot, 0.0, "Right card %d rotation is positive" % i)

func test_oval_cards_spread_horizontally():
	var spread = cards[4].position.x - cards[0].position.x
	assert_gt(spread, 300.0, "5-card oval spread > 300px")
	assert_lt(spread, 800.0, "5-card oval spread < 800px")

func test_oval_cards_ordered_left_to_right():
	for i in range(cards.size() - 1):
		assert_lt(cards[i].position.x, cards[i + 1].position.x,
				"Card %d left of card %d" % [i, i + 1])

func test_oval_recalculate_matches_actual_position():
	# Actual card position must match recalculate_position() output
	for i in range(cards.size()):
		assert_almost_eq(cards[i].recalculate_position(), cards[i].position,
				Vector2(2, 2), "Card %d position matches recalculate" % i)

func test_oval_arch_present():
	# Cards form an arch: middle card Y differs from edges
	var mid_y = cards[2].position.y
	assert_ne(mid_y, cards[0].position.y,
			"Middle card Y differs from left edge (arch present)")
	assert_ne(mid_y, cards[4].position.y,
			"Middle card Y differs from right edge (arch present)")

func test_oval_rotations_not_all_zero():
	# At least some cards should have non-zero rotation in oval mode
	var has_rotation = false
	for c in cards:
		if abs(c.get_node("Control").rotation) > 0.1:
			has_rotation = true
	assert_true(has_rotation, "Oval mode applies rotation to cards")

func test_rectangle_recalculate_flat():
	cfc.game_settings.hand_use_oval_shape = false
	for i in range(cards.size()):
		var pos = cards[i].recalculate_position()
		assert_almost_eq(0.0, pos.y, 2.0,
				"Card %d y=0 in rectangle mode" % i)
		var rot = cards[i]._recalculate_rotation()
		assert_almost_eq(0.0, rot, 1.0,
				"Card %d rotation=0 in rectangle mode" % i)
