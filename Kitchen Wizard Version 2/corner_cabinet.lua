--Corner cabinet, both left and right sided door

local function get_l_piece_length(general_data, specific_data)
	local l_piece_length = math.max(specific_data.width2 - general_data.depth, specific_data.width - specific_data.door_width - general_data.depth)

	l_piece_length = math.max(l_piece_length, general_data.thickness) -- needs to be at least board thick
	return l_piece_length
end

local function recreate_corner(general_data, specific_data)
	local cur_elements = {}
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local door_height = specific_data.height - general_data.top_gap - drawer_height
	if drawer_height > 0 then
		door_height = door_height - general_data.gap
	end
	--the L-piece is symmetrical, therefore the length is determined as the maximum of width2 - depth and width1 - door width
	
	local l_piece_length = get_l_piece_length(general_data, specific_data) 
	
	local loc_origin= {}
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End LH"})
	table.insert(cur_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, general_data.depth, specific_data.height, loc_origin, {name = pyloc "End RH"})
	table.insert(cur_elements, new_elem)
	--Bottom
	loc_origin[1] = general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.depth - groove_dist_back_off, general_data.thickness, loc_origin, {name = pyloc "Bottom"})
	table.insert(cur_elements, new_elem)
	--Front rail
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Front"})
	table.insert(cur_elements, new_elem)
	--Back rail
	loc_origin[2] = general_data.depth - general_data.width_rail - groove_dist_back_off
	new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin, {name = pyloc "CR Back"})
	table.insert(cur_elements, new_elem)
	--Shelves
	for i=1, specific_data.shelf_count, 1 do
		loc_origin[2] = general_data.setback_shelves
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		local shelf_depth = general_data.depth - general_data.setback_shelves - groove_dist_back_off
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, shelf_depth, general_data.thickness, loc_origin, {name = pyloc "Adjustable shelf"})
		table.insert(cur_elements, new_elem)
	end
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - 2 * (general_data.thickness - general_data.groove_depth), general_data.thickness_back, specific_data.height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
	
	
	--This section is influenced by "door right"
	
	--Corner angle

	if specific_data.door_rh == true then
		local p_array = {{0, 0, 0}, 
						{0, -l_piece_length + general_data.gap, 0},
						{general_data.thickness, -l_piece_length + general_data.gap, 0}, 
						{general_data.thickness, -general_data.thickness, 0}, 
						{l_piece_length - general_data.gap, -general_data.thickness, 0}, 
						{l_piece_length - general_data.gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap, {name = pyloc "Corner angle"})[1]
		table.insert(cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.width - specific_data.door_width  - l_piece_length
		loc_origin[2] = 0
		loc_origin[3] = base_height 
		pytha.move_element(corner_angle, loc_origin)
	else
		local p_array = {{0, 0, 0}, 
						{0, -general_data.thickness, 0}, 
						{l_piece_length - general_data.gap - general_data.thickness, -general_data.thickness, 0}, 
						{l_piece_length - general_data.gap - general_data.thickness, -l_piece_length + general_data.gap, 0},
						{l_piece_length - general_data.gap, -l_piece_length + general_data.gap, 0},
						{l_piece_length - general_data.gap, 0, 0}}
		local corner_face = pytha.create_polygon(p_array)
		local corner_angle =  pytha.create_profile(corner_face, specific_data.height - general_data.top_gap, {name = pyloc "Corner angle"})[1]
		table.insert(cur_elements, corner_angle)
		pytha.delete_element(corner_face)
		loc_origin[1] = specific_data.door_width + general_data.gap
		loc_origin[2] = 0
		loc_origin[3] = base_height
		pytha.move_element(corner_angle, loc_origin)
	end
	if specific_data.door_rh == true then
		loc_origin[1] = specific_data.width - specific_data.door_width - l_piece_length - general_data.thickness
	else
		loc_origin[1] = specific_data.door_width + l_piece_length
	end
	loc_origin[2] = - l_piece_length
	new_elem = pytha.create_block(general_data.thickness, l_piece_length, specific_data.height, loc_origin, {name = pyloc "Corner Blind"})
	table.insert(cur_elements, new_elem)
	
	--Kickboard
	loc_origin[2] = general_data.kickboard_setback
	loc_origin[3] = general_data.kickboard_margin
	if specific_data.door_rh == true then
		loc_origin[1] = specific_data.width - specific_data.door_width - l_piece_length - general_data.kickboard_thickness - general_data.kickboard_setback
		specific_data.kickboard_handle_right = pytha.create_block(specific_data.door_width + l_piece_length + general_data.kickboard_thickness + general_data.kickboard_setback, 
																general_data.kickboard_thickness, base_height - general_data.kickboard_margin, loc_origin, {name = pyloc "Kickboard"})
		loc_origin[2] = - l_piece_length
		specific_data.kickboard_handle_left = pytha.create_block(general_data.kickboard_thickness, l_piece_length + general_data.kickboard_setback, 
																base_height - general_data.kickboard_margin, loc_origin, {name = pyloc "Kickboard"})
	else
		loc_origin[1] = 0
		loc_origin[2] = general_data.kickboard_setback
		specific_data.kickboard_handle_left = pytha.create_block(specific_data.door_width + l_piece_length + general_data.kickboard_thickness + general_data.kickboard_setback, 
																general_data.kickboard_thickness, base_height - general_data.kickboard_margin, loc_origin, {name = pyloc "Kickboard"})
		loc_origin[1] = specific_data.door_width + l_piece_length + general_data.kickboard_setback
		loc_origin[2] = - l_piece_length
		specific_data.kickboard_handle_right = pytha.create_block(general_data.kickboard_thickness, l_piece_length + general_data.kickboard_setback, 
																base_height - general_data.kickboard_margin, loc_origin, {name = pyloc "Kickboard"})
	end
	table.insert(cur_elements, specific_data.kickboard_handle_left)
	table.insert(cur_elements, specific_data.kickboard_handle_right)
		
	
	--Door
	if specific_data.door_width - 2 * general_data.gap > 0 then
		if specific_data.door_rh == true then
			loc_origin[1] = specific_data.width - specific_data.door_width + general_data.gap
		else
			loc_origin[1] = general_data.gap
		end
		loc_origin[2] = -general_data.thickness
		loc_origin[3] = base_height
		
		local door_group = create_door(general_data, specific_data, specific_data.door_width - 2 * general_data.gap, door_height, loc_origin, not specific_data.door_rh, coordinate_system)
		table.insert(cur_elements, door_group)
		
		--Drawer
		if drawer_height > 0 then
			loc_origin[3] = base_height + specific_data.height - general_data.top_gap - drawer_height
			new_elem = create_drawer(general_data, specific_data, specific_data.door_width - 2 * general_data.gap, drawer_height, loc_origin, coordinate_system, 'center', 'center')
			table.insert(cur_elements, new_elem)
		end
	end
	
	local z = general_data.benchtop_height - general_data.benchtop_thickness
	local poly_array = {}
	if specific_data.door_rh == true then
		poly_array = {{specific_data.width - specific_data.door_width - l_piece_length + general_data.top_over, -l_piece_length, z}, 
						{specific_data.width - specific_data.door_width - l_piece_length + general_data.top_over, - general_data.top_over, z}, 
						{specific_data.width, - general_data.top_over, z}, 
						{specific_data.width, general_data.depth, z}, 
						{specific_data.width - specific_data.door_width - l_piece_length - general_data.depth, general_data.depth, z},
						{specific_data.width - specific_data.door_width - l_piece_length - general_data.depth, -l_piece_length, z}}
	else
		poly_array = {{0, -general_data.top_over, z}, 
						{specific_data.door_width + l_piece_length - general_data.top_over, -general_data.top_over, z}, 
						{specific_data.door_width + l_piece_length - general_data.top_over, -l_piece_length, z}, 
						{specific_data.door_width + l_piece_length + general_data.depth, -l_piece_length, z}, 
						{specific_data.door_width + l_piece_length + general_data.depth, general_data.depth, z}, 
						{0, general_data.depth, z}}
	end
	
	
	specific_data.main_group = pytha.create_group(cur_elements)
	
	if specific_data.individual_call == nil then
		local benchtop = pytha.create_polygon(poly_array)
		specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
		pytha.delete_element(benchtop)
	end
	
	return specific_data.main_group
end

local function placement_corner(general_data, specific_data)
	local l_piece_length = get_l_piece_length(general_data, specific_data) 
	if specific_data.door_rh == true then
		specific_data.right_connection_point = {specific_data.width, general_data.depth, 0}
		specific_data.left_connection_point = {specific_data.width - specific_data.door_width - l_piece_length - general_data.depth, -l_piece_length,0}
		specific_data.origin_point = {specific_data.width - specific_data.door_width - l_piece_length - general_data.depth, general_data.depth, 0}
		specific_data.right_direction = 0
		specific_data.left_direction = 90
	else
		specific_data.right_connection_point = {specific_data.door_width + l_piece_length + general_data.depth, -l_piece_length, 0}
		specific_data.left_connection_point = {0, general_data.depth,0}
		specific_data.origin_point = {specific_data.door_width + l_piece_length + general_data.depth, general_data.depth, 0}
		specific_data.right_direction = -90
		specific_data.left_direction = 0
	end
end

local function ui_update_corner(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	controls.door_side:show_control()
	if soft_update == true then return end

	controls.label_width:show_control()
	controls.width:show_control()
	controls.label_width2:show_control()
	controls.width2:show_control()
	controls.height_label:show_control()
	controls.height:show_control()
	controls.drawer_height_list_label:show_control()
	controls.drawer_height_list:show_control()
	controls.label6:show_control()
	controls.shelf_count:show_control()
	controls.door_width:show_control()
	controls.label_door_width:show_control()
	
	controls.door_side:set_control_text(pyloc "Door right side")
	controls.label_door_width:set_control_text(pyloc "Door width")
	controls.label_width2:set_control_text(pyloc "Connecting width")		
	controls.drawer_height_list_label:set_control_text(pyloc "Drawer height")	
	
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
					width2 = 650,},
	geometry_function = recreate_corner,
	placement_function = placement_corner, 	
	ui_update_function = ui_update_corner,
	organization_styles = {},
}
