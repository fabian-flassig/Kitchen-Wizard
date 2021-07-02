--High cabinet with two doors



local function recreate_high(general_data, specific_data)
	
	specific_data.elem_handle_for_top = nil
	
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local base_height = general_data.benchtop_height - general_data.general_height_base - general_data.benchtop_thickness
	local height = specific_data.height_top - base_height
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local carcass_depth = specific_data.depth - door_to_carcass
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local carcass_elements = {}
	local cur_elements = {}
	local new_elem = nil
	local door_height1 = specific_data.height - general_data.top_gap
	local door_height2 = height - door_height1 - general_data.gap
	local shelf_depth = calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)

	recreate_carcass_base(general_data, specific_data, base_height, height, specific_data.width, carcass_depth, coordinate_system, carcass_elements)
	--Back
	recreate_back(general_data, specific_data, height, specific_data.width, carcass_depth, base_height, carcass_elements)
	
	--Front
	
	front_style_info = organization_style_list[specific_data.front_style]
	if type(front_style_info.geometry_function) == "table" then --this allows for split fronts
		--fixed_shelf
		loc_origin[1] = 0
		loc_origin[2] = door_to_carcass
		loc_origin[3] = base_height + specific_data.height - general_data.thickness
		new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
		table.insert(carcass_elements, new_elem)
		local index = 1
		recreate_basic_front(general_data, specific_data, base_height, specific_data.height, specific_data.width, shelf_depth, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)
		index = 2
		recreate_basic_front(general_data, specific_data, base_height + specific_data.height, specific_data.height_top - base_height - specific_data.height, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)
	elseif type(front_style_info.geometry_function) == "function" then
		recreate_basic_front(general_data, specific_data, base_height, specific_data.height_top - base_height, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0})
	end

	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)

	--Kickboard
	create_straight_kickboard(general_data, specific_data, base_height, specific_data.width, cur_elements)
	recreate_plan_details_base(general_data, specific_data, cur_elements)
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end
local function recreate_high_appl1(general_data, specific_data)
	
	specific_data.elem_handle_for_top = nil
	
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local base_height = general_data.benchtop_height - general_data.general_height_base - general_data.benchtop_thickness
	local height = specific_data.height_top - base_height
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local carcass_depth = specific_data.depth - door_to_carcass
	specific_data.groove_dist = specific_data.depth2
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local carcass_elements = {}
	local cur_elements = {}
	local new_elem = nil
	local door_height1 = specific_data.height - general_data.top_gap
	local door_height2 = height - door_height1 - general_data.gap
	local shelf_depth = calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)

	recreate_carcass_base(general_data, specific_data, base_height, height, specific_data.width, carcass_depth, coordinate_system, carcass_elements)
	
	--Oven
	loc_origin[1] = general_data.gap
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height + specific_data.height
	local oven_width = 0
	local oven_height = 0
	if specific_data.appliance_file then 
		loaded_oven, oven_width, oven_height = create_oven_with_blind(general_data, specific_data, specific_data.appliance_file, loc_origin, shelf_depth, cur_elements, carcass_elements, "bottom")

	end 
	local oven_top_pos = base_height + specific_data.height + oven_height
	--fixed_shelf
	loc_origin[1] = 0
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
	table.insert(carcass_elements, new_elem)
	loc_origin[3] = oven_top_pos + (general_data.gap - general_data.thickness) / 2
	new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
	table.insert(carcass_elements, new_elem)

	local base_top_back = loc_origin[3]
	--Lower Back
	recreate_back(general_data, specific_data, specific_data.height, specific_data.width, carcass_depth, base_height, carcass_elements)
	--Upper Back
	recreate_back(general_data, specific_data, specific_data.height_top - base_top_back, specific_data.width, carcass_depth, base_top_back, carcass_elements, true)

	--Front
	local index = 1
	recreate_basic_front(general_data, specific_data, base_height, specific_data.height, specific_data.width, shelf_depth, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)
	index = 2
	local top_front_base = oven_top_pos + general_data.gap
	recreate_basic_front(general_data, specific_data, top_front_base, specific_data.height_top - top_front_base, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)

	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)

	--Kickboard
	create_straight_kickboard(general_data, specific_data, base_height, specific_data.width, cur_elements)
	recreate_plan_details_base(general_data, specific_data, cur_elements)
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end
local function recreate_high_appl2(general_data, specific_data)
	
	specific_data.elem_handle_for_top = nil
	
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local base_height = general_data.benchtop_height - general_data.general_height_base - general_data.benchtop_thickness
	local height = specific_data.height_top - base_height
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local carcass_depth = specific_data.depth - door_to_carcass
	specific_data.groove_dist = specific_data.depth2
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local carcass_elements = {}
	local cur_elements = {}
	local new_elem = nil
	local door_height1 = specific_data.height - general_data.top_gap
	local shelf_depth = calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)

	recreate_carcass_base(general_data, specific_data, base_height, height, specific_data.width, carcass_depth, coordinate_system, carcass_elements)
	
	--Oven
	loc_origin[1] = general_data.gap
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height + specific_data.height
	local oven_width = 0
	local oven_height = 0
	if specific_data.appliance_file then 
		loaded_oven, oven_width, oven_height = create_oven_with_blind(general_data, specific_data, specific_data.appliance_file, loc_origin, shelf_depth, cur_elements, carcass_elements, "bottom")
	end 
	--fixed_shelf
	loc_origin[1] = 0
	loc_origin[2] = general_data.setback_fixed_shelves
	loc_origin[3] = base_height + specific_data.height - general_data.thickness
	new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
	table.insert(carcass_elements, new_elem)
	loc_origin[3] = base_height + specific_data.height + oven_height + (general_data.gap - general_data.thickness) / 2
	new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
	table.insert(carcass_elements, new_elem)
	--Microwave
	local microwave_bottom = base_height + specific_data.height + oven_height + general_data.top_gap
	loc_origin[1] = general_data.gap
	loc_origin[2] = door_to_carcass
	loc_origin[3] = microwave_bottom
	local microwave_height = 0
	if specific_data.appliance_file2 then 
		loaded_oven, oven_width, microwave_height = create_oven_with_blind(general_data, specific_data, specific_data.appliance_file2, loc_origin, shelf_depth, cur_elements, carcass_elements, "bottom")
	end 
	loc_origin[3] = microwave_bottom + microwave_height + (general_data.gap - general_data.thickness) / 2
	new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
	table.insert(carcass_elements, new_elem)
	

	local base_top_back = loc_origin[3]
	--Lower Back
	recreate_back(general_data, specific_data, specific_data.height, specific_data.width, carcass_depth, base_height, carcass_elements)
	--Upper Back
	recreate_back(general_data, specific_data, specific_data.height_top - base_top_back, specific_data.width, carcass_depth, base_top_back, carcass_elements, true)

	--Front
	local index = 1
	recreate_basic_front(general_data, specific_data, base_height, specific_data.height, specific_data.width, shelf_depth, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)
	index = 2
	recreate_basic_front(general_data, specific_data, base_top_back, specific_data.height_top - base_top_back, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)

	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)

	--Kickboard
	create_straight_kickboard(general_data, specific_data, base_height, specific_data.width, cur_elements)
	recreate_plan_details_base(general_data, specific_data, cur_elements)
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end

local function recreate_high_fridge(general_data, specific_data)
	
	specific_data.elem_handle_for_top = nil
	
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local base_height = general_data.benchtop_height - general_data.general_height_base - general_data.benchtop_thickness
	local height = specific_data.height_top - base_height
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local carcass_depth = specific_data.depth - door_to_carcass
	specific_data.groove_dist = specific_data.depth2
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local carcass_elements = {}
	local cur_elements = {}
	local new_elem = nil
	local door_height1 = 0
	local lower_door_exists = false
	local upper_door_exists = false
	local shelf_depth = calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)

	local carcass_handles = recreate_carcass_base(general_data, specific_data, base_height, height, specific_data.width, carcass_depth, coordinate_system, carcass_elements)

	local front_style_info = nil
	front_style_info = organization_style_list[specific_data.front_style]
	if specific_data.front_style and type(front_style_info.geometry_function) == "table" and front_style_info.geometry_function[1] ~= nil then
		lower_door_exists = true 
		door_height1 = specific_data.width2
	end
	if specific_data.front_style and type(front_style_info.geometry_function) == "table" and front_style_info.geometry_function[2] ~= nil then
		upper_door_exists = true 
	end
	--Fridge
	loc_origin[1] = general_data.gap
	loc_origin[2] = 0
	loc_origin[3] = 0
	local fridge_type = "one_door"
	local fridge_base_height = base_height + general_data.thickness
	local fridge_width = 0
	local fridge_height = 0
	local fridge_bottom = base_height
	local fridge_door_height = 0
	local freezer_height = 0
	local freezer_width = 0
	local gap_in_kickboard = false 
	local reference_points = {}
	local create_top_blind = 0
	if specific_data.appliance_file then 
		loaded_oven, fridge_width, fridge_height, reference_points = create_oven(general_data, specific_data, specific_data.appliance_file, {0,0,0}) --create oven works also for fridge except for 

		if #reference_points > 0 then 
			fridge_door_height = math.abs(reference_points[1][3] - reference_points[#reference_points][3])
		end
		if #reference_points > 3 then 
			freezer_height = math.abs(reference_points[4][3] - reference_points[3][3])
			freezer_width = math.abs(reference_points[4][1] - reference_points[3][1])
			fridge_type = "split_door"
			if freezer_width > freezer_height then 
				fridge_type = "side_by_side"
			end
		end
		if fridge_type == "split_door" and lower_door_exists == false then 
			fridge_base_height = general_data.benchtop_height - general_data.benchtop_thickness - freezer_height
			pytha.move_element(carcass_handles.bottom, {0,0, fridge_base_height - base_height - general_data.thickness})	--move the bottom board upwards for ventilation
		elseif lower_door_exists == true then 
			fridge_base_height = base_height + door_height1 + (general_data.gap + general_data.thickness) / 2
			fridge_bottom = base_height + door_height1 + general_data.gap
			gap_in_kickboard = true
		else 
			fridge_base_height = base_height + specific_data.groove_dist + general_data.thickness
			pytha.move_element(carcass_handles.bottom, {0,0, fridge_base_height - base_height - general_data.thickness})	--move the bottom board upwards for ventilation
		end


		if upper_door_exists == false then 
			local door_base = fridge_bottom
			if fridge_type == "split_door" then 
				door_base = fridge_base_height + freezer_height
			end
			fridge_door_height = specific_data.height_top - door_base

			create_top_blind = fridge_door_height - math.abs(reference_points[1][3] - reference_points[#reference_points][3])
		end

		if loaded_oven ~= nil then 
			table.insert(cur_elements, loaded_oven)
			pytha.move_element(loaded_oven, {(specific_data.width - fridge_width) / 2, 0, fridge_height + fridge_base_height})
		end
		if fridge_door_height > 0 then 
			local door_ori = {0,0,0}
			local backup_front_style = specific_data.front_style
			local backup_shelf_count = specific_data.shelf_count
			local backup_door_side = specific_data.door_rh
			specific_data.front_style = "single_door"
			specific_data.shelf_count = 0
			local door_base = fridge_bottom
			local door_width = specific_data.width
			local door_height = fridge_base_height + fridge_door_height - fridge_bottom
			if fridge_type == "split_door" then 
				door_base = fridge_base_height + freezer_height
				door_height = fridge_door_height
			elseif fridge_type == "side_by_side" then 
				specific_data.door_rh = true
				door_width = fridge_width - freezer_width + (specific_data.width - fridge_width + general_data.gap) / 2
				door_ori[1] = freezer_width + (specific_data.width - fridge_width - general_data.gap) / 2 
			end 
			recreate_basic_front(general_data, specific_data, door_base, door_height, door_width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, door_ori)	--top gap has to be included in height
			specific_data.front_style = backup_front_style
			specific_data.shelf_count = backup_shelf_count
			specific_data.door_rh = backup_door_side
		end
		if fridge_type == "split_door" or fridge_type == "side_by_side" then 
			local backup_front_style = specific_data.front_style
			local backup_shelf_count = specific_data.shelf_count
			local backup_door_side = specific_data.door_rh
			specific_data.front_style = "single_door"
			specific_data.shelf_count = 0
			local door_base = fridge_bottom
			local door_height = fridge_base_height + freezer_height - fridge_bottom
			local door_width = specific_data.width
			local top_gap = general_data.top_gap
			if fridge_type == "side_by_side" then 
				specific_data.door_rh = false
				door_width = freezer_width + (specific_data.width - fridge_width + general_data.gap) / 2
				door_height = fridge_base_height + fridge_door_height - fridge_bottom
				top_gap = 0
			end 
			recreate_basic_front(general_data, specific_data, door_base, door_height, door_width, shelf_depth, top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0})	--top gap has to be included in height
			specific_data.front_style = backup_front_style
			specific_data.shelf_count = backup_shelf_count
			specific_data.door_rh = backup_door_side
		end
	end 
	local fridge_top_pos = fridge_base_height + fridge_height

	if create_top_blind > 2 * general_data.thickness then
		loc_origin[1] = general_data.thickness
		loc_origin[2] = 0
		loc_origin[3] = fridge_top_pos
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin)
		set_part_attributes(new_elem, "inner_end")
		table.insert(carcass_elements, new_elem)
		loc_origin[3] = fridge_top_pos + general_data.thickness
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.thickness, create_top_blind - 2 * general_data.thickness, loc_origin)
		set_part_attributes(new_elem, "blind_panel")
		table.insert(carcass_elements, new_elem)
	elseif create_top_blind > general_data.thickness then
		loc_origin[1] = general_data.thickness
		loc_origin[2] = 0
		loc_origin[3] = fridge_top_pos
		new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.thickness, create_top_blind - general_data.thickness, loc_origin)
		set_part_attributes(new_elem, "blind_panel")
		table.insert(carcass_elements, new_elem)
	end
	--Lower Front
	local index = 1
	if lower_door_exists == true then 
		recreate_basic_front(general_data, specific_data, base_height, door_height1, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)
		--Lower Back
		recreate_back(general_data, specific_data, door_height1 + (general_data.gap + general_data.thickness) / 2, specific_data.width, carcass_depth, base_height, carcass_elements)
		
		--fixed_shelf
		loc_origin[1] = 0
		loc_origin[2] = door_to_carcass
		loc_origin[3] = base_height + door_height1 + (general_data.gap - general_data.thickness) / 2
		new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
		table.insert(carcass_elements, new_elem)

	end

	--Upper Front
	index = 2
	if upper_door_exists == true then 
		local top_front_base = fridge_top_pos + general_data.gap
		recreate_basic_front(general_data, specific_data, top_front_base, specific_data.height_top - top_front_base, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0}, index)
		--Upper Back
		recreate_back(general_data, specific_data, specific_data.height_top - fridge_top_pos, specific_data.width, carcass_depth, fridge_top_pos, carcass_elements, true)
		
		--fixed_shelf
		loc_origin[1] = 0
		loc_origin[2] = door_to_carcass
		loc_origin[3] = fridge_top_pos
		new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
		table.insert(carcass_elements, new_elem)
	end


	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)

	--Kickboard
	local kickboard_height = base_height
	if gap_in_kickboard == true then 
		kickboard_height = base_height - specific_data.groove_dist + general_data.kickboard_margin
	end
	create_straight_kickboard(general_data, specific_data, kickboard_height, specific_data.width, cur_elements)
	recreate_plan_details_base(general_data, specific_data, cur_elements)
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end

local function placement_high(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, specific_data.depth,0}
	specific_data.left_connection_point = {0, specific_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

local function ui_update_high(general_data, soft_update)

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if soft_update == false then 
		insert_specific_control(general_data, "width", nil)
		insert_specific_control(general_data, "height_top", nil)
		insert_specific_control(general_data, "depth", nil)
	end

end

local function ui_update_high_appl1(general_data, soft_update)
	ui_update_high(general_data, soft_update)
	
	if soft_update == true then return end

	insert_specific_control(general_data, "height", pyloc "Lower section height")

	insert_specific_control(general_data, "depth2", pyloc "Ventilation space")	--we use the depth2 edit for the additional groove depth! And assign a specific_data.groove_dist value within the geometry function.
	
	controls.appliance_model_label:show_control()
	controls.appliance_model_label:set_control_text(pyloc "Oven model")
	controls.appliance_model:show_control()

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	ovens_to_front_styles1(general_data, specific_data, false)
end

local function ui_update_high_fridge(general_data, soft_update)
	ui_update_high(general_data, soft_update)
	
	if soft_update == true then return end
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	--the height is only selectable if there is a section below and a section above the fridge.
	local front_style_info = nil
	front_style_info = organization_style_list[specific_data.front_style]
	if specific_data.front_style and type(front_style_info.geometry_function) == "table" and front_style_info.geometry_function[1] ~= nil then 
		insert_specific_control(general_data, "width2", pyloc "Lower section height")
	end
	
	insert_specific_control(general_data, "depth2", pyloc "Ventilation space") 	--we use the depth2 edit for the additional groove depth! And assign a specific_data.groove_dist value within the geometry function.

	controls.appliance_model_label:show_control()
	controls.appliance_model_label:set_control_text(pyloc "Fridge model")
	controls.appliance_model:show_control()

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	fridges_to_front_styles1(general_data, specific_data, false)

end
local function ui_update_high_appl2(general_data, soft_update)
	ui_update_high_appl1(general_data, soft_update)
	
	if soft_update == true then return end

	insert_specific_control(general_data, "height", pyloc "Lower section height")

	controls.appliance_model2_label:show_control()
	controls.appliance_model2_label:set_control_text(pyloc "Microwave model")
	controls.appliance_model2:show_control()

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	ovens_to_front_styles2(general_data, specific_data, false)

end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.high = 				
{									
	name = pyloc "High cabinet",
	row = 0x3,
	default_data = {width = 600,},
	geometry_function = recreate_high,
	placement_function = placement_high, 	
	ui_update_function = ui_update_high,
	organization_styles = {"split_drawers_intelli_doors", 
							"split_intelli_doors_doors",
							"intelli_doors"},
	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"top_solid",},
}
cabinet_typelist.high_appliance1 = 				
{									
	name = pyloc "High oven cabinet",
	row = 0x3,
	default_data = function(general_data, specific_data) specific_data.width = 600 
														specific_data.depth2 = 30 
														specific_data.appliance_file = general_data.default_folders.oven_folder  
														specific_data.appliance_file2 = general_data.default_folders.microwave_folder  
														specific_data.shelf_count = 1
														specific_data.drawer_count = 3 end,
	geometry_function = recreate_high_appl1,
	placement_function = placement_high, 	
	ui_update_function = ui_update_high_appl1,
	organization_styles = {"split_drawers_intelli_doors",
							"split_intelli_doors_doors"},
	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"top_solid",},
}
cabinet_typelist.high_appliance2 = 				
{									
	name = pyloc "High oven&microwave cabinet",
	row = 0x3,
	default_data = function(general_data, specific_data) specific_data.width = 600 
														specific_data.depth2 = 30 
														specific_data.appliance_file = general_data.default_folders.oven_folder  
														specific_data.appliance_file2 = general_data.default_folders.microwave_folder  
														specific_data.shelf_count = 1
														specific_data.drawer_count = 3 end,
	geometry_function = recreate_high_appl2,
	placement_function = placement_high, 	
	ui_update_function = ui_update_high_appl2,
	organization_styles = {"split_drawers_intelli_doors",
							"split_intelli_doors_doors"},
	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"top_solid",},
}
cabinet_typelist.high_fridge = 				
{									
	name = pyloc "High fridge cabinet",
	row = 0x3,
	default_data = function(general_data, specific_data) specific_data.width = 600 
														specific_data.depth2 = 30 
														specific_data.appliance_file = general_data.default_folders.fridge_folder  
														specific_data.shelf_count = 1
														specific_data.drawer_count = 3
														specific_data.width2 = 350 end,
	geometry_function = recreate_high_fridge,
	placement_function = placement_high, 	
	ui_update_function = ui_update_high_fridge,
	organization_styles = {"fridge_lift",
							"fridge_doors",
							"drawer_fridge",
							"doors_fridge",
							"drawer_fridge_lift",
							"drawer_fridge_doors",
							"doors_fridge_doors",
							"doors_fridge_lift",},	--To properly display the UI please use an organization style that is a table.
															--There is a section below and a section above the fridge. 
															--To emit one of the sections use the style nil.
	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal", },
	top_styles = {"top_solid",},
}


