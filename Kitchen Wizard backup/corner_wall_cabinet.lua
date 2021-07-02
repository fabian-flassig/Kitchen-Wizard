--Corner wall cabinet, both left and right sided door

local back_board_width = 160
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

local function recreate_cornerwall(general_data, specific_data)
	local cur_elements = {}
	
	local base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
	local height = specific_data.height_top - base_height
	local depth1 = specific_data.depth
	local depth2 = specific_data.depth2
	

	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin= {}
	local ext_elements = {}
	local carcass_elements = {}
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local door_to_carcass = door_carcass_calc(general_data, specific_data)

	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	--Left side
	local new_elem = pytha.create_block(general_data.thickness, depth1, height, loc_origin)
	set_part_attributes(new_elem, "end_lh")
	table.insert(carcass_elements, new_elem)
	
	--Right side
	loc_origin[1] = specific_data.width - depth2
	loc_origin[2] = depth1 - specific_data.width2
	new_elem = pytha.create_block(depth2, general_data.thickness, height, loc_origin)
	set_part_attributes(new_elem, "end_rh")
	table.insert(carcass_elements, new_elem)
	
	
	loc_origin[1] = 0
	loc_origin[2] = 0
	--Bottom
	if specific_data.row == 0x2 then
		poly_array = {{general_data.thickness, 0, 0}, 
						{specific_data.width - depth2, 0, 0}, 
						{specific_data.width - depth2, depth1 - specific_data.width2 + general_data.thickness, 0}, 
						{specific_data.width, depth1 - specific_data.width2 + general_data.thickness, 0}, 
						{specific_data.width, depth1, 0},
						{general_data.thickness, depth1, 0}}
	else
		poly_array = {{general_data.thickness, 0, 0}, 
						{specific_data.width - depth2, 0, 0}, 
						{specific_data.width - depth2, depth1 - specific_data.width2 + general_data.thickness, 0}, 
						{specific_data.width - groove_dist_back_off, depth1- specific_data.width2 + general_data.thickness, 0}, 
						{specific_data.width - groove_dist_back_off, depth1 - groove_dist_back_off, 0},
						{general_data.thickness, depth1 - groove_dist_back_off, 0}}
	end
	create_profile_from_poly(poly_array, general_data.thickness, loc_origin, carcass_elements, "bottom")

	
	--We reuse the fla handle for the top and the shelves
	loc_origin[3] = base_height + height - general_data.thickness
	create_profile_from_poly(poly_array, general_data.thickness, loc_origin, carcass_elements, "top")

	
	
	local slope = (specific_data.width2 - depth1 - general_data.thickness)/(specific_data.width - depth2 - general_data.thickness)
	local slope_angle = ATAN(slope)
	
	local p_left = get_backboard_left_point(general_data, specific_data, slope)
	local p_right = get_backboard_right_point(general_data, specific_data, slope)
	--Shelves
	poly_array = {{general_data.thickness + general_data.shelf_gap, general_data.setback_shelves, 0}, 
					{specific_data.width - depth2 + general_data.setback_shelves, general_data.setback_shelves, 0}, 
					{specific_data.width - depth2 + general_data.setback_shelves, depth1 - specific_data.width2 + general_data.thickness + general_data.shelf_gap, 0}, 
					{specific_data.width - groove_dist_back_off, depth1 - specific_data.width2 + general_data.thickness + general_data.shelf_gap, 0}, 
					{p_right[1], p_right[2] - general_data.shelf_gap * SIN(slope_angle), p_right[3]},
					{p_left[1] - general_data.shelf_gap * COS(slope_angle), p_left[2], p_left[3]},
					{general_data.thickness + general_data.shelf_gap, depth1 - groove_dist_back_off, 0}}
	
	for i=1,specific_data.shelf_count,1 do
		loc_origin[3] = base_height + i * (height - general_data.thickness) / (specific_data.shelf_count + 1)
		create_profile_from_poly(poly_array, general_data.thickness, loc_origin, carcass_elements, "adjustable_shelf")

	end
	pytha.delete_element(fla_handle)
	
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

	local back_height = height - general_data.thickness + general_data.groove_depth
	local back_max_width = specific_data.width - groove_dist_back_off - dx + general_data.thickness * PYTHAGORAS(1 / slope, 1)
	local back_width = back_max_width - general_data.thickness + general_data.groove_depth
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = door_to_carcass + depth1 - groove_dist_back_off
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
	back_max_width = specific_data.width2 - groove_dist_back_off - dy + general_data.thickness * PYTHAGORAS(slope, 1)
	back_width = back_max_width - general_data.thickness + general_data.groove_depth
	loc_origin[1] = specific_data.width - groove_dist_back_off
	loc_origin[2] = depth1 - specific_data.width2 + general_data.thickness - general_data.groove_depth
	if specific_data.back_style == "back_external" then
		loc_origin[2] = depth1 - specific_data.width2 
		back_width = back_max_width
	end
	new_elem = pytha.create_block(general_data.thickness_back, back_width, back_height, loc_origin)
	set_part_attributes(new_elem, "back")
	table.insert(carcass_elements, new_elem)

	
	
	--Door
	if specific_data.front_style ~= "base_open" then
		local door_width_left = specific_data.width - depth2 - general_data.thickness - 2 * general_data.gap - general_data.door_carcass_gap
		local door_width_right = specific_data.width2 - depth1 - general_data.thickness - 2 * general_data.gap - general_data.door_carcass_gap
		local door_key = "door_rh"
		if specific_data.door_rh == false then
			door_key = "door_lh"
		end
		local door_group1 = nil
		local door_group2 = nil
		local rp_pos1 = {}
		local rp_pos2 = {}
		local rp_pos3 = {}
		local rp_pos4 = {}
		if door_width_left > 0 then 
			loc_origin[1] = general_data.gap
			loc_origin[2] = -general_data.door_thickness - general_data.door_carcass_gap
			loc_origin[3] = base_height
			if specific_data.door_rh == false then 
				new_elem = pytha.create_block(door_width_left, general_data.door_thickness, height, loc_origin)
				set_part_attributes(new_elem, door_key)
				door_group1 = pytha.create_group(new_elem, {name = attribute_list[door_key].name})
				rp_pos1 = {loc_origin[1], loc_origin[2] + general_data.door_thickness, loc_origin[3] + height}
				rp_pos2 = {loc_origin[1] + door_width_left, loc_origin[2] + general_data.door_thickness, loc_origin[3] + height}
				rp_pos3 = {loc_origin[1], loc_origin[2] + general_data.door_thickness, loc_origin[3]}
				rp_pos4 = {loc_origin[1], loc_origin[2], loc_origin[3] + height}
			else 
				door_group1 = create_door_tkh(general_data, specific_data, door_width_left, height, loc_origin, specific_data.door_rh, 'bottom', ext_elements, loc_origin)
			end
		end
		if door_width_right > 0 then 
			
			loc_origin[1] = specific_data.width - depth2 - general_data.door_thickness - general_data.door_carcass_gap
			if specific_data.door_rh == false then
				loc_origin[2] = -general_data.door_thickness - general_data.door_carcass_gap - general_data.gap
			else
				loc_origin[2] = -general_data.door_thickness - general_data.door_carcass_gap - general_data.gap
			end
			loc_origin[3] = base_height
			options = {u_axis = {0, -1, 0}, v_axis = {1, 0, 0}, w_axis = {0,0,1}}

			if specific_data.door_rh == false then 
				local token = pytha.push_local_coordinates(loc_origin, options)
				door_group2 = create_door_tkh(general_data, specific_data, door_width_right, height, {0,0,0}, specific_data.door_rh, 'bottom', ext_elements, {0,0,0})
				pytha.pop_local_coordinates(token)
			else 
				local token = pytha.push_local_coordinates(loc_origin, options)
				new_elem = pytha.create_block(door_width_right, general_data.door_thickness, height, {0,0,0})
				pytha.pop_local_coordinates(token)
				set_part_attributes(new_elem, door_key)
				rp_pos1 = {loc_origin[1] + general_data.door_thickness, loc_origin[2], loc_origin[3] + height}
				rp_pos2 = {loc_origin[1] + general_data.door_thickness, loc_origin[2] - door_width_left, loc_origin[3] + height}
				rp_pos3 = {loc_origin[1] + general_data.door_thickness, loc_origin[2], loc_origin[3]}
				rp_pos4 = {loc_origin[1], loc_origin[2], loc_origin[3] + height}
				
				door_group2 = pytha.create_group(new_elem, {name = attribute_list[door_key].name})
			end

		end
		if specific_data.front_style ~= "base_open" and #ext_elements > 0  then
			ext_elements = pytha.create_group(ext_elements, {name = attribute_list["externals"].name})
			table.insert(cur_elements, ext_elements)
		end
		
		local total_door_group = pytha.create_group({door_group1, door_group2}, {name = attribute_list[door_key].name})
		pytha.create_element_ref_point(total_door_group, rp_pos1)
		pytha.create_element_ref_point(total_door_group, rp_pos2)
		pytha.create_element_ref_point(total_door_group, rp_pos3)
		pytha.create_element_ref_point(total_door_group, rp_pos4)
		if specific_data.door_rh == true then
			total_door_group:set_element_attributes({action_string = "ROTATE(90,R3R1,R2S30)"})
		else
			total_door_group:set_element_attributes({action_string = "ROTATE(-90,R3R1,R1S30)"})
		end
		table.insert(cur_elements, total_door_group)
	end
	
	--Downlight
	--we need to flip the face light source uside down, so we simply use the -z direction. 
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width / 2 + 25, math.max(depth1 - 150, depth1 / 2) - 25, base_height - 10}, {w_axis = "-z"})
	set_part_attributes(new_elem, "light")
	table.insert(cur_elements, new_elem)
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width + math.max(- 150, - depth2 / 2) + 25, depth2 - specific_data.width2 / 2 - 25, base_height - 10}, {w_axis = "-z"})
	set_part_attributes(new_elem, "light")
	table.insert(cur_elements, new_elem)

	specific_data.left_direction = 0
	
	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)
	
	specific_data.main_group = pytha.create_group(cur_elements)
	

	
	return specific_data.main_group
end

local function placement_cornerwall(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, specific_data.depth - specific_data.width2, 0}
	specific_data.left_connection_point = {0, specific_data.depth, 0}
	specific_data.origin_point = {specific_data.width, specific_data.depth, 0}
	specific_data.right_direction = -90
	specific_data.left_direction = 0
end

local function ui_update_cornerwall(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	
	if soft_update == true then return end

	insert_specific_control(general_data, "door_side", nil)

	insert_specific_control(general_data, "width", pyloc "Left width")
	insert_specific_control(general_data, "width2", pyloc "Right width")
	insert_specific_control(general_data, "height_top", nil)
	insert_specific_control(general_data, "shelf_count", nil)
	insert_specific_control(general_data, "depth", nil)
	insert_specific_control(general_data, "depth2", nil)
		
	
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.cornerwall = 				
{									
	name = pyloc "Corner wall cabinet",
	row = 0x2,
	default_data = function(general_data, specific_data) specific_data.width = 650
														specific_data.width2 = 650
														specific_data.depth = general_data.depth_wall
														specific_data.depth2 = general_data.depth_wall
					end,
	geometry_function = recreate_cornerwall,
	placement_function = placement_cornerwall, 	
	ui_update_function = ui_update_cornerwall,
	organization_styles = {"intelli_doors",
								"open",}
}

