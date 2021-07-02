--Blind End Side

function get_blind_end_row_height_base_height(general_data, specific_data)
	local base_height = 0
	local height = 0
	if specific_data.aux_values.row == 0x1 then 
		height = general_data.benchtop_height - general_data.benchtop_thickness 
	elseif specific_data.aux_values.row == 0x2 then 
		base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
		height = specific_data.height_top - base_height
	elseif specific_data.aux_values.row == 0x3 then 
		height = specific_data.height_top - base_height
	end
	return base_height, height
end

local function recreate_blind(general_data, specific_data)
	local cur_elements = {}
	
	local loc_origin= {}
	local base_height, height = get_blind_end_row_height_base_height(general_data, specific_data)

	loc_origin[1] = 0
	loc_origin[2] = 0 - specific_data.width2
	loc_origin[3] = base_height


	
	local new_elem = pytha.create_block(specific_data.width, specific_data.depth + specific_data.width2, height, loc_origin)
	set_part_attributes(new_elem, "blind_end")
	table.insert(cur_elements, new_elem)

	specific_data.aux_values.kickboard_handle_right = nil
	specific_data.aux_values.kickboard_handle_left = nil
	specific_data.aux_values.main_group = pytha.create_group(cur_elements)
	
	if specific_data.aux_values.row == 0x1 then 
		--Benchtop
		create_straight_benchtop(general_data, specific_data, specific_data.width)
	end
	return specific_data.aux_values.main_group
end


local function recreate_filler(general_data, specific_data)
	local cur_elements = {}
	local carcass_elements = {}
	
	local loc_origin= {}
	local base_height, height = get_cabinet_row_height_base_height(general_data, specific_data)
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height

	specific_data.drawer_count = 1

	
	local new_elem = pytha.create_block(general_data.thickness, specific_data.width2, height, loc_origin)
	set_part_attributes(new_elem, "inner_end")
	table.insert(carcass_elements, new_elem)
	
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, specific_data.width2, height, loc_origin)
	set_part_attributes(new_elem, "inner_end")
	table.insert(carcass_elements, new_elem)

	--Front
	recreate_basic_front(general_data, specific_data, base_height, height, specific_data.width, specific_data.width2, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0})

	if specific_data.aux_values.row == 0x1 then 
		--Benchtop
		create_straight_benchtop(general_data, specific_data, specific_data.width)
	end
	specific_data.aux_values.kickboard_handle_right = nil
	specific_data.aux_values.kickboard_handle_left = nil
	if specific_data.aux_values.row ~= 0x2 then 	
		--Kickboard
		create_straight_kickboard(general_data, specific_data, base_height, specific_data.width, cur_elements)
	end
	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)
	specific_data.aux_values.main_group = pytha.create_group(cur_elements)
	return specific_data.aux_values.main_group
end

local function get_miter_edge(general_data, specific_data, position, left_right_off)
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap
	local angle = math.abs(specific_data.angle)
	local depth = get_cabinet_depth(general_data, specific_data)
	local offset_x = 0
	local offset_y = 0
	if left_right_off < 0 then 
		offset_x = left_right_off
	elseif left_right_off > 0 then
		offset_x = COS(specific_data.angle) * left_right_off
		offset_y = SIN(specific_data.angle) * left_right_off
	end
	
	if specific_data.angle > 0 then 
		return {specific_data.width + TAN(angle / 2) * (position + door_to_carcass) + offset_x, position + offset_y, 0}
	else
		return {specific_data.width + TAN(angle / 2) * (depth - position) + offset_x, position + offset_y, 0}
	end
end

local function get_right_edge(general_data, specific_data, position, offset)
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap
	local depth = get_cabinet_depth(general_data, specific_data)
	local angle = math.abs(specific_data.angle)
	if specific_data.angle > 0 then 
		return {specific_data.width + SIN(angle) * (position + door_to_carcass) + COS(angle) * (specific_data.width2 - offset), 
				COS(angle) * (position + door_to_carcass) - SIN(angle) * (specific_data.width2 - offset) - door_to_carcass, 0}
	else
		return {specific_data.width + SIN(angle) * (depth - position) + COS(angle) * (specific_data.width2 - offset), 
				depth - COS(angle) * (depth - position) + SIN(angle) * (specific_data.width2 - offset), 0}
	end
end
local function get_tan_alpha_4(general_data, specific_data, position)
	local angle = math.abs(specific_data.angle)
	return TAN(angle / 4) * (position + general_data.top_over)
end

function get_cabinet_depth(general_data, specific_data)
	if specific_data.aux_values.row == 0x2 then 
		return specific_data.depth_wall
	end
	return specific_data.depth
end
local function recreate_angle(general_data, specific_data)
	local cur_elements = {}
	local carcass_elements = {}
	
	local loc_origin= {}
	local base_height, height = get_cabinet_row_height_base_height(general_data, specific_data)
	local door_height = height
	local depth = get_cabinet_depth(general_data, specific_data)
	if specific_data.aux_values.row == 0x1 then 
		door_height = height - general_data.top_gap
	end

	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap
	local angle = math.abs(specific_data.angle)

	local tan_alpha_4_1 = get_tan_alpha_4(general_data, specific_data, 0)
	local tan_alpha_4_2 = get_tan_alpha_4(general_data, specific_data, general_data.thickness)

	local tan_alpha_4_1_fr = get_tan_alpha_4(general_data, specific_data, - door_to_carcass)
	local tan_alpha_4_2_fr = get_tan_alpha_4(general_data, specific_data, - general_data.door_carcass_gap)

	local benchtop_array = {}
	local kickboard_array = {}
	local kickboard_array2 = {}
	local kickboard_array3 = {}
	local blind_end_1 = {}
	local blind_end_2 = {}
	local blind_end_3 = {}
	local blind_front_1 = {}
	local blind_front_2 = {}
	local blind_front_3 = {}

	if specific_data.angle >= 0 then 
		table.insert(blind_end_1, {0, 0, 0})
		if angle <= 170 then
			table.insert(blind_end_1, get_miter_edge(general_data, specific_data, 0, 0))
			table.insert(blind_end_1, get_miter_edge(general_data, specific_data, general_data.thickness, 0))
		end
		table.insert(blind_end_1, {0, general_data.thickness, 0})
		
		table.insert(blind_end_2, get_right_edge(general_data, specific_data, 0, 0))
		table.insert(blind_end_2, get_right_edge(general_data, specific_data, 0 + general_data.thickness, 0))
		if angle <= 170 then
			table.insert(blind_end_2, get_miter_edge(general_data, specific_data, general_data.thickness, 0))
			table.insert(blind_end_2, get_miter_edge(general_data, specific_data, 0, 0))
		end
	
	else 
		table.insert(blind_end_1, {0, 0, 0})
		
		table.insert(blind_end_2, get_right_edge(general_data, specific_data, 0, 0))
		table.insert(blind_end_2, get_right_edge(general_data, specific_data, general_data.thickness, 0))
		if angle <= 90 then
			table.insert(blind_end_1, get_miter_edge(general_data, specific_data, 0, 0))
			table.insert(blind_end_1, get_miter_edge(general_data, specific_data, general_data.thickness, 0))

			table.insert(blind_end_2, get_miter_edge(general_data, specific_data, general_data.thickness, 0))
			table.insert(blind_end_2, get_miter_edge(general_data, specific_data, 0, 0))
		else
			
			local p1 = {specific_data.width - tan_alpha_4_1, 0, 0}
			local p2 = {specific_data.width  - tan_alpha_4_2, general_data.thickness, 0}
			if specific_data.width  - tan_alpha_4_2 > 0 then 
				table.insert(blind_end_1, p1)
				table.insert(blind_end_1, p2)
			elseif specific_data.width  - tan_alpha_4_1 > 0 then 
				table.insert(blind_end_1, 1, p2)
				table.insert(blind_end_1, p1)
			else
				table.insert(blind_end_1, 1, p2)
				table.insert(blind_end_1, 2, p1)
			end
			
			local ori_p = get_right_edge(general_data, specific_data, -general_data.top_over, specific_data.width2)
			local off_1 = general_data.top_over
			local off_2 = general_data.top_over + general_data.thickness
			local p3 = {ori_p[1] + tan_alpha_4_2 * COS(angle) - off_2 * SIN(angle), ori_p[2] + tan_alpha_4_2 * SIN(angle) + off_2 * COS(angle), 0}
			local p4 = {ori_p[1] + tan_alpha_4_1 * COS(angle) - off_1 * SIN(angle), ori_p[2] + tan_alpha_4_1 * SIN(angle) + off_1 * COS(angle), 0}
			if specific_data.width2  - tan_alpha_4_2 > 0 then 
				table.insert(blind_end_2, p3)
				table.insert(blind_end_2, p4)
			elseif specific_data.width2  - tan_alpha_4_1 > 0 then 
				table.insert(blind_end_2, 2, p3)
				table.insert(blind_end_2, p4)
			else
				table.insert(blind_end_2, 2, p4)
				table.insert(blind_end_2, 3, p3)
			end
			blind_end_3 = {p1, p4, p3, p2}
		end
		table.insert(blind_end_1, {0, general_data.thickness, 0})
	end

	create_profile_from_poly(blind_end_1, height, loc_origin, carcass_elements, "blind_panel")
	create_profile_from_poly(blind_end_2, height, loc_origin, carcass_elements, "blind_panel")
	if #blind_end_3 > 0 then
		create_profile_from_poly(blind_end_3, height, loc_origin, carcass_elements, "blind_panel")
	end

	if specific_data.angle >= 0 then 
		table.insert(blind_front_1, {general_data.gap, -door_to_carcass, 0})
		if angle <= 170 then
			table.insert(blind_front_1, get_miter_edge(general_data, specific_data, -door_to_carcass, 0))
			table.insert(blind_front_1, get_miter_edge(general_data, specific_data, -general_data.door_carcass_gap, 0))
		end
		table.insert(blind_front_1, {general_data.gap, -general_data.door_carcass_gap, 0})
		
		table.insert(blind_front_2, get_right_edge(general_data, specific_data, -door_to_carcass, general_data.gap))
		table.insert(blind_front_2, get_right_edge(general_data, specific_data, -general_data.door_carcass_gap, general_data.gap))
		if angle <= 170 then
			table.insert(blind_front_2, get_miter_edge(general_data, specific_data, -general_data.door_carcass_gap, 0))
			table.insert(blind_front_2, get_miter_edge(general_data, specific_data, -door_to_carcass, 0))
		end
	
	else 
		table.insert(blind_front_1, {general_data.gap, -door_to_carcass, 0})
		
		table.insert(blind_front_2, get_right_edge(general_data, specific_data, -door_to_carcass, general_data.gap))
		table.insert(blind_front_2, get_right_edge(general_data, specific_data, -general_data.door_carcass_gap, general_data.gap))
		if angle <= 90 then
			table.insert(blind_front_1, get_miter_edge(general_data, specific_data, -door_to_carcass, 0))
			table.insert(blind_front_1, get_miter_edge(general_data, specific_data, -general_data.door_carcass_gap, 0))

			table.insert(blind_front_2, get_miter_edge(general_data, specific_data, -general_data.door_carcass_gap, 0))
			table.insert(blind_front_2, get_miter_edge(general_data, specific_data, -door_to_carcass, 0))
		else
			
			local p1 = {specific_data.width - tan_alpha_4_1_fr, -door_to_carcass, 0}
			local p2 = {specific_data.width  - tan_alpha_4_2_fr, -general_data.door_carcass_gap, 0}
			if specific_data.width  - tan_alpha_4_2_fr > 0 then 
				table.insert(blind_front_1, p1)
				table.insert(blind_front_1, p2)
			elseif specific_data.width  - tan_alpha_4_1_fr > 0 then 
				table.insert(blind_front_1, 1, p2)
				table.insert(blind_front_1, p1)
			else
				table.insert(blind_front_1, 1, p2)
				table.insert(blind_front_1, 2, p1)
			end
			
			local ori_p = get_right_edge(general_data, specific_data, -general_data.top_over, specific_data.width2)
			local off_1 = general_data.top_over - door_to_carcass
			local off_2 = general_data.top_over - general_data.door_carcass_gap
			local p3 = {ori_p[1] + tan_alpha_4_2_fr * COS(angle) - off_2 * SIN(angle), ori_p[2] + tan_alpha_4_2_fr * SIN(angle) + off_2 * COS(angle), 0}
			local p4 = {ori_p[1] + tan_alpha_4_1_fr * COS(angle) - off_1 * SIN(angle), ori_p[2] + tan_alpha_4_1_fr * SIN(angle) + off_1 * COS(angle), 0}
			if specific_data.width2  - tan_alpha_4_2_fr > 0 then 
				table.insert(blind_front_2, p3)
				table.insert(blind_front_2, p4)
			elseif specific_data.width2  - tan_alpha_4_1_fr > 0 then 
				table.insert(blind_front_2, 2, p3)
				table.insert(blind_front_2, p4)
			else
				table.insert(blind_front_2, 2, p4)
				table.insert(blind_front_2, 3, p3)
			end
			blind_front_3 = {p1, p4, p3, p2}
		end
		table.insert(blind_front_1, {general_data.gap, -general_data.door_carcass_gap, 0})
	end

	if not (specific_data.angle >= 0 and specific_data.width < general_data.gap) then 
		create_profile_from_poly(blind_front_1, door_height, loc_origin, carcass_elements, "blind_front", specific_data.aux_values.row)
	end 
	if not (specific_data.angle >= 0 and specific_data.width2 < general_data.gap) then 
		create_profile_from_poly(blind_front_2, door_height, loc_origin, carcass_elements, "blind_front", specific_data.aux_values.row)
	end
	if #blind_front_3 > 0 then
		create_profile_from_poly(blind_front_3, door_height, loc_origin, carcass_elements, "blind_front", specific_data.aux_values.row)
	end 

	if specific_data.angle >= 0 then 
		table.insert(benchtop_array, {0, -general_data.top_over, 0})
		table.insert(benchtop_array, get_miter_edge(general_data, specific_data, -general_data.top_over, 0))
	
		table.insert(benchtop_array, get_right_edge(general_data, specific_data, -general_data.top_over, 0))
		table.insert(benchtop_array, get_right_edge(general_data, specific_data, depth, 0))
		if angle <= 170 then
			table.insert(benchtop_array, get_miter_edge(general_data, specific_data, depth, 0))
		end
		table.insert(benchtop_array, {0, depth, 0})


	else 
		table.insert(benchtop_array, {0, -general_data.top_over, 0})
		if angle <= 90 then
			table.insert(benchtop_array, get_miter_edge(general_data, specific_data, -general_data.top_over, 0))
		else
	 		table.insert(benchtop_array, {specific_data.width, -general_data.top_over, 0})
			table.insert(benchtop_array, get_right_edge(general_data, specific_data, -general_data.top_over, specific_data.width2))
		end
		table.insert(benchtop_array, get_right_edge(general_data, specific_data, -general_data.top_over, 0))
		table.insert(benchtop_array, get_right_edge(general_data, specific_data, depth, 0))
		table.insert(benchtop_array, {specific_data.width + COS(angle) * specific_data.width2, depth + SIN(angle) * specific_data.width2, 0})
		table.insert(benchtop_array, {specific_data.width, depth, 0})
		table.insert(benchtop_array, {0, depth, 0})
	end

	tan_alpha_4_1 = get_tan_alpha_4(general_data, specific_data, general_data.kickboard_setback)
	tan_alpha_4_2 = get_tan_alpha_4(general_data, specific_data, general_data.kickboard_setback + general_data.kickboard_thickness)
	
	if specific_data.angle >= 0 then 
		table.insert(kickboard_array, {0, general_data.kickboard_setback, 0})
		if angle <= 170 then
			table.insert(kickboard_array, get_miter_edge(general_data, specific_data, general_data.kickboard_setback, 0))
			table.insert(kickboard_array, get_miter_edge(general_data, specific_data, general_data.kickboard_setback + general_data.kickboard_thickness, 0))
		end
		table.insert(kickboard_array, {0, general_data.kickboard_setback + general_data.kickboard_thickness, 0})
		
		table.insert(kickboard_array2, get_right_edge(general_data, specific_data, general_data.kickboard_setback, 0))
		table.insert(kickboard_array2, get_right_edge(general_data, specific_data, general_data.kickboard_setback + general_data.kickboard_thickness, 0))
		if angle <= 170 then
			table.insert(kickboard_array2, get_miter_edge(general_data, specific_data, general_data.kickboard_setback + general_data.kickboard_thickness, 0))
			table.insert(kickboard_array2, get_miter_edge(general_data, specific_data, general_data.kickboard_setback, 0))
		end
	
	else 
		table.insert(kickboard_array, {0, general_data.kickboard_setback, 0})
		
		table.insert(kickboard_array2, get_right_edge(general_data, specific_data, general_data.kickboard_setback, 0))
		table.insert(kickboard_array2, get_right_edge(general_data, specific_data, general_data.kickboard_setback + general_data.kickboard_thickness, 0))
		if angle <= 90 then
			table.insert(kickboard_array, get_miter_edge(general_data, specific_data, general_data.kickboard_setback, 0))
			table.insert(kickboard_array, get_miter_edge(general_data, specific_data, general_data.kickboard_setback + general_data.kickboard_thickness, 0))

			table.insert(kickboard_array2, get_miter_edge(general_data, specific_data, general_data.kickboard_setback + general_data.kickboard_thickness, 0))
			table.insert(kickboard_array2, get_miter_edge(general_data, specific_data, general_data.kickboard_setback, 0))
		else
			
			local p1 = {specific_data.width - tan_alpha_4_1, general_data.kickboard_setback, 0}
			local p2 = {specific_data.width  - tan_alpha_4_2, general_data.kickboard_setback + general_data.kickboard_thickness, 0}
			if specific_data.width  - tan_alpha_4_2 > 0 then 
				table.insert(kickboard_array, p1)
				table.insert(kickboard_array, p2)
			elseif specific_data.width  - tan_alpha_4_1 > 0 then 
				table.insert(kickboard_array, 1, p2)
				table.insert(kickboard_array, p1)
			else
				table.insert(kickboard_array, 1, p2)
				table.insert(kickboard_array, 2, p1)
			end
			
			local ori_p = get_right_edge(general_data, specific_data, -general_data.top_over, specific_data.width2)
			local off_1 = general_data.kickboard_setback + general_data.top_over
			local off_2 = general_data.kickboard_setback + general_data.top_over + general_data.kickboard_thickness
			local p3 = {ori_p[1] + tan_alpha_4_2 * COS(angle) - off_2 * SIN(angle), ori_p[2] + tan_alpha_4_2 * SIN(angle) + off_2 * COS(angle), 0}
			local p4 = {ori_p[1] + tan_alpha_4_1 * COS(angle) - off_1 * SIN(angle), ori_p[2] + tan_alpha_4_1 * SIN(angle) + off_1 * COS(angle), 0}
			if specific_data.width2  - tan_alpha_4_2 > 0 then 
				table.insert(kickboard_array2, p3)
				table.insert(kickboard_array2, p4)
			elseif specific_data.width2  - tan_alpha_4_1 > 0 then 
				table.insert(kickboard_array2, 2, p3)
				table.insert(kickboard_array2, p4)
			else
				table.insert(kickboard_array2, 2, p4)
				table.insert(kickboard_array2, 3, p3)
			end
			kickboard_array3 = {p1, p4, p3, p2}
		end
		table.insert(kickboard_array, {0, general_data.kickboard_setback + general_data.kickboard_thickness, 0})
	end

	
	if specific_data.aux_values.row == 0x1 then 
		--Benchtop
		local benchtop = pytha.create_polygon(benchtop_array, {0,0, general_data.benchtop_height - general_data.benchtop_thickness})
		local profile_handles = pytha.create_profile(benchtop, general_data.benchtop_thickness)
		specific_data.aux_values.elem_handle_for_top = profile_handles[1]
		for i = 2, #profile_handles do 
			pytha.delete_element(profile_handles[i])
		end
		pytha.delete_element(benchtop)
	end
	specific_data.aux_values.kickboard_handle_right = nil
	specific_data.aux_values.kickboard_handle_left = nil
	if specific_data.aux_values.row ~= 0x2 then 	
		--Kickboard
		local fla_handle = pytha.create_polygon(kickboard_array, {0,0, general_data.kickboard_margin})		
		specific_data.aux_values.kickboard_handle_left = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin)[1]
		set_part_attributes(specific_data.aux_values.kickboard_handle_left, "kickboard")
		pytha.delete_element(fla_handle)
		table.insert(cur_elements, specific_data.aux_values.kickboard_handle_left)
		
		fla_handle = pytha.create_polygon(kickboard_array2, {0,0, general_data.kickboard_margin})		
		specific_data.aux_values.kickboard_handle_right = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin)[1]
		set_part_attributes(specific_data.aux_values.kickboard_handle_right, "kickboard")
		pytha.delete_element(fla_handle)
		table.insert(cur_elements, specific_data.aux_values.kickboard_handle_right)


		if #kickboard_array3 > 0 then
			fla_handle = pytha.create_polygon(kickboard_array3, {0,0, general_data.kickboard_margin})
			new_elem = pytha.create_profile(fla_handle, base_height - general_data.kickboard_margin)[1]
			set_part_attributes(new_elem, "kickboard")
			pytha.delete_element(fla_handle)
			table.insert(cur_elements, new_elem)
			table.insert(general_data.kickboards, new_elem)
		end
	end 
--	recreate_plan_details_base(general_data, specific_data, cur_elements)


carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
table.insert(cur_elements, carcass_elements)
	specific_data.aux_values.main_group = pytha.create_group(cur_elements)
	return specific_data.aux_values.main_group
end


local function placement_blind(general_data, specific_data)
	specific_data.aux_values.right_connection_point = {specific_data.width, specific_data.depth,0}
	specific_data.aux_values.left_connection_point = {0, specific_data.depth,0}
	specific_data.aux_values.right_direction = 0
	specific_data.aux_values.left_direction = 0
end


local function placement_angle(general_data, specific_data)
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap
	if specific_data.angle > 0 then 
		specific_data.aux_values.left_connection_point =  {0, specific_data.depth, 0}
		specific_data.aux_values.right_connection_point = {specific_data.width + SIN(specific_data.angle) * (specific_data.depth + door_to_carcass) + COS(specific_data.angle) * specific_data.width2, 
															COS(specific_data.angle) * (specific_data.depth + door_to_carcass) - SIN(specific_data.angle) * specific_data.width2 - door_to_carcass, 0}
		specific_data.origin_point = {specific_data.width + TAN(specific_data.angle / 2) * (specific_data.depth + door_to_carcass), specific_data.depth, 0}

	else 
		specific_data.aux_values.left_connection_point =  {0, specific_data.depth, 0}
		specific_data.aux_values.right_connection_point = {specific_data.width + COS(specific_data.angle) * specific_data.width2, specific_data.depth - SIN(specific_data.angle) * specific_data.width2, 0}
		specific_data.origin_point = {specific_data.width, specific_data.depth, 0}
	end
	specific_data.aux_values.right_direction = -specific_data.angle
	specific_data.aux_values.left_direction = 0
end

function ui_update_blind(general_data, soft_update)
	if soft_update == true then return end
	insert_specific_control(general_data, "width", pyloc "Thickness")
	insert_specific_control(general_data, "width2", pyloc "Protrusion")		
end	


function ui_update_filler(general_data, soft_update)
	if soft_update == true then return end
	insert_specific_control(general_data, "width", pyloc "Thickness")
	insert_specific_control(general_data, "width2", pyloc "Length of inner end")		
end	

function ui_update_angle(general_data, soft_update)
	if soft_update == true then return end
	insert_specific_control(general_data, "angle", nil)
	insert_specific_control(general_data, "width", pyloc "Excess length left")
	insert_specific_control(general_data, "width2", pyloc "Excess length right")
--	insert_specific_control(general_data, "door_side", pyloc "Flat")
end	
	

--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.blind_end = 				
{									
	name = pyloc "Blind End",
	row = 0x1,
	default_data = function (general_data, specific_data) specific_data.width = 20							--used for the thickness of the blind end
							specific_data.width2 = general_data.door_thickness + general_data.door_carcass_gap 	--used for the protrusion of the blind end 
							end,
	geometry_function = recreate_blind,
	placement_function = placement_blind, 	
	ui_update_function = ui_update_blind,
	organization_styles = {},
}

cabinet_typelist.blind_end_high = 				
{									
	name = pyloc "High Blind End",
	row = 0x3,
	default_data = function (general_data, specific_data) specific_data.width = 20							--used for the thickness of the blind end
						specific_data.width2 = general_data.door_thickness + general_data.door_carcass_gap 	--used for the protrusion of the blind end 
						end,
	geometry_function = recreate_blind,
	placement_function = placement_blind, 	 
	ui_update_function = ui_update_blind,
	organization_styles = {},
}
cabinet_typelist.blind_end_wall = 				
{									
	name = pyloc "Wall Blind End",
	row = 0x2,
	default_data = function (general_data, specific_data) specific_data.width = 20							--used for the thickness of the blind end
						specific_data.width2 = general_data.door_thickness + general_data.door_carcass_gap 	--used for the protrusion of the blind end 
						end,			
	geometry_function = recreate_blind,
	placement_function = placement_blind, 	
	ui_update_function = ui_update_blind,
	organization_styles = {},
}
cabinet_typelist.filler = 				
{									
	name = pyloc "Filler",
	row = 0x1,
	default_data = {width = 100,
					width2 = 60,
					shelf_count = 1,
					drawer_count = 1},
	geometry_function = recreate_filler,
	placement_function = placement_blind, 	
	ui_update_function = ui_update_filler,
	organization_styles = {"blind"},
}

cabinet_typelist.filler_high = 				
{									
	name = pyloc "High Filler",
	row = 0x3,
	default_data = {width = 100,
					width2 = 60,
					shelf_count = 1,
					drawer_count = 1},
	geometry_function = recreate_filler,
	placement_function = placement_blind, 	
	ui_update_function = ui_update_blind,
	organization_styles = {"blind"},
}
cabinet_typelist.filler_wall = 				
{									
	name = pyloc "Wall Filler",
	row = 0x2,
	default_data = {width = 100,
					width2 = 60,
					shelf_count = 1,
					drawer_count = 1},		
	geometry_function = recreate_filler,
	placement_function = placement_blind, 	
	ui_update_function = ui_update_blind,
	organization_styles = {"blind"},
}


cabinet_typelist.angle_piece = 				
{									
	name = pyloc "Angle Filler",
	row = 0x1,
	default_data = {angle = 45,
					width = 50,
					width2 = 50,},		
	geometry_function = recreate_angle,
	placement_function = placement_angle, 	
	ui_update_function = ui_update_angle,
	organization_styles = {},
}


cabinet_typelist.angle_piece_high = 				
{									
	name = pyloc "High Angle Filler",
	row = 0x3,
	default_data = {angle = 45,
					width = 50,
					width2 = 50,},		
	geometry_function = recreate_angle,
	placement_function = placement_angle, 	
	ui_update_function = ui_update_angle,
	organization_styles = {},
}


cabinet_typelist.angle_piece_wall = 				
{									
	name = pyloc "Wall Angle Filler",
	row = 0x2,
	default_data = {angle = 45,
					width = 50,
					width2 = 50,},		
	geometry_function = recreate_angle,
	placement_function = placement_angle, 	
	ui_update_function = ui_update_angle,
	organization_styles = {},
}

