--some basic logic for the vertical position of the handles
function get_handle_v_pos(general_data, specific_data, door_height, origin)
	if 	origin[3] < general_data.benchtop_height / 2 and origin[3] + door_height > 1500 then 
		return 'benchtop'
	end
	if math.abs(origin[3] - general_data.benchtop_height) < math.abs(origin[3] + door_height - general_data.benchtop_height) then 
		return 'bottom'
	end

	return 'top'
end

function create_plain_front(general_data, width, door_thickness, door_height, origin, door_key)
	new_elem = pytha.create_block(width, door_thickness, door_height, origin)
	set_part_attributes(new_elem, door_key)
	
	local door_group = pytha.create_group(new_elem, {name = attribute_list[door_key].name})
	return door_group
end
function create_frame1_front(general_data, width, door_thickness, door_height, origin, door_key)
	local frame_width = general_data.panel_frame_width
	local door_table = {}
	local central_panel_thickness = general_data.panel_central_thickness

	if width < 2 * frame_width + 20 or door_height < 2 * frame_width + 20 then --arbitrary constraints to create a flat panel for e.g. small drawers
		return create_plain_front(general_data, width, door_thickness, door_height, origin, door_key)
	end

	local rel_origin = {origin[1] + frame_width, origin[2], origin[3]}
	new_elem = pytha.create_block(width - 2 * frame_width, door_thickness, frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)

	rel_origin = {origin[1], origin[2], origin[3]}
	new_elem = pytha.create_block(frame_width, door_thickness, door_height, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	
	rel_origin = {origin[1] + width - frame_width, origin[2], origin[3]}
	new_elem = pytha.create_block(frame_width, door_thickness, door_height, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	
	rel_origin = {origin[1] + frame_width, origin[2], origin[3] + door_height - frame_width}
	new_elem = pytha.create_block(width - 2 * frame_width, door_thickness, frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	
	rel_origin = {origin[1] + frame_width, origin[2] + door_thickness - central_panel_thickness, origin[3] + frame_width}
	new_elem = pytha.create_block(width - 2 * frame_width, central_panel_thickness, door_height - 2 * frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	local door_group = pytha.create_group(door_table, {name = attribute_list[door_key].name})
	return door_group
end

function create_frame2_front(general_data, width, door_thickness, door_height, origin, door_key)
	local frame_width = general_data.panel_frame_width
	local door_table = {}
	local central_panel_thickness = general_data.panel_central_thickness
	
	if width < 2 * frame_width + 20 or door_height < 2 * frame_width + 20 then --arbitrary constraints to create a flat panel for e.g. small drawers
		return create_plain_front(general_data, width, door_thickness, door_height, origin, door_key)
	end

	local rel_origin = {origin[1], origin[2], origin[3]}
	new_elem = pytha.create_block(width, door_thickness, frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)

	rel_origin = {origin[1], origin[2], origin[3] + frame_width}
	new_elem = pytha.create_block(frame_width, door_thickness, door_height - 2 * frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	
	rel_origin = {origin[1] + width - frame_width, origin[2], origin[3] + frame_width}
	new_elem = pytha.create_block(frame_width, door_thickness, door_height - 2 * frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	
	rel_origin = {origin[1], origin[2], origin[3] + door_height - frame_width}
	new_elem = pytha.create_block(width, door_thickness, frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	
	rel_origin = {origin[1] + frame_width, origin[2] + door_thickness - central_panel_thickness, origin[3] + frame_width}
	new_elem = pytha.create_block(width - 2 * frame_width, central_panel_thickness, door_height - 2 * frame_width, rel_origin)
	set_part_attributes(new_elem, door_key)
	table.insert(door_table, new_elem)
	local door_group = pytha.create_group(door_table, {name = attribute_list[door_key].name})
	return door_group
end


panel_options = {
	{ name = pyloc "Plain",
		geometry_function = create_plain_front,
	},
	{ name = pyloc "Frame 1",
		geometry_function = create_frame1_front,
	},
	{ name = pyloc "Frame 2",
		geometry_function = create_frame2_front,
	},
	--here you can add an option e.g. from file
}

function create_door_panel(general_data, width, door_thickness, door_height, origin, door_key)
	local loc_panel_type = general_data.panel_type
	if general_data.panel_type == nil or general_data.panel_type < 1 or general_data.panel_type > #panel_options then 
		loc_panel_type = 1
	end
	local new_elem = panel_options[loc_panel_type].geometry_function(general_data, width, door_thickness, door_height, origin, door_key)
	pytha.set_group_replace_properties(new_elem, {origin_u = 'mid', origin_v = 'high', origin_w = 'mid', zoom_u = true, zoom_v = false, zoom_w = true})
	return new_elem
end


-- Door
function create_door_tkh(general_data, specific_data, width, height, origin, door_rh, v_posi_code, ext_elements, base_origin)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local door_thickness = general_data.door_thickness
	local door_height = height
	
	local door_key = "door_rh"
	if door_rh == false then
		door_key = "door_lh"
	end

	new_elem = create_door_panel(general_data, width, door_thickness, door_height, origin, door_key)

	local h_posi_code = ''
	local vertical = false
	
	if general_data.handle_position == 1 then 
		vertical = true
	end
	if v_posi_code == nil then
		v_posi_code = get_handle_v_pos(general_data, specific_data, door_height, base_origin)
	end
	if general_data.handle_position == 1 or general_data.handle_position == 2 then 
		if door_rh == false then	
			h_posi_code = 'right'
		else 
			h_posi_code = 'left'
		end
	elseif general_data.handle_position == 3 then 
		h_posi_code = 'center'
	end
	local handle = create_handle(general_data, specific_data, origin, width, door_height, vertical, h_posi_code, v_posi_code, base_origin)
	local door_group = pytha.create_group({handle, new_elem}, {name = attribute_list[door_key].name})
	local elevation_elem = nil
	local plan_elem = nil
	elevation_elem, plan_elem = create_doorline_tkh(general_data, specific_data, origin, width, door_height, door_rh)

	local rp_pos = {origin[1],
					origin[2] + door_thickness,
					origin[3] + door_height}
	if specific_data.this_type == "overhead_tkh" then
		rp_pos[3] = origin[3] + door_height
	end
	if door_group ~= nil then
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = rp_pos[1] + width
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = origin[1]
		rp_pos[3] = origin[3]
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[3] = origin[3] + door_height
		if specific_data.this_type == "overhead_tkh" then
			rp_pos[3] = origin[3] + door_height
		end
		rp_pos[2] = rp_pos[2] - general_data.door_thickness
		pytha.create_element_ref_point(door_group, rp_pos)
	end



	if door_rh == true then
		door_group:set_element_attributes({action_string = "ROTATE(70,R3R1,R2S30)"})
	else
		door_group:set_element_attributes({action_string = "ROTATE(-70,R3R1,R1S30)"})
	end
	
	table.insert(ext_elements, door_group)
	table.insert(ext_elements, elevation_elem)
	table.insert(ext_elements, plan_elem)
	return door_group, elevation_elem, plan_elem
end

--TKH Door Drawings
function create_doorline_tkh(general_data, specific_data, origin, width, height, door_rh)
	local loc_origin = {origin[1], origin[2], origin[3]} 

	if door_rh then
		loc_origin[1] = loc_origin[1] + width
	end

	local elevation_elem = nil
	local plan_elem = nil
	if door_rh then
		elevation_elem = pytha.create_polyline("open", {{loc_origin[1], loc_origin[2], loc_origin[3]},
														{loc_origin[1] - width, loc_origin[2], loc_origin[3]+ height/2},
														{loc_origin[1], loc_origin[2], loc_origin[3] + height}})
		plan_elem = pytha.create_polygon({{loc_origin[1], loc_origin[2], loc_origin[3]},
											{loc_origin[1] - width, loc_origin[2] - 49, loc_origin[3]},
											{loc_origin[1] - width, loc_origin[2] - 55, loc_origin[3]},
											{loc_origin[1], loc_origin[2] - 6, loc_origin[3]}})
	else
		elevation_elem = pytha.create_polyline("open", {{loc_origin[1], loc_origin[2], loc_origin[3]},
														{loc_origin[1] + width, loc_origin[2], loc_origin[3]+ height/2},
														{loc_origin[1], loc_origin[2], loc_origin[3] + height}})
		plan_elem = pytha.create_polygon({{loc_origin[1], loc_origin[2], loc_origin[3]},
											{loc_origin[1], loc_origin[2] - 6, loc_origin[3]},
											{loc_origin[1] + width, loc_origin[2] - 55, loc_origin[3]},
											{loc_origin[1] + width, loc_origin[2] - 49, loc_origin[3]}})
	end

	set_part_attributes(elevation_elem, "door_swing")
	set_part_attributes(plan_elem, "floor_plan")

	return elevation_elem, plan_elem
end

function create_drawer_tkh(general_data, specific_data, width, shelf_depth, drawer_height, origin, ext_elements, base_origin)

	local h_posi_code = 'center'
	local v_posi_code = 'top'
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local depth = shelf_depth --specific_data.depth - general_data.groove_dist - general_data.thickness_back
	if specific_data.fingerpull then
		drawer_height = drawer_height - 22
	end

	--Drawer Front
	local drawer_front = create_door_panel(general_data, width, general_data.door_thickness, drawer_height, loc_origin, "dr_front")

	local elevation_elem = create_drawerelevation_tkh(general_data, specific_data, origin, width, drawer_height)
	local drawer_box = nil
	loc_origin[1] = origin[1] + general_data.thickness - general_data.gap
	loc_origin[2] = origin[2] + general_data.door_thickness
	loc_origin[3] = origin[3] + general_data.thickness

	if specific_data.fingerpull then
		new_elem = pytha.create_block(width - 2 * (general_data.thickness - general_data.gap), specific_data.depth - (general_data.top_over + general_data.door_thickness + general_data.door_carcass_gap + general_data.thickness + 13.5), drawer_height - (23.5 + 18.5) - 21.5, loc_origin)
	
		drawer_box = pytha.create_group(new_elem, {name = attribute_list["dr_box"].name})
		pytha.set_group_replace_properties(drawer_box, {origin_u = 'mid', origin_v = 'low', origin_w = 'low', zoom_u = true, zoom_v = false, zoom_w = false})
	else

		--Drawer Box: values are max values to allow for replacement with drawer box with runners
		local drawer_box_collection = {}
		if specific_data.row == 0x2 then
			depth = specific_data.depth - general_data.groove_dist - general_data.thickness_back
		end
		local token = pytha.push_local_coordinates(loc_origin, {u_axis = "x", v_axis = "y", w_axis = "z"})
		local new_elem = pytha.create_block(width - 4 * general_data.thickness + 2 * general_data.gap, depth - 2 * general_data.thickness, general_data.thickness, {general_data.thickness, general_data.thickness, 0})
		set_part_attributes(new_elem, "dr_bottom")
		table.insert(drawer_box_collection, new_elem)
		new_elem = pytha.create_block(width - 4 * general_data.thickness + 2 * general_data.gap, general_data.thickness, drawer_height - 2 * general_data.thickness, {general_data.thickness, 0, 0})
		set_part_attributes(new_elem, "dr_front")
		table.insert(drawer_box_collection, new_elem)
		new_elem = pytha.create_block(general_data.thickness, depth - general_data.thickness, drawer_height - 2 * general_data.thickness, {0, 0, 0})
		set_part_attributes(new_elem, "dr_left")
		table.insert(drawer_box_collection, new_elem)
		new_elem = pytha.create_block(general_data.thickness, depth - general_data.thickness, drawer_height - 2 * general_data.thickness, {width - 3 * general_data.thickness + 2 * general_data.gap, 0, 0})
		set_part_attributes(new_elem, "dr_right")
		table.insert(drawer_box_collection, new_elem)
		new_elem = pytha.create_block(width - 2 * general_data.thickness + 2 * general_data.gap, general_data.thickness, drawer_height - 2 * general_data.thickness, {0, depth - general_data.thickness, 0})
		set_part_attributes(new_elem, "dr_back")
		table.insert(drawer_box_collection, new_elem)
		pytha.pop_local_coordinates(token)
		
		drawer_box = pytha.create_group(drawer_box_collection, {name = attribute_list["dr_box"].name})
		pytha.set_group_replace_properties(drawer_box, {origin_u = 'mid', origin_v = 'low', origin_w = 'low', zoom_u = true, zoom_v = false, zoom_w = false})
	end
	
	local rp_pos = loc_origin
	pytha.create_element_ref_point(drawer_box, rp_pos)
	rp_pos[1] = rp_pos[1] + width - 2 * (general_data.thickness - general_data.gap)
	pytha.create_element_ref_point(drawer_box, rp_pos)

	
	loc_origin = {origin[1], origin[2], origin[3]} 
	local handle = create_handle(general_data, specific_data, loc_origin, width, drawer_height, false, h_posi_code, v_posi_code, base_origin)

	local grouping_table = {}
	if drawer_front ~= nil then table.insert(grouping_table, drawer_front) end
	if handle ~= nil then table.insert(grouping_table, handle) end
	if drawer_box ~= nil then table.insert(grouping_table, drawer_box) end

	local drawer_group = pytha.create_group(grouping_table, {name = attribute_list["drawer"].name})
	drawer_group:set_element_attributes({action_string = "MOVE(-0,-" .. 0.75*depth .. ",-0S34)"})

	table.insert(ext_elements, drawer_group)
	table.insert(ext_elements, elevation_elem)

	return drawer_group, elevation_elem
	
end
function create_blind_front(general_data, specific_data, width, drawer_height, origin, ext_elements)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	if specific_data.fingerpull then
		drawer_height = drawer_height - 22
	end
	
	--Drawer Front
	local drawer_front = create_door_panel(general_data, width, general_data.door_thickness, drawer_height, loc_origin, "blind_front")

	loc_origin[1] = origin[1] + general_data.thickness - general_data.gap
	loc_origin[2] = origin[2] + general_data.door_thickness + general_data.door_carcass_gap
	loc_origin[3] = origin[3] + 18.5

	--for the blind piece it doesnt matter whether there is a fingerpull or not
--[[ 	new_elem = pytha.create_block(width - 2 * (general_data.thickness - general_data.gap), general_data.thickness, drawer_height - 18.5 + general_data.top_gap - general_data.thickness, loc_origin)

	
	set_part_attributes(new_elem, "blind_mount")
	local rp_pos = loc_origin
	pytha.create_element_ref_point(new_elem, rp_pos)
	rp_pos[1] = rp_pos[1] + width - 2 * (general_data.thickness - general_data.gap)
	pytha.create_element_ref_point(new_elem, rp_pos) ]]

	table.insert(ext_elements, drawer_front)
	--					table.insert(carcass_elements, blind_elem)
	return drawer_front --, new_elem
	
end

--TKH Drawer Drawings
function create_drawerelevation_tkh(general_data, specific_data, origin, width, height)
	local loc_origin = {origin[1], origin[2], origin[3]} 

	local elevation_elem = nil
	--local plan_elem = nil

	elevation_elem = pytha.create_polyline("open", {{loc_origin[1], loc_origin[2], loc_origin[3]},
													{loc_origin[1] + width / 2, loc_origin[2], loc_origin[3] + height},
													{loc_origin[1] + width, loc_origin[2], loc_origin[3]}})
	--[[plan_elem = pytha.create_polygon({{loc_origin[1], loc_origin[2], loc_origin[3]},
										{loc_origin[1] - width, loc_origin[2] - 49, loc_origin[3]},
										{loc_origin[1] - width, loc_origin[2] - 55, loc_origin[3]},
										{loc_origin[1], loc_origin[2] - 6, loc_origin[3]}})--]]


	set_part_attributes(elevation_elem, "door_swing")
	return elevation_elem --, plan_elem
end

--handles have to be drawn in xz plane at y=0, including three group reference points at the bore hole positions left and right. With 2 reference points a knob is assumed.
function load_handle(general_data, specific_data)
	local loaded_parts = pytha.import_pyo(general_data.handle_file)
	if loaded_parts ~= nil then 
		for i = #loaded_parts, 1, -1 do 
			local ref_point_coos = pytha.get_element_ref_point_coordinates(loaded_parts[i])
			if #ref_point_coos > 0 then 
				local left_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				local right_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				if #ref_point_coos > 1 then
					right_point = {ref_point_coos[2][1], ref_point_coos[2][2], ref_point_coos[2][3]}
				end
				pytha.move_element(loaded_parts, {-left_point[1], -left_point[2], -left_point[3]}) 
			end
		end
	end
	return loaded_parts
end


--origin, width and height are for the whole door. The handle then is positioned according to the posi codes
function create_handle(general_data, specific_data, origin, width, height, vert, h_posi_code, v_posi_code, base_origin)
	local loc_origin = {origin[1], origin[2], origin[3]} 	--tables are by reference, so you could overwrite the origin in the calling function. Therefore we assign by value.
	local handle_over = 12.5
	local handle_length = general_data.handle_length
	local total_length = handle_length + 2 * handle_over
	local diameter = 12
	local block_length = 23
	local block_height = 10
	local knob_diameter = 30
	local knob_thickness = 8
	local bore_hole_diameter = 5
	local depth = 38 - diameter / 2
	local left_rp = {0,0,0}
	local right_rp = {0,0,0}
	local hori_off = general_data.handle_dist_hori
	local vert_off = general_data.handle_dist_vert
	
	local perp_dir = {0,1,0}	--its just shorter

	-- handle offset to front, this is independent of handle position
	loc_origin[1] = loc_origin[1]
	loc_origin[2] = loc_origin[2] - depth
	
	local reference_coordinate = {loc_origin[1], loc_origin[2], loc_origin[3]}
	--handle offset position dependent
	
	if h_posi_code == 'right' then
		reference_coordinate[1] = loc_origin[1] + (width - hori_off)
		reference_coordinate[2] = loc_origin[2]
		if vert == false then
			left_rp[1] = reference_coordinate[1] - handle_length
			left_rp[2] = reference_coordinate[2]
			right_rp[1] = reference_coordinate[1]
			right_rp[2] = reference_coordinate[2]
		end
	elseif h_posi_code == 'center' then
		reference_coordinate[1] = loc_origin[1] + 0.5 * width
		reference_coordinate[2] = loc_origin[2]
		if vert == false then
			left_rp[1] = reference_coordinate[1] - 0.5 * handle_length
			left_rp[2] = reference_coordinate[2]
			right_rp[1] = reference_coordinate[1] + 0.5 * handle_length
			right_rp[2] = reference_coordinate[2]
		end
	else 
		reference_coordinate[1] = loc_origin[1] + hori_off
		reference_coordinate[2] = loc_origin[2]
		if vert == false then
			left_rp[1] = reference_coordinate[1]
			left_rp[2] = reference_coordinate[2]
			right_rp[1] = reference_coordinate[1] + handle_length
			right_rp[2] = reference_coordinate[2]
		end
	end

	if vert == true then 
		left_rp[1] = reference_coordinate[1]
		left_rp[2] = reference_coordinate[2]
		right_rp[1] = reference_coordinate[1]
		right_rp[2] = reference_coordinate[2]
	end
	
	if v_posi_code == 'top' then
		reference_coordinate[3] = loc_origin[3] + height - vert_off
		if vert == true then
			left_rp[3] = reference_coordinate[3]
			right_rp[3] = reference_coordinate[3] - handle_length 
		end
	elseif v_posi_code == 'center' then
		reference_coordinate[3] = loc_origin[3] + 0.5 * height
		if vert == true then
			left_rp[3] = reference_coordinate[3] + 0.5 * handle_length 
			right_rp[3] = reference_coordinate[3] - 0.5 * handle_length 
		end
	elseif v_posi_code == 'benchtop' then
		reference_coordinate[3] = general_data.benchtop_height - general_data.benchtop_thickness - base_origin[3] + vert_off
		if vert == true then
			left_rp[3] = reference_coordinate[3] + handle_length 
			right_rp[3] = reference_coordinate[3]
		end
	else 
		reference_coordinate[3] = loc_origin[3] + vert_off
		if vert == true then
			left_rp[3] = reference_coordinate[3] + handle_length 
			right_rp[3] = reference_coordinate[3]
		end
	end
	if vert == false then 
		left_rp[3] = reference_coordinate[3]
		right_rp[3] = reference_coordinate[3]
	end
		
	
	
	--this is so we do not have to treat any different cases  
	local main_dir = {right_rp[1] - left_rp[1], right_rp[2] - left_rp[2], right_rp[3] - left_rp[3]}
	main_dir[1] = main_dir[1] / handle_length
	main_dir[2] = main_dir[2] / handle_length
	main_dir[3] = main_dir[3] / handle_length
	

	local third_dir =  {main_dir[2] * perp_dir[3] - main_dir[3] * perp_dir[2], 
								main_dir[3] * perp_dir[1] - main_dir[1] * perp_dir[3], 
								main_dir[1] * perp_dir[2] - main_dir[2] * perp_dir[1]}
	
	--cylinder doesnt directly start at reference point, but shifted along main dir
	local cylinder_origin = {left_rp[1] - handle_over * main_dir[1], 
							left_rp[2] - handle_over * main_dir[2], 
							left_rp[3] - handle_over * main_dir[3]}

	local options = {u_axis = perp_dir, v_axis = third_dir, w_axis = main_dir}
	local handle_group = nil
	local grouping_table = {}
	if general_data.handle_type == 2 then
		handle_cyl = pytha.create_cylinder(total_length, diameter / 2, cylinder_origin, options)
		set_part_attributes(handle_cyl, "handle")
		pytha.delete_element_ref_point(handle_cyl)
			
		local block_origin = {	left_rp[1] - 0.5 * block_length * main_dir[1] - 0.5 * block_height * third_dir[1], 
								left_rp[2] - 0.5 * block_length * main_dir[2] - 0.5 * block_height * third_dir[2], 
								left_rp[3] - 0.5 * block_length * main_dir[3] - 0.5 * block_height * third_dir[3]}
		handle_block1 = pytha.create_block(depth, block_height, block_length, block_origin, options)
		set_part_attributes(handle_block1, "handle")
		block_origin[1] = block_origin[1] + handle_length * main_dir[1]
		block_origin[2] = block_origin[2] + handle_length * main_dir[2]
		block_origin[3] = block_origin[3] + handle_length * main_dir[3]
		handle_block2 = pytha.create_block(depth, block_height, block_length, block_origin, options)
		set_part_attributes(handle_block2, "handle")
		
		options = {w_axis = perp_dir, segments = 12}
		local bore_hole_origin1 = {left_rp[1] + (depth + general_data.door_thickness) * perp_dir[1], left_rp[2] + (depth + general_data.door_thickness) * perp_dir[2], left_rp[3]}
		local bore_hole_origin2 = {right_rp[1] + (depth + general_data.door_thickness) * perp_dir[1], right_rp[2] + (depth + general_data.door_thickness) * perp_dir[2], right_rp[3]}
		local handle_bore_hole1 = pytha.create_circle(bore_hole_diameter / 2, bore_hole_origin1, options)
		local handle_bore_hole2 = pytha.create_circle(bore_hole_diameter / 2, bore_hole_origin2, options)
		set_part_attributes(handle_bore_hole1, "bore_hole")
		set_part_attributes(handle_bore_hole2, "bore_hole")

		grouping_table = {handle_cyl, handle_block1, handle_block2, handle_bore_hole1, handle_bore_hole2}
		handle_group = pytha.create_group(grouping_table, {name = attribute_list["handle"].name})
		left_rp[1] = left_rp[1] + depth * (perp_dir[1])
		left_rp[2] = left_rp[2] + depth * (perp_dir[2])
		right_rp[1] = right_rp[1] + depth * (perp_dir[1])
		right_rp[2] = right_rp[2] + depth * (perp_dir[2])
		pytha.create_element_ref_point(handle_group, left_rp)
		pytha.create_element_ref_point(handle_group, right_rp)
		left_rp[1] = left_rp[1] + general_data.door_thickness * (perp_dir[1])
		left_rp[2] = left_rp[2] + general_data.door_thickness * (perp_dir[2])
		pytha.create_element_ref_point(handle_group, left_rp)
	elseif general_data.handle_type == 3 then
		options = {w_axis = perp_dir}
		local handle_cyl1 = pytha.create_cylinder(depth, diameter / 2, reference_coordinate, options)
		pytha.delete_element_ref_point(handle_cyl1)
		local handle_cyl2 = pytha.create_cylinder(knob_thickness, knob_diameter / 2, reference_coordinate, options)
		pytha.delete_element_ref_point(handle_cyl2)
		handle_cyl = pytha.boole_part_union({handle_cyl1, handle_cyl2})
		set_part_attributes(handle_cyl, "handle")
		
		options = {w_axis = perp_dir, segments = 12}
		local bore_hole_origin = {reference_coordinate[1] + (depth + general_data.door_thickness) * perp_dir[1], reference_coordinate[2] + (depth + general_data.door_thickness) * perp_dir[2], reference_coordinate[3]}
		local handle_bore_hole = pytha.create_circle(bore_hole_diameter / 2, bore_hole_origin, options)
		set_part_attributes(handle_bore_hole, "bore_hole")

		grouping_table = {handle_cyl, handle_bore_hole}
		handle_group = pytha.create_group(grouping_table, {name = attribute_list["handle"].name})
		left_rp[1] = reference_coordinate[1] + depth * (perp_dir[1])
		left_rp[2] = reference_coordinate[2] + depth * (perp_dir[2])
		left_rp[3] = reference_coordinate[3] 
		pytha.create_element_ref_point(handle_group, left_rp)
		
		pytha.create_element_ref_point(handle_group, bore_hole_origin)
	elseif general_data.handle_type == 4 and general_data.handle_file then
		load_handle(general_data, specific_data)
		
	else 
		return handle_group
	end
	
	
	return handle_group
end

 


-- Dropdown Door for e.g. Dishwasher 
function create_dropdown_door(general_data, specific_data, width, height, origin, ext_elements, base_origin)
	local door_thickness = general_data.door_thickness
	local door_height = height
	
	local h_posi_code = 'center'
	local v_posi_code = 'top'
	local vertical = false
	local door_key = "dropdown_door"

	new_elem = create_door_panel(general_data, width, general_data.door_thickness, door_height, loc_origin, door_key)

	local handle = create_handle(general_data, specific_data, origin, width, door_height, vertical, h_posi_code, v_posi_code, base_origin)
	local door_group = pytha.create_group({handle, new_elem}, {name = attribute_list[door_key].name})
	local elevation_elem = nil
	local plan_elem = nil
--	elevation_elem, plan_elem = create_doorline_tkh(general_data, specific_data, origin, width, door_height, door_rh)

	local rp_pos = {origin[1],
					origin[2] + door_thickness,
					origin[3] + door_height}

	if door_group ~= nil then
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = rp_pos[1] + width
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = origin[1]
		rp_pos[3] = origin[3]
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[3] = origin[3] + door_height
		if specific_data.this_type == "overhead_tkh" then
			rp_pos[3] = origin[3] + door_height
		end
		rp_pos[2] = rp_pos[2] - general_data.door_thickness
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = rp_pos[1] + width
		rp_pos[2] = origin[2] + door_thickness
		rp_pos[3] = origin[3]
		pytha.create_element_ref_point(door_group, rp_pos)
		door_group:set_element_attributes({action_string = "ROTATE(90,R3R5,R3S30)"})
	end

	table.insert(ext_elements, door_group)
--	table.insert(ext_elements, elevation_elem)
--	table.insert(ext_elements, plan_elem)
	return door_group
end


function create_lift_door_base(general_data, specific_data, width, height, origin, ext_elements, base_origin)
	local door_thickness = general_data.door_thickness
	local door_height = height
	
	local h_posi_code = 'center'
	local v_posi_code = 'bottom'
	local vertical = false
	local door_key = "lift_door"

	new_elem = create_door_panel(general_data, width, general_data.door_thickness, door_height, loc_origin, door_key)

	local handle = create_handle(general_data, specific_data, origin, width, door_height, vertical, h_posi_code, v_posi_code, base_origin)
	local door_group = pytha.create_group({handle, new_elem}, {name = attribute_list[door_key].name})
	local elevation_elem = nil
	local plan_elem = nil
--	elevation_elem, plan_elem = create_doorline_tkh(general_data, specific_data, origin, width, door_height, door_rh)

	local rp_pos = {origin[1],
					origin[2] + door_thickness,
					origin[3] + door_height}

	if door_group ~= nil then
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = rp_pos[1] + width
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = origin[1]
		rp_pos[3] = origin[3]
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[3] = origin[3] + door_height
		if specific_data.this_type == "overhead_tkh" then
			rp_pos[3] = origin[3] + door_height
		end
		rp_pos[2] = rp_pos[2] - general_data.door_thickness
		pytha.create_element_ref_point(door_group, rp_pos)
		rp_pos[1] = rp_pos[1] + width
		rp_pos[2] = origin[2] + door_thickness
		rp_pos[3] = origin[3]
		pytha.create_element_ref_point(door_group, rp_pos)
		door_group:set_element_attributes({action_string = "ROTATE(-75,R1R2,R1S30)"})
	end

	table.insert(ext_elements, door_group)
--	table.insert(ext_elements, elevation_elem)
--	table.insert(ext_elements, plan_elem)
	return door_group
end