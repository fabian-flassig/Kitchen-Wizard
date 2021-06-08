--Diagonal corner cabinet with a variable number of shelves

local back_board_width = 160

local function get_max_diag_door_length(general_data, specific_data)
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap
	local p1 = {general_data.gap, - door_to_carcass}
	local p2 = {specific_data.width - specific_data.depth2 - door_to_carcass, specific_data.depth - specific_data.width2 - door_to_carcass + general_data.gap}
	local door_length = PYTHAGORAS(p2[1] - p1[1], p2[2] - p1[2])
	return door_length
end
local function get_carcass_opening_length(general_data, specific_data)
	local p1 = {general_data.thickness, 0}
	local p2 = {specific_data.width - specific_data.depth2, specific_data.depth - specific_data.width2 + general_data.thickness}
	local door_length = PYTHAGORAS(p2[1] - p1[1], p2[2] - p1[2])
	return door_length
end


local function get_backboard_left_point(general_data, specific_data, slope)
	local slope_angle = ATAN(slope)
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local dx = back_board_width * COS(slope_angle)
	local dy = back_board_width * SIN(slope_angle)
	return {specific_data.width - groove_dist_back_off - dx, specific_data.depth - groove_dist_back_off, 0}
end
local function get_backboard_right_point(general_data, specific_data, slope)
	local slope_angle = ATAN(slope)
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local dx = back_board_width * COS(slope_angle)
	local dy = back_board_width * SIN(slope_angle)
	return {specific_data.width - groove_dist_back_off, specific_data.depth - groove_dist_back_off - dy, 0}
end

function recreate_diagonal_base(general_data, specific_data, base_height, height, width1, width2, carcass_depth1, carcass_depth2, carcass_elements)
	local new_elem = nil
	
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local side_length1 = carcass_depth1
	local side_length2 = carcass_depth2
	local loc_origin = {0, 0, base_height}
	if specific_data.back_style == "back_external" then
		side_length1 = carcass_depth1 - general_data.thickness_back
		side_length2 = carcass_depth2 - general_data.thickness_back
	end
	local side_height = height
	if specific_data.bottom_style == "bottom_external" then
		loc_origin[3] = base_height + general_data.thickness
		side_height = height - general_data.thickness
	end

	local slope = (width2 - carcass_depth1 - general_data.thickness)/(width1 - carcass_depth2 - general_data.thickness)
	local slope_angle = ATAN(slope)
			
	--Left side
	loc_origin[2] = door_to_carcass
	new_elem = pytha.create_block(general_data.thickness, side_length1, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, width1, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_lh")
	table.insert(carcass_elements, new_elem)
	--Right side
	loc_origin[1] = width1 - carcass_depth2 + door_to_carcass
	loc_origin[2] = door_to_carcass + carcass_depth1 - width2 
	new_elem = pytha.create_block(side_length2, general_data.thickness, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, width1, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_rh")
	table.insert(carcass_elements, new_elem)
	
	--Diagonal Back board
	loc_origin = {0, 0, base_height + general_data.thickness}
	local dx = back_board_width * COS(slope_angle)
	local dy = back_board_width * SIN(slope_angle)
	local p_left = get_backboard_left_point(general_data, specific_data, slope)
	local p_right = get_backboard_right_point(general_data, specific_data, slope)
	poly_array = {p_left, 
					p_right,
					{p_right[1], p_right[2] + PYTHAGORAS(slope, 1) * general_data.thickness, 0}, 
					{p_left[1] + PYTHAGORAS(1 / slope, 1) * general_data.thickness, p_left[2], 0}}
	create_profile_from_poly(poly_array, height - 2 * general_data.thickness, loc_origin, carcass_elements, "back_massive")


	--Bottom
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height

	local bottom_depth1 = carcass_depth1 - groove_dist_back_off
	local bottom_depth2 = carcass_depth2 - groove_dist_back_off
	
	if specific_data.row == 0x2 then
		poly_array = {{general_data.thickness, 0, 0}, 
						{width1 - carcass_depth2, carcass_depth1 - width2 + general_data.thickness, 0}, 
						{width1, carcass_depth1 - width2 + general_data.thickness, 0}, 
						{width1, carcass_depth1, 0}, 
						{general_data.thickness, carcass_depth1, 0}}	
	else
		poly_array = {{general_data.thickness, 0, 0}, 
						{width1 - carcass_depth2, carcass_depth1 - width2 + general_data.thickness, 0}, 
						{width1 - carcass_depth2 + bottom_depth2, carcass_depth1 - width2 + general_data.thickness, 0}, 
						{width1 - carcass_depth2 + bottom_depth2, bottom_depth1, 0}, 
						{general_data.thickness, bottom_depth1, 0}}	
	end				
	create_profile_from_poly(poly_array, general_data.thickness, loc_origin, carcass_elements, "bottom")

	--Top
	--We reuse the fla handle for the top and the shelves
	loc_origin[3] = base_height + height - general_data.thickness
	create_profile_from_poly(poly_array, general_data.thickness, loc_origin, carcass_elements, "top")

	--Back left
	local back_height = height - general_data.thickness + general_data.groove_depth
	local back_max_width = width1 - groove_dist_back_off - dx + general_data.thickness * PYTHAGORAS(1 / slope, 1)
	local back_width = back_max_width - general_data.thickness + general_data.groove_depth
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = door_to_carcass + carcass_depth1 - groove_dist_back_off
	loc_origin[3] = base_height
	if specific_data.row == 0x2 then
		loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
		back_height = height - 2 * general_data.thickness + 2 * general_data.groove_depth
	else
		if specific_data.back_style == "back_rebate" then
			loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
		elseif specific_data.back_style == "back_external" then
			back_height = height
		elseif specific_data.back_style == "back_internal" then
			if specific_data.bottom_style == "bottom_external" then
				loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
			end
		end
	end
	if specific_data.back_style == "back_external" then
		loc_origin[1] = 0 
		back_width = back_max_width
	end
	new_elem = pytha.create_block(back_width, general_data.thickness_back, back_height, loc_origin)
	set_part_attributes(new_elem, "back")
	table.insert(carcass_elements, new_elem)
	--Back right
	back_max_width = width2 - groove_dist_back_off - dy + general_data.thickness * PYTHAGORAS(slope, 1)
	back_width = back_max_width - general_data.thickness + general_data.groove_depth
	loc_origin[1] = width1 - groove_dist_back_off
	loc_origin[2] = carcass_depth1 - width2 + general_data.thickness - general_data.groove_depth
	if specific_data.back_style == "back_external" then
		loc_origin[2] = carcass_depth1 - width2 
		back_width = back_max_width
	end
	new_elem = pytha.create_block(general_data.thickness_back, back_width, back_height, loc_origin)
	set_part_attributes(new_elem, "back")
	table.insert(carcass_elements, new_elem)
end

local function recreate_diagonal(general_data, specific_data)
	local cur_elements = {}
	local carcass_elements = {}
	local base_height, height = get_cabinet_row_height_base_height(general_data, specific_data)
	
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local loc_origin= {}
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local door_height = height - general_data.top_gap
	local door_width = specific_data.door_width


	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	
	local slope = (specific_data.width2 - specific_data.depth - general_data.thickness)/(specific_data.width - specific_data.depth2 - general_data.thickness)
	local slope_angle = ATAN(slope)
	local miter_angle1 = (180 - slope_angle) / 2
	local miter_angle2 = (90 - slope_angle) / 2
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
		
	local door_diag_offset_y1 = general_data.gap * slope - general_data.thickness * (1 - PYTHAGORAS(slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height
	local door_diag_offset_x2 = general_data.gap / slope - general_data.thickness * (1 - PYTHAGORAS(1 / slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height


	recreate_diagonal_base(general_data, specific_data, base_height, height, specific_data.width, specific_data.width2, specific_data.depth, specific_data.depth2, carcass_elements)

	--this point gives a 3mm gap of the door to the side

	local carcass_opening = get_carcass_opening_length(general_data, specific_data)
	local piece_length = (carcass_opening - door_width) / 2
	local orientation_p_left = {piece_length * COS(slope_angle), - piece_length * SIN(slope_angle), 0}		
	local orientation_p_right = {- piece_length * COS(slope_angle), piece_length * SIN(slope_angle), 0}

	local max_door_length = get_max_diag_door_length(general_data, specific_data)
	local door_hinge_rail_thickness = 60 --programatically set to 60
	local front_off = door_hinge_rail_thickness - general_data.thickness
	local door_hinge_length = piece_length + general_data.thickness
	loc_origin[1] = general_data.thickness
	loc_origin[2] = 0
	loc_origin[3] = base_height + general_data.thickness
	
	if max_door_length > 2 * general_data.gap then
		poly_array = {{0, 0, 0}, 
						orientation_p_left, 
						{orientation_p_left[1] + general_data.thickness * SIN(slope_angle), orientation_p_left[2] + general_data.thickness * COS(slope_angle), 0}, 
						{0, general_data.thickness * PYTHAGORAS(slope, 1), 0},}
		create_profile_from_poly(poly_array, height - 2 * general_data.thickness, loc_origin, carcass_elements, "blind_panel")

		---
		poly_array = {{0, front_off * PYTHAGORAS(slope, 1), 0}, 
						{orientation_p_left[1] + front_off * SIN(slope_angle), orientation_p_left[2] + front_off * COS(slope_angle), 0}, 
						{orientation_p_left[1] + door_hinge_rail_thickness * SIN(slope_angle), orientation_p_left[2] + door_hinge_rail_thickness * COS(slope_angle), 0}, 
						{0, door_hinge_rail_thickness * PYTHAGORAS(slope, 1), 0},}
		create_profile_from_poly(poly_array, height - 2 * general_data.thickness, loc_origin, carcass_elements, "blind_panel")
		---
		poly_array = {{orientation_p_left[1], orientation_p_left[2], 0}, 
						{door_hinge_length * COS(slope_angle), - door_hinge_length * SIN(slope_angle), 0}, 
						{door_hinge_length * COS(slope_angle) + door_hinge_rail_thickness * SIN(slope_angle), - door_hinge_length * SIN(slope_angle) + door_hinge_rail_thickness * COS(slope_angle), 0}, 
						{orientation_p_left[1] + door_hinge_rail_thickness * SIN(slope_angle), orientation_p_left[2] + door_hinge_rail_thickness * COS(slope_angle), 0},}
		create_profile_from_poly(poly_array, height - 2 * general_data.thickness, loc_origin, carcass_elements, "inner_end")
		
		local p_out_1 = {- (general_data.door_thickness + general_data.door_carcass_gap) * TAN(90 - miter_angle1), -general_data.door_carcass_gap - general_data.door_thickness, 0}
		local p_in_1 = {- general_data.door_carcass_gap * TAN(90 - miter_angle1), -general_data.door_carcass_gap, 0}
		
		loc_origin[3] = base_height
		poly_array = {{general_data.gap - general_data.thickness, -general_data.door_carcass_gap - general_data.door_thickness, 0}, p_out_1, p_in_1, {general_data.gap - general_data.thickness, -general_data.door_carcass_gap, 0}}
		create_profile_from_poly(poly_array, door_height, loc_origin, carcass_elements, "blind_front")

		local p3 = {orientation_p_left[1] - (general_data.door_carcass_gap + general_data.door_thickness) * SIN(slope_angle) - general_data.gap * COS(slope_angle), 
					orientation_p_left[2] - (general_data.door_carcass_gap + general_data.door_thickness) * COS(slope_angle) + general_data.gap * SIN(slope_angle), 0}
		local p4 = {orientation_p_left[1] - general_data.door_carcass_gap * SIN(slope_angle) - general_data.gap * COS(slope_angle), 
					orientation_p_left[2] - general_data.door_carcass_gap * COS(slope_angle) + general_data.gap * SIN(slope_angle), 0}
		poly_array = {p_out_1, p3, p4, p_in_1}
		create_profile_from_poly(poly_array, door_height, loc_origin, carcass_elements, "blind_front")

		

		loc_origin[1] = specific_data.width - specific_data.depth2
		loc_origin[2] = specific_data.depth - specific_data.width2 + general_data.thickness
		loc_origin[3] = base_height + general_data.thickness
		poly_array = {{0, 0, 0}, 
						{general_data.thickness * PYTHAGORAS(1/slope, 1), 0, 0},
						{orientation_p_right[1] + general_data.thickness * SIN(slope_angle), orientation_p_right[2] + general_data.thickness * COS(slope_angle), 0}, 
						orientation_p_right, }
		create_profile_from_poly(poly_array, height - 2 * general_data.thickness, loc_origin, carcass_elements, "blind_panel")
		---
		poly_array = {{front_off * PYTHAGORAS(1/slope, 1), 0, 0}, 
						{door_hinge_rail_thickness * PYTHAGORAS(1/slope, 1), 0, 0},
						{orientation_p_right[1] + door_hinge_rail_thickness * SIN(slope_angle), orientation_p_right[2] + door_hinge_rail_thickness * COS(slope_angle), 0}, 
						{orientation_p_right[1] + front_off * SIN(slope_angle), orientation_p_right[2] + front_off * COS(slope_angle), 0}, }
		create_profile_from_poly(poly_array, height - 2 * general_data.thickness, loc_origin, carcass_elements, "blind_panel")
		---
		poly_array = {{orientation_p_right[1], orientation_p_right[2], 0}, 
						{orientation_p_right[1] + door_hinge_rail_thickness * SIN(slope_angle), orientation_p_right[2] + door_hinge_rail_thickness * COS(slope_angle), 0},
						{- door_hinge_length * COS(slope_angle) + door_hinge_rail_thickness * SIN(slope_angle), door_hinge_length * SIN(slope_angle) + door_hinge_rail_thickness * COS(slope_angle), 0},
						{- door_hinge_length * COS(slope_angle), door_hinge_length * SIN(slope_angle), 0},}
		create_profile_from_poly(poly_array, height - 2 * general_data.thickness, loc_origin, carcass_elements, "inner_end")

		loc_origin[3] = base_height
		p_out_2 = {-general_data.door_carcass_gap - general_data.door_thickness, - (general_data.door_thickness + general_data.door_carcass_gap) * TAN(miter_angle2), 0}
		p_in_2 = {-general_data.door_carcass_gap, - general_data.door_carcass_gap * TAN(miter_angle2), 0}
		
		poly_array = {{-general_data.door_carcass_gap - general_data.door_thickness, general_data.gap - general_data.thickness, 0}, {-general_data.door_carcass_gap, general_data.gap - general_data.thickness, 0}, p_in_2, p_out_2}
		create_profile_from_poly(poly_array, door_height, loc_origin, carcass_elements, "blind_front")

		p3 = {orientation_p_right[1] - (general_data.door_carcass_gap + general_data.door_thickness) * SIN(slope_angle) + general_data.gap * COS(slope_angle), 
				orientation_p_right[2] - (general_data.door_carcass_gap + general_data.door_thickness) * COS(slope_angle) - general_data.gap * SIN(slope_angle), 0}
		p4 = {orientation_p_right[1] - general_data.door_carcass_gap * SIN(slope_angle) + general_data.gap * COS(slope_angle), 
				orientation_p_right[2] - general_data.door_carcass_gap * COS(slope_angle) - general_data.gap * SIN(slope_angle), 0}
		poly_array = {p_out_2, p_in_2, p4, p3}
		create_profile_from_poly(poly_array, door_height, loc_origin, carcass_elements, "blind_front")


		--Front
	local shelf_depth = door_hinge_rail_thickness
		loc_origin[1] = orientation_p_left[1] + general_data.thickness
		loc_origin[2] = orientation_p_left[2]
		loc_origin[3] = 0

		coordinate_system = {{COS(slope_angle), -SIN(slope_angle), 0}, {SIN(slope_angle), COS(slope_angle), 0}, {0,0,1}}
		recreate_basic_front(general_data, specific_data, base_height, height, door_width, shelf_depth, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, loc_origin)

		options = {u_axis = coordinate_system[1], v_axis = coordinate_system[2], w_axis = coordinate_system[3]}
		local token = pytha.push_local_coordinates(loc_origin, options)	
		if specific_data.front_style == "single_door_and_drawer" then 
			local drawer_height = get_drawer_heights(general_data, specific_data)
			loc_origin[1] = 0 
			loc_origin[2] = door_hinge_rail_thickness 
			loc_origin[3] = height - drawer_height - general_data.top_gap - (general_data.thickness + general_data.gap) / 2
			new_elem = pytha.create_block(general_data.thickness, specific_data.depth - door_hinge_rail_thickness, drawer_height + general_data.top_gap + (general_data.thickness + general_data.gap) / 2 - general_data.thickness, loc_origin)	--programatically set to 60. That would e.g. fit a Kaesseboehmer LeMans2 Swing corner pullout. 
			set_part_attributes(new_elem, "inner_end")
			table.insert(carcass_elements, new_elem)
			loc_origin[1] = door_width - general_data.thickness
			new_elem = pytha.create_block(general_data.thickness, specific_data.depth - door_hinge_rail_thickness, drawer_height + general_data.top_gap + (general_data.thickness + general_data.gap) / 2 - general_data.thickness, loc_origin)	--programatically set to 60. That would e.g. fit a Kaesseboehmer LeMans2 Swing corner pullout. 
			set_part_attributes(new_elem, "inner_end")
			table.insert(carcass_elements, new_elem)
		end
		pytha.pop_local_coordinates(token)
	
	end 

	--shelf setback needs pythagoras 
	--Shelves
	
	local p_left = get_backboard_left_point(general_data, specific_data, slope)
	local p_right = get_backboard_right_point(general_data, specific_data, slope)
	loc_origin[1] = 0
	loc_origin[2] = 0
	poly_array = {{general_data.thickness + general_data.shelf_gap, (door_hinge_rail_thickness + general_data.shelf_gap) * PYTHAGORAS(slope, 1) - general_data.shelf_gap * slope, 0},
					{specific_data.width - specific_data.depth2 + (door_hinge_rail_thickness + general_data.shelf_gap) * PYTHAGORAS(1/slope, 1) - general_data.shelf_gap / slope, specific_data.depth - specific_data.width2 + general_data.thickness + general_data.shelf_gap, 0},
					{specific_data.width - groove_dist_back_off, specific_data.depth - specific_data.width2 + general_data.thickness + general_data.shelf_gap, 0},
					{p_right[1], p_right[2] - general_data.shelf_gap * SIN(slope_angle), p_right[3]},
					{p_left[1] - general_data.shelf_gap * COS(slope_angle), p_left[2], p_left[3]},
					{general_data.thickness + general_data.shelf_gap, specific_data.depth - groove_dist_back_off, 0},}
	
	for i=1,specific_data.shelf_count,1 do
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		create_profile_from_poly(poly_array, general_data.thickness, loc_origin, carcass_elements, "adjustable_shelf")

	end


	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)
	
	if specific_data.row ~= 0x2 then 
		--Kickboard
		local front_setback = general_data.thickness + general_data.kickboard_setback
		loc_origin[1] = general_data.gap
		loc_origin[2] = -general_data.thickness
		local p_out_1 = {general_data.gap + front_setback * TAN(90 - miter_angle1), 
						general_data.kickboard_setback, 
						general_data.kickboard_margin}
		local p_out_2 = {specific_data.width - specific_data.depth2 + general_data.kickboard_setback, 
						specific_data.depth - specific_data.width2 + general_data.gap + front_setback * TAN(miter_angle2), 
						general_data.kickboard_margin}
		local p_in_1 = {general_data.gap + (front_setback + general_data.kickboard_thickness) * TAN(90 - miter_angle1), 
						general_data.kickboard_setback + general_data.kickboard_thickness, 
						general_data.kickboard_margin}
		local p_in_2 = {specific_data.width - specific_data.depth2 + general_data.kickboard_setback + general_data.kickboard_thickness, 
						specific_data.depth - specific_data.width2 + general_data.gap + (front_setback + general_data.kickboard_thickness) * TAN(miter_angle2), 
						general_data.kickboard_margin}
		poly_array = {{0, general_data.kickboard_setback, general_data.kickboard_margin}, p_out_1, p_in_1, {0, general_data.kickboard_setback + general_data.kickboard_thickness, general_data.kickboard_margin}}
		fla_handle = pytha.create_polygon(poly_array)
		specific_data.kickboard_handle_left = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin)[1]
		pytha.delete_element(fla_handle)
		table.insert(cur_elements, specific_data.kickboard_handle_left)
		
		
		poly_array = {p_out_1, p_out_2, p_in_2, p_in_1}
		fla_handle = pytha.create_polygon(poly_array)
		new_elem = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin)[1]
		set_part_attributes(new_elem, "kickboard")
		pytha.delete_element(fla_handle)
		table.insert(cur_elements, new_elem)
		table.insert(general_data.kickboards, new_elem)	--already needs to be added here as it wont be treated later again
		
		poly_array = {{specific_data.width - specific_data.depth2 + general_data.kickboard_setback, specific_data.depth - specific_data.width2, general_data.kickboard_margin}, 
						{specific_data.width - specific_data.depth2 + general_data.kickboard_setback + general_data.kickboard_thickness, specific_data.depth - specific_data.width2, general_data.kickboard_margin}, p_in_2 , p_out_2}
		fla_handle = pytha.create_polygon(poly_array)
		specific_data.kickboard_handle_right = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin)[1]
		pytha.delete_element(fla_handle)
		table.insert(cur_elements, specific_data.kickboard_handle_right)
	end
	specific_data.main_group = pytha.create_group(cur_elements)

--Benchtop
	if specific_data.row == 0x1 then 
		local z = general_data.benchtop_height - general_data.benchtop_thickness
		poly_array = {{0, -general_data.top_over,z}, 
							{specific_data.width - specific_data.depth2 - general_data.top_over, specific_data.depth - specific_data.width2, z}, 
							{specific_data.width, specific_data.depth - specific_data.width2, z}, 
							{specific_data.width, specific_data.depth, z}, 
							{0, specific_data.depth, z}}
							
		local benchtop = pytha.create_polygon(poly_array)
		specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness)[1]
		pytha.delete_element(benchtop)
	end
	
	return specific_data.main_group
end

local function placement_diagonal(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, specific_data.depth - specific_data.width2, 0}
	specific_data.left_connection_point = {0,specific_data.depth,0}
	specific_data.origin_point = {specific_data.width, specific_data.depth, 0}
	specific_data.right_direction = -90
	specific_data.left_direction = 0
end

local function ui_update_diagonal(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if soft_update == false then 
		insert_specific_control(general_data, "width", pyloc "Left width")
		insert_specific_control(general_data, "width2", pyloc "Right width")
		insert_specific_control(general_data, "height", nil)
		insert_specific_control(general_data, "drawer_height_list", pyloc "Drawer height")
		insert_specific_control(general_data, "door_width", nil)
		insert_specific_control(general_data, "depth", nil)
		insert_specific_control(general_data, "depth2", nil)
	end

end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.diagonal = 				
{									
	name = pyloc "Diagonal cabinet",
	row = 0x1,
	default_data = {width = 1000, 
					width2 = 1000,
					door_width = 500},
	geometry_function = recreate_diagonal,
	placement_function = placement_diagonal,
	ui_update_function = ui_update_diagonal,
	organization_styles = {"intelli_doors",	
							"intelli_doors_and_drawer",			
							},	

	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
--	bottom_styles = {"bottom_internal"},	--bottom cannot go through for this cabinet construction
--	top_styles = {"top_solid"},				--top is designed to be solid, can be modified to be rail construction...
}
cabinet_typelist.diagonal_high = 				
{									
	name = pyloc "Diagonal high cabinet",
	row = 0x3,
	default_data = {width = 1000, 
					width2 = 1000,
					door_width = 500},
	geometry_function = recreate_diagonal,
	placement_function = placement_diagonal,
	ui_update_function = ui_update_diagonal,
	organization_styles = {"intelli_doors",},	

	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
--	bottom_styles = {"bottom_internal"},	--bottom cannot go through for this cabinet construction
--	top_styles = {"top_solid"},				--top is designed to be solid, can be modified to be rail construction...
}

cabinet_typelist.diagonal_wall = 				
{									
	name = pyloc "Diagonal wall cabinet",
	row = 0x2,
	default_data = function(general_data, specific_data) specific_data.width = 650
														specific_data.width2 = 650
														specific_data.door_width = 400
														specific_data.depth = general_data.depth_wall
														specific_data.depth2 = general_data.depth_wall
					end,
	geometry_function = recreate_diagonal,
	placement_function = placement_diagonal,
	ui_update_function = ui_update_diagonal,
	organization_styles = {"intelli_doors",},	

	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
--	bottom_styles = {"bottom_internal"},	--bottom cannot go through for this cabinet construction
--	top_styles = {"top_solid"},				--top is designed to be solid, can be modified to be rail construction...
}


