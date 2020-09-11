--Diagonal corner cabinet with a variable number of shelves
function diagonal_cabinet_solo()
	local general_data = _G["general_default_data"]
	local spec_index = initialize_cabinet_values(general_data)
	local loaded_data = pyio.load_values("diagonal_dimensions")
	if loaded_data ~= nil then 
		merge_data(loaded_data, general_data)
	end
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	specific_data.this_type = "diagonal"
	specific_data.individual_call = true
	
	general_data.own_direction = 0
	recreate_diagonal(general_data, general_data.cabinet_list[#general_data.cabinet_list])
	
	pyui.run_modal_dialog(diagonal_dialog, general_data)
	
	pyio.save_values("diagonal_dimensions", general_data)
end

local function diagonal_dialog(dialog, general_data)
	local specific_data = general_data.cabinet_list[#general_data.cabinet_list]
	
	dialog:set_window_title(pyloc "Diagonal Cabinet")
	
	local label_benchtop = dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_height))
	local label_bt_thick = dialog:create_label(1, pyloc "Benchtop thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(general_data.benchtop_thickness))
	local label1 = dialog:create_label(1, pyloc "Left Width")
	local width = dialog:create_text_box(2, pyui.format_length(specific_data.width))
	local label7 = dialog:create_label(1, pyloc "Right Width")
	local width2 = dialog:create_text_box(2, pyui.format_length(specific_data.width2))
	local label2 = dialog:create_label(1, pyloc "Height")
	local height = dialog:create_text_box(2, pyui.format_length(specific_data.height))
	local label3 = dialog:create_label(1, pyloc "Depth")
	local depth = dialog:create_text_box(2, pyui.format_length(general_data.depth))
	local label4 = dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(general_data.thickness))
	local label5 = dialog:create_label(1, pyloc "Drawer height")
	local drawer_height = dialog:create_text_box(2, pyui.format_length(specific_data.drawer_height))
	local label6 = dialog:create_label(1, pyloc "Number of shelves")
	local shelf_count = dialog:create_text_box(2, pyui.format_length(specific_data.shelf_count))
	
	general_data.door_side = dialog:create_check_box({1, 2}, pyloc "Door right side")
	general_data.door_side:set_control_checked(specific_data.door_rh)

	local align1 = dialog:create_align({1,2}) -- So that OK and Cancel will be in the same row
	local ok = dialog:create_ok_button(1)
	local cancel = dialog:create_cancel_button(2)
	dialog:equalize_column_widths({1,2,4})
	
	bt_height:set_on_change_handler(function(text)
		general_data.benchtop_height = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	bt_thick:set_on_change_handler(function(text)
		general_data.benchtop_thickness = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	width:set_on_change_handler(function(text)
		specific_data.width = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	width2:set_on_change_handler(function(text)
		specific_data.width2 = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	height:set_on_change_handler(function(text)
		specific_data.height = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	depth:set_on_change_handler(function(text)
		general_data.depth = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	
	thickness:set_on_change_handler(function(text)
		general_data.thickness = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	drawer_height:set_on_change_handler(function(text)
		specific_data.drawer_height = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	shelf_count:set_on_change_handler(function(text)
		specific_data.shelf_count = math.max(pyui.parse_length(text), 0)
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	general_data.door_side:set_on_click_handler(function(state)
		specific_data.door_rh = state
		recreate_diagonal_solo(general_data, specific_data)
	end)
	
	update_diagonal_ui(general_data, specific_data)
end


local function get_diag_door_length(general_data, specific_data)
	local p2 = {specific_data.width - general_data.depth - general_data.thickness, general_data.depth - specific_data.width2 + general_data.gap, 0}
	local door_length = PYTHAGORAS(p2[1] - general_data.gap, p2[2] + general_data.thickness, 0)
	return door_length
end

local function recreate_diagonal_solo(general_data, specific_data)
	update_diagonal_ui(general_data, specific_data)
	
	if specific_data.main_group ~= nil then
		pytha.delete_element(specific_data.main_group)
	end
	recreate_diagonal(general_data, specific_data)
end

local function update_diagonal_ui(general_data, specific_data)
	if get_diag_door_length(general_data, specific_data) - 2 * general_data.gap > 0 then
		if get_diag_door_length(general_data, specific_data) > specific_data.door_width then
			general_data.door_side:disable_control()
		else
			general_data.door_side:enable_control()
		end
	else 
		general_data.door_side:disable_control()
	end
end

local function recreate_diagonal(general_data, specific_data)
	local cur_elements = {}
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness

	local loc_origin= {}
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local door_height = specific_data.height - general_data.top_gap - specific_data.drawer_height
	if specific_data.drawer_height > 0 then
		door_height = door_height - general_data.gap
	end

	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	
	local slope = (specific_data.width2 - general_data.depth - general_data.thickness - general_data.gap)/(specific_data.width - general_data.depth - general_data.thickness - general_data.gap)
	local slope_angle = ATAN(slope)
	local miter_angle1 = (180 - slope_angle) / 2
	local miter_angle2 = (90 - slope_angle) / 2
	local groove_dist_back_off = general_data.groove_dist + general_data.thickness_back
		
	local door_diag_offset_y1 = general_data.gap * slope - general_data.thickness * (1 - PYTHAGORAS(slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height
	local door_diag_offset_x2 = general_data.gap / slope - general_data.thickness * (1 - PYTHAGORAS(1 / slope, 1))	--distance that door is standing out further than a normal door. We shift by that value to bring all doors to the same height

	--Left side
	local poly_array = {{0, door_diag_offset_y1,0}, 
						{general_data.thickness, door_diag_offset_y1 - general_data.thickness * slope, 0}, 
						{general_data.thickness, general_data.depth, 0}, 
						{0, general_data.depth, 0}}
	local fla_handle = pytha.create_polygon(poly_array)
	local profile = pytha.create_profile(fla_handle, specific_data.height, {name = pyloc "End LH"})[1]
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(cur_elements, profile)
	
	--Right side
	poly_array = {{specific_data.width, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - general_data.depth - general_data.thickness / slope + door_diag_offset_x2, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - general_data.depth + door_diag_offset_x2, general_data.depth - specific_data.width2, 0}, 
					{specific_data.width, general_data.depth - specific_data.width2, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, specific_data.height, {name = pyloc "End RH"})[1]
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(cur_elements, profile)
	
	
	--Bottom
	poly_array = {{general_data.thickness, -general_data.thickness * slope + door_diag_offset_y1, 0}, 
					{specific_data.width - general_data.depth - general_data.thickness / slope + door_diag_offset_x2, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - groove_dist_back_off, 0},
					{general_data.thickness, general_data.depth - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, general_data.thickness, {name = pyloc "Bottom"})[1]
	pytha.move_element(profile, loc_origin)
	table.insert(cur_elements, profile)
	
	--We reuse the fla handle for the top and the shelves
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	profile = pytha.create_profile(fla_handle, general_data.thickness, {name = pyloc "Top"})[1]
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(cur_elements, profile)
	
	--shelf setback needs pythagoras 
	--Shelves
	poly_array = {{general_data.thickness, - general_data.thickness * slope + door_diag_offset_y1 + general_data.setback_shelves * PYTHAGORAS(slope, 1), 0}, 
					{specific_data.width - general_data.depth - general_data.thickness / slope + door_diag_offset_x2 + general_data.setback_shelves * PYTHAGORAS(1 / slope, 1), general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - specific_data.width2 + general_data.thickness, 0}, 
					{specific_data.width - groove_dist_back_off, general_data.depth - groove_dist_back_off, 0},
					{general_data.thickness, general_data.depth - groove_dist_back_off, 0}}
	fla_handle = pytha.create_polygon(poly_array)
	
	for i=1,specific_data.shelf_count,1 do
		loc_origin[3] = base_height + i * (door_height - general_data.thickness) / (specific_data.shelf_count + 1)
		profile = pytha.create_profile(fla_handle, general_data.thickness, {name = pyloc "Adjustable shelf"})[1]
		pytha.move_element(profile, loc_origin)
		table.insert(cur_elements, profile)
	end
	pytha.delete_element(fla_handle)
	--Back
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = general_data.depth - groove_dist_back_off
	loc_origin[3] = base_height
	new_elem = pytha.create_block(specific_data.width - general_data.thickness + general_data.groove_depth - groove_dist_back_off, general_data.thickness_back, specific_data.height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
	loc_origin[1] = specific_data.width - groove_dist_back_off
	loc_origin[2] = general_data.depth - specific_data.width2 +  general_data.thickness - general_data.groove_depth
	loc_origin[3] = base_height 
	new_elem = pytha.create_block(general_data.thickness_back, specific_data.width2 - general_data.thickness + general_data.groove_depth - groove_dist_back_off + general_data.thickness_back, specific_data.height, loc_origin, {name = pyloc "Back"})
	table.insert(cur_elements, new_elem)
	

	--here we need to introduce a rotated coordinate system for the door
	local main_dir = {specific_data.width - general_data.depth - general_data.thickness - general_data.gap, general_data.depth + general_data.thickness + general_data.gap - specific_data.width2, 0}
	local diag_length = PYTHAGORAS(main_dir[1], main_dir[2], main_dir[3])
	main_dir[1] = main_dir[1] / diag_length
	main_dir[2] = main_dir[2] / diag_length
	main_dir[3] = main_dir[3] / diag_length
	
	local third_dir =  {-main_dir[2], main_dir[1], 0}
	
	local diag_coos = {main_dir, third_dir, {0,0,1}}
	--this point gives a 3mm gap of the door to the side
	loc_origin[1] = general_data.gap
	loc_origin[2] = -general_data.thickness
	loc_origin[3] = base_height
	local door_length = get_diag_door_length(general_data, specific_data)
	
	--Door
	if door_length > 0 then
		
		if door_length > specific_data.door_width then	--create two doors
			local door_width = door_length / 2 - general_data.gap
		--left handed door
			local door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, false, diag_coos)
			table.insert(cur_elements, door_group)
		--right handed door
			loc_origin[1] = loc_origin[1] + (door_width + 2 * general_data.gap) * main_dir[1]
			loc_origin[2] = loc_origin[2] + (door_width + 2 * general_data.gap) * main_dir[2]
			door_group = create_door(general_data, specific_data, door_width, door_height, loc_origin, true, diag_coos)
			table.insert(cur_elements, door_group)
		else
		--only one door 
			local door_group = create_door(general_data, specific_data, door_length, door_height, loc_origin, specific_data.door_rh, diag_coos)
			table.insert(cur_elements, door_group)
		end
		
		--Drawer
		local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
		if specific_data.drawer_height > 0 then
			loc_origin[1] = general_data.gap
			loc_origin[2] = -general_data.thickness
			loc_origin[3] = base_height + specific_data.height - general_data.top_gap - specific_data.drawer_height
			new_elem = create_drawer(general_data, specific_data, door_length, specific_data.drawer_height, loc_origin, coordinate_system, 'center', 'center')
			pytha.rotate_element(new_elem, loc_origin, 'z', -slope_angle)--this will also rotate the group vector and therefore gives the correct action
			table.insert(cur_elements, new_elem)
		end
	end
	
	--Kickboard
	local front_setback = general_data.thickness + general_data.kickboard_setback
	loc_origin[1] = general_data.gap
	loc_origin[2] = -general_data.thickness
	local p_out_1 = {general_data.gap + front_setback * TAN(90 - miter_angle1), 
					general_data.kickboard_setback, 
					general_data.kickboard_margin}
	local p_out_2 = {specific_data.width - general_data.depth + general_data.kickboard_setback, 
					general_data.depth - specific_data.width2 + general_data.gap + front_setback * TAN(miter_angle2), 
					general_data.kickboard_margin}
	local p_in_1 = {general_data.gap + (front_setback + general_data.kickboard_thickness) * TAN(90 - miter_angle1), 
					general_data.kickboard_setback + general_data.kickboard_thickness, 
					general_data.kickboard_margin}
	local p_in_2 = {specific_data.width - general_data.depth + general_data.kickboard_setback + general_data.kickboard_thickness, 
					general_data.depth - specific_data.width2 + general_data.gap + (front_setback + general_data.kickboard_thickness) * TAN(miter_angle2), 
					general_data.kickboard_margin}
	poly_array = {{0, general_data.kickboard_setback, general_data.kickboard_margin}, p_out_1, p_in_1, {0, general_data.kickboard_setback + general_data.kickboard_thickness, general_data.kickboard_margin}}
	fla_handle = pytha.create_polygon(poly_array)
	specific_data.kickboard_handle_left = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin, {name = pyloc "Kickboard"})[1]
	pytha.delete_element(fla_handle)
	table.insert(cur_elements, specific_data.kickboard_handle_left)
	
	
	poly_array = {p_out_1, p_out_2, p_in_2, p_in_1}
	fla_handle = pytha.create_polygon(poly_array)
	new_elem = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin, {name = pyloc "Kickboard"})[1]
	pytha.delete_element(fla_handle)
	table.insert(cur_elements, new_elem)
	table.insert(general_data.kickboards, new_elem)	--already needs to be added here as it wont be treated later again
	
	poly_array = {{specific_data.width - general_data.depth + general_data.kickboard_setback, general_data.depth - specific_data.width2, general_data.kickboard_margin}, 
					{specific_data.width - general_data.depth + general_data.kickboard_setback + general_data.kickboard_thickness, general_data.depth - specific_data.width2, general_data.kickboard_margin}, p_in_2 , p_out_2}
	fla_handle = pytha.create_polygon(poly_array)
	specific_data.kickboard_handle_right = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin, {name = pyloc "Kickboard"})[1]
	pytha.delete_element(fla_handle)
	table.insert(cur_elements, specific_data.kickboard_handle_right)
	

	specific_data.main_group = pytha.create_group(cur_elements)
	
	local z = general_data.benchtop_height - general_data.benchtop_thickness
	poly_array = {{0, -general_data.top_over,z}, 
						{specific_data.width - general_data.depth - general_data.top_over, general_data.depth - specific_data.width2, z}, 
						{specific_data.width, general_data.depth - specific_data.width2, z}, 
						{specific_data.width, general_data.depth, z}, 
						{0, general_data.depth, z}}
						
	if specific_data.individual_call == nil then
		local benchtop = pytha.create_polygon(poly_array)
		specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness, {name = pyloc "Benchtop"})[1]
		pytha.delete_element(benchtop)
	end
	
	return specific_data.main_group
end

local function placement_diagonal(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, general_data.depth - specific_data.width2, 0}
	specific_data.left_connection_point = {0,general_data.depth,0}
	specific_data.origin_point = {specific_data.width, general_data.depth, 0}
	specific_data.right_direction = -90
	specific_data.left_direction = 0
end

local function ui_update_diagonal(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if get_diag_door_length(general_data, specific_data) - 2 * general_data.gap > 0 then
		if get_diag_door_length(general_data, specific_data)  > specific_data.door_width then
			controls.door_side:disable_control()
		else
			controls.door_side:enable_control()
		end
	else 
		controls.door_side:enable_control()
	end
	
	if soft_update == true then return end

	controls.label_width:enable_control()
	controls.width:enable_control()
	controls.label_width2:enable_control()
	controls.width2:enable_control()
	controls.height_label:enable_control()
	controls.height:enable_control()
	controls.label5:enable_control()
	controls.drawer_height:enable_control()
	controls.label6:enable_control()
	controls.shelf_count:enable_control()
	controls.door_width:enable_control()
	controls.label_door_width:enable_control()
	
	controls.door_side:set_control_text(pyloc "Door RH")
	controls.label_door_width:set_control_text(pyloc "Max door width")
	controls.label_width:set_control_text(pyloc "Left width")		
	controls.label_width2:set_control_text(pyloc "Right width")		
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
					width2 = 1000,},
	geometry_function = recreate_diagonal,
	placement_function = placement_diagonal,
	ui_update_function = ui_update_diagonal,
	organization_styles = {},
}


