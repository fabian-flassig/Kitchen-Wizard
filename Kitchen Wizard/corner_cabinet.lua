--Corner cabinet, both left and right sided door

local function get_l_piece_length(general_data, specific_data)
	local l_piece_length = math.max(specific_data.width2 - specific_data.depth, specific_data.width - specific_data.door_width - specific_data.depth)

	l_piece_length = math.max(l_piece_length, general_data.thickness) -- needs to be at least board thick
	return l_piece_length
end

local function recreate_corner(general_data, specific_data)
	local cur_elements = {}
-------------------
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local carcass_depth = specific_data.depth - door_to_carcass
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local carcass_elements = {}
	local new_elem = nil
	local displacement = specific_data.depth - specific_data.depth2

	local side_length = carcass_depth
	if specific_data.back_style == "back_external" then
		side_length = carcass_depth - general_data.thickness_back
	end
	local side_height = specific_data.height
	if specific_data.bottom_style == "bottom_external" then
		loc_origin[3] = base_height + general_data.thickness
		side_height = specific_data.height - general_data.thickness
	end

	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness

	--the L-piece is symmetrical, therefore the length is determined as the maximum of width2 - depth and width1 - door width
	local l_piece_length = get_l_piece_length(general_data, specific_data) 
	
	--Left side
	loc_origin[2] = 0
	new_elem = pytha.create_block(general_data.thickness, side_length, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, specific_data.width, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_lh")
	table.insert(carcass_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, side_length, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, specific_data.width, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_rh")
	table.insert(carcass_elements, new_elem)
	
	
	--Bottom
	loc_origin[1] = general_data.thickness
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local bottom_style_info = nil
	if specific_data.bottom_style then
		bottom_style_info = bottom_style_list[specific_data.bottom_style]
	end
	local bottom_width = specific_data.width - 2 * general_data.thickness
	local bottom_depth = carcass_depth
	local top_depth = carcass_depth
	if specific_data.bottom_style == "bottom_external" then
		bottom_width = specific_data.width
		loc_origin[1] = 0
	end
	if specific_data.back_style == "back_rebate" then
		bottom_depth = carcass_depth
		top_depth = carcass_depth - general_data.thickness_back 
	elseif specific_data.back_style == "back_external" then
		bottom_depth = carcass_depth - general_data.thickness_back
		top_depth = carcass_depth - general_data.thickness_back 
	elseif specific_data.back_style == "back_internal" then
		if specific_data.bottom_style == "bottom_external" then
			bottom_depth = carcass_depth
		else
			bottom_depth = carcass_depth - groove_dist_back_off
		end
		top_depth = carcass_depth - groove_dist_back_off
	end
	
	new_elem = pytha.create_block(bottom_width, bottom_depth, general_data.thickness, loc_origin)
	set_part_attributes(new_elem, "bottom")
	table.insert(carcass_elements, new_elem)
	
	--Top
	loc_origin[1] = general_data.thickness
	loc_origin[2] = 0
	loc_origin[3] = base_height + specific_data.height
	local top_style_info = nil
	if specific_data.top_style then
		top_style_info = top_style_list[specific_data.top_style]
		top_style_info.geometry_function(general_data, specific_data, specific_data.width, top_depth, loc_origin, coordinate_system, carcass_elements)
	end

	--Blind panel
	loc_origin[2] = 0
	loc_origin[3] = base_height + general_data.thickness
	if specific_data.door_rh == true then
		loc_origin[1] = specific_data.door_width
	else
		loc_origin[1] = general_data.thickness -- specific_data.width - specific_data.door_width
	end
	new_elem = pytha.create_block(specific_data.width - general_data.thickness - specific_data.door_width, general_data.thickness, specific_data.height - 2 * general_data.thickness, loc_origin)
	set_part_attributes(new_elem, "blind_panel")
	table.insert(carcass_elements, new_elem)

	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = specific_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, specific_data.height, loc_origin)
	set_part_attributes(new_elem, "back")
	table.insert(carcass_elements, new_elem)
	
	local corner_width = specific_data.width + specific_data.depth2 + 20
	

	--Front
	local shelf_depth = 60 - general_data.setback_shelves 
	if specific_data.door_rh == true then
		loc_origin[1] = 0
	else
		loc_origin[1] = specific_data.width - specific_data.door_width
	end
	loc_origin[2] = 0
	loc_origin[3] = 0

	recreate_basic_front(general_data, specific_data, base_height, specific_data.height, specific_data.door_width, shelf_depth, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, loc_origin)
	
	--Shelves are treated separately here due to special case for corner:
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local door_height = specific_data.height - drawer_height - general_data.top_gap

	if specific_data.this_type == "single_door_and_drawer" and drawer_height > 0 then
		door_height = door_height - general_data.gap
	end	
	local depth = specific_data.depth - groove_dist_back_off - 60

	loc_origin[1] = general_data.thickness + general_data.shelf_gap
	loc_origin[2] = 60

	for i = 1, specific_data.shelf_count, 1 do
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		local new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness - 2 * general_data.shelf_gap, depth, general_data.thickness, loc_origin)
		set_part_attributes(new_elem, "adjustable_shelf")
		table.insert(carcass_elements, new_elem)
	end


	--Inner rail for door
	if specific_data.door_rh == true then
		loc_origin[1] = specific_data.door_width - general_data.thickness
	else
		loc_origin[1] = specific_data.width - specific_data.door_width
	end
	loc_origin[2] = 0
	loc_origin[3] = base_height + general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, 60, specific_data.height - 2 * general_data.thickness, loc_origin)	--programatically set to 60. That would e.g. fit a Kaesseboehmer LeMans2 Swing corner pullout. 
	set_part_attributes(new_elem, "inner_end")
	table.insert(carcass_elements, new_elem)

	--Inner rail for drawer 

	if specific_data.front_style == "single_door_and_drawer" then 
		local drawer_height = get_drawer_heights(general_data, specific_data)
		if specific_data.door_rh == true then
			loc_origin[1] = specific_data.door_width - general_data.thickness
		else
			loc_origin[1] = specific_data.width - specific_data.door_width
		end
		loc_origin[2] = 60 
		loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - drawer_height - general_data.top_gap - (general_data.thickness + general_data.gap) / 2
		new_elem = pytha.create_block(general_data.thickness, specific_data.depth - groove_dist_back_off - 60, drawer_height + general_data.top_gap + (general_data.thickness + general_data.gap) / 2 - general_data.thickness, loc_origin)	--programatically set to 60. That would e.g. fit a Kaesseboehmer LeMans2 Swing corner pullout. 
		set_part_attributes(new_elem, "inner_end")
		table.insert(carcass_elements, new_elem)
	
	end

	--This section is influenced by "door right"
	
	--Corner angle

	if specific_data.door_rh == false then
		local p_array = {{0, 0, 0}, 
							{general_data.thickness, -general_data.thickness, 0}, 
							{l_piece_length - general_data.gap - general_data.door_carcass_gap, -general_data.thickness, 0}, 
							{l_piece_length - general_data.gap - general_data.door_carcass_gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap)[1]
		set_part_attributes(new_elem, "corner_angle")
		table.insert(carcass_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.width - specific_data.door_width - l_piece_length + general_data.door_carcass_gap
		loc_origin[2] = - general_data.door_carcass_gap
		loc_origin[3] = base_height 
		pytha.move_element(corner_angle, loc_origin)
		p_array = {{0, 0, 0}, 
					{0, -l_piece_length + general_data.gap + general_data.door_carcass_gap, 0},
					{general_data.thickness, -l_piece_length + general_data.gap + general_data.door_carcass_gap, 0}, 
					{general_data.thickness, -general_data.thickness, 0}}
		corner_face = pytha.create_polygon(p_array)
		corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap)[1]
		set_part_attributes(new_elem, "corner_angle")
		table.insert(carcass_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.width - specific_data.door_width  - l_piece_length + general_data.door_carcass_gap
		loc_origin[2] = - general_data.door_carcass_gap
		loc_origin[3] = base_height 
		pytha.move_element(corner_angle, loc_origin)
	else
		local p_array = {{0, 0, 0}, 
						{0, -general_data.thickness, 0}, 
						{l_piece_length - general_data.gap - general_data.thickness - general_data.door_carcass_gap, -general_data.thickness, 0}, 
						{l_piece_length - general_data.gap - general_data.door_carcass_gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap)[1]
		set_part_attributes(new_elem, "corner_angle")
		table.insert(carcass_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.door_width + general_data.gap
		loc_origin[2] = - general_data.door_carcass_gap
		loc_origin[3] = base_height
		pytha.move_element(corner_angle, loc_origin)
		p_array = {{l_piece_length - general_data.gap - general_data.thickness, -general_data.thickness, 0}, 
						{l_piece_length - general_data.gap - general_data.thickness, -l_piece_length + general_data.gap + general_data.door_carcass_gap, 0},
						{l_piece_length - general_data.gap, -l_piece_length + general_data.gap + general_data.door_carcass_gap, 0},
						{l_piece_length - general_data.gap, 0, 0}}
		corner_face = pytha.create_polygon(p_array)
		corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap)[1]
		set_part_attributes(new_elem, "corner_angle")
		table.insert(carcass_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.door_width + general_data.gap - general_data.door_carcass_gap
		loc_origin[2] = - general_data.door_carcass_gap
		loc_origin[3] = base_height
		pytha.move_element(corner_angle, loc_origin)
	end
	if specific_data.door_rh == false then
		loc_origin[1] = specific_data.width - specific_data.door_width - l_piece_length - general_data.thickness
	else
		loc_origin[1] = specific_data.door_width + l_piece_length
	end
	loc_origin[2] = - l_piece_length
	new_elem = pytha.create_block(general_data.thickness, l_piece_length, specific_data.height, loc_origin)
	set_part_attributes(new_elem, "corner_blind")
	table.insert(carcass_elements, new_elem)
	

	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)

	--Kickboard
	loc_origin[2] = general_data.kickboard_setback
	loc_origin[3] = general_data.kickboard_margin
	if specific_data.door_rh == false then
		loc_origin[1] = specific_data.width - specific_data.door_width - l_piece_length - general_data.kickboard_thickness - general_data.kickboard_setback
		specific_data.kickboard_handle_right = pytha.create_block(specific_data.door_width + l_piece_length + general_data.kickboard_thickness + general_data.kickboard_setback, 
																general_data.kickboard_thickness, base_height - general_data.kickboard_margin, loc_origin)
																set_part_attributes(new_elem, "kickboard")
		loc_origin[2] = - l_piece_length
		specific_data.kickboard_handle_left = pytha.create_block(general_data.kickboard_thickness, l_piece_length + general_data.kickboard_setback, 
																base_height - general_data.kickboard_margin, loc_origin)
																set_part_attributes(new_elem, "kickboard")
	else
		loc_origin[1] = 0
		loc_origin[2] = general_data.kickboard_setback
		specific_data.kickboard_handle_left = pytha.create_block(specific_data.door_width + l_piece_length + general_data.kickboard_thickness + general_data.kickboard_setback, 
																general_data.kickboard_thickness, base_height - general_data.kickboard_margin, loc_origin)
																set_part_attributes(new_elem, "kickboard")
		loc_origin[1] = specific_data.door_width + l_piece_length + general_data.kickboard_setback
		loc_origin[2] = - l_piece_length
		specific_data.kickboard_handle_right = pytha.create_block(general_data.kickboard_thickness, l_piece_length + general_data.kickboard_setback, 
																base_height - general_data.kickboard_margin, loc_origin)
																set_part_attributes(new_elem, "kickboard")
	end
	table.insert(cur_elements, specific_data.kickboard_handle_left)
	table.insert(cur_elements, specific_data.kickboard_handle_right)
		

	
	local z = general_data.benchtop_height - general_data.benchtop_thickness
	local poly_array = {}
	if specific_data.door_rh == false then
		poly_array = {{specific_data.width - specific_data.door_width - l_piece_length + general_data.top_over, -l_piece_length, z}, 
						{specific_data.width - specific_data.door_width - l_piece_length + general_data.top_over, - general_data.top_over, z}, 
						{specific_data.width, - general_data.top_over, z}, 
						{specific_data.width, specific_data.depth, z}, 
						{specific_data.width - specific_data.door_width - l_piece_length - specific_data.depth, specific_data.depth, z},
						{specific_data.width - specific_data.door_width - l_piece_length - specific_data.depth, -l_piece_length, z}}
	else
		poly_array = {{0, -general_data.top_over, z}, 
						{specific_data.door_width + l_piece_length - general_data.top_over, -general_data.top_over, z}, 
						{specific_data.door_width + l_piece_length - general_data.top_over, -l_piece_length, z}, 
						{specific_data.door_width + l_piece_length + specific_data.depth, -l_piece_length, z}, 
						{specific_data.door_width + l_piece_length + specific_data.depth, specific_data.depth, z}, 
						{0, specific_data.depth, z}}
	end
	
	
	specific_data.main_group = pytha.create_group(cur_elements)
	
	local benchtop = pytha.create_polygon(poly_array)
	specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness)[1]
	pytha.delete_element(benchtop)
	
	return specific_data.main_group
end

local function placement_corner(general_data, specific_data)
	local l_piece_length = get_l_piece_length(general_data, specific_data) 
	if specific_data.door_rh == false then
		specific_data.right_connection_point = {specific_data.width, specific_data.depth, 0}
		specific_data.left_connection_point = {specific_data.width - specific_data.door_width - l_piece_length - specific_data.depth, -l_piece_length,0}
		specific_data.origin_point = {specific_data.width - specific_data.door_width - l_piece_length - specific_data.depth, specific_data.depth, 0}
		specific_data.right_direction = 0
		specific_data.left_direction = 90
	else
		specific_data.right_connection_point = {specific_data.door_width + l_piece_length + specific_data.depth, -l_piece_length, 0}
		specific_data.left_connection_point = {0, specific_data.depth,0}
		specific_data.origin_point = {specific_data.door_width + l_piece_length + specific_data.depth, specific_data.depth, 0}
		specific_data.right_direction = -90
		specific_data.left_direction = 0
	end
end

local function ui_update_corner(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if soft_update == true then return end
	insert_specific_control(general_data, "door_side", pyloc "Connect to right side")

	
	insert_specific_control(general_data, "width", nil)
	insert_specific_control(general_data, "width2", "Connecting width")
	insert_specific_control(general_data, "height", nil)
	insert_specific_control(general_data, "depth", nil)
	insert_specific_control(general_data, "depth2", nil)

	insert_specific_control(general_data, "shelf_count_0_20", nil)
	insert_specific_control(general_data, "door_width", pyloc "Door width")
	
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.corner = 				
{									
	name = pyloc "Corner cabinet",
	row = 0x1,
	default_data = {width = 1000,  
					width2 = 650,
					shelf_count = 0},
	geometry_function = recreate_corner,
	placement_function = placement_corner, 	
	ui_update_function = ui_update_corner,
	organization_styles = {"single_door",			
							"single_door_and_drawer",	
							},	
	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"top_horizontal",},
}
