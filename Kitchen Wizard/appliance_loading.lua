-- Functions for the sink, hob, oven, microwave appliace loading


function sink_geometry(general_data, specific_data, file_handle)
	--here the sink is loaded and placed. This function returns the loaded parts as a handle
		local loaded_parts = pytha.import_pyo(file_handle)
	
	if loaded_parts ~= nil then 
		if specific_data.sink_flipped == 1 then 
			pytha.mirror_element(loaded_parts, {0,0,0}, "x")
		end
		for i = #loaded_parts, 1, -1 do 
			local ref_point_coos = pytha.get_element_ref_point_coordinates(loaded_parts[i])
			if #ref_point_coos > 0 then 
				local left_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				local center_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				local right_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				if #ref_point_coos > 1 then
					center_point = {(ref_point_coos[1][1] + ref_point_coos[2][1]) / 2, 
									(ref_point_coos[1][2] + ref_point_coos[2][2]) / 2, 
									(ref_point_coos[1][3] + ref_point_coos[2][3]) / 2}
					right_point = {ref_point_coos[2][1], ref_point_coos[2][2], ref_point_coos[2][3]}
				end
				if specific_data.sink_flipped == 1 then 
					if specific_data.sink_position == 1 then 
						pytha.move_element(loaded_parts, {-right_point[1], -right_point[2], -right_point[3]}) 
					elseif specific_data.sink_position == 2 then 
						pytha.move_element(loaded_parts, {-center_point[1], -center_point[2], -center_point[3]}) 
					else
						pytha.move_element(loaded_parts, {-left_point[1], -left_point[2], -left_point[3]}) 
					end
				else 
					if specific_data.sink_position == 3 then 
						pytha.move_element(loaded_parts, {-right_point[1], -right_point[2], -right_point[3]}) 
					elseif specific_data.sink_position == 2 then 
						pytha.move_element(loaded_parts, {-center_point[1], -center_point[2], -center_point[3]}) 
					else
						pytha.move_element(loaded_parts, {-left_point[1], -left_point[2], -left_point[3]}) 
					end
				end
				break 
			end
		end
	end
	return loaded_parts
end

function create_sink(general_data, specific_data, file_handle)
	local loaded_parts = {}
	local parent_group = nil
	if file_handle then 
		loaded_parts = sink_geometry(general_data, specific_data, file_handle) 
		if loaded_parts == nil then return nil end
		parent_group = pytha.get_element_common_group(loaded_parts)
		for i,k in pairs(loaded_parts) do
			local name = pytha.get_element_attribute(k, "name")
			if string.find(string.lower(name), "template") ~= nil then
				table.insert(general_data.benchtop_templates, k)
			end
		end
		
		pytha.move_element(parent_group, {0.5 * specific_data.width * (specific_data.sink_position - 1), 0, general_data.benchtop_height})
	end
	return parent_group
end

function create_garbage_bin(general_data, specific_data, file_handle, bottom_inner_cormer)
	--here the garbage bin under the sink is loaded and placed. This function returns the loaded parts as a handle plus the height of the loaded unit

		local ref_point_coos = {}
		local loaded_parts = pytha.import_pyo(file_handle)
		if file_handle == nil then return nil, nil end
		local garbage_parent_group = pytha.get_element_common_group(loaded_parts)
		if garbage_parent_group ~= nil then 
			ref_point_coos = pytha.get_element_ref_point_coordinates(garbage_parent_group)
			if #ref_point_coos > 0 then 
				local left_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
				pytha.move_element(garbage_parent_group, {-left_point[1], -left_point[2], -left_point[3]}) 
				pytha.move_element(garbage_parent_group, bottom_inner_cormer)
			end
		end
		return garbage_parent_group, ref_point_coos
	end

function create_oven(general_data, specific_data, file_handle, top_left_corner)
--here the oven is loaded and placed. This function returns the loaded parts as a handle plus the height of the loaded unit
	local width = 0
	local height = 0
	local ref_point_coos = {}
	local loaded_parts = pytha.import_pyo(file_handle)
	if file_handle == nil then return nil, width, height end
	local oven_parent_group = pytha.get_element_common_group(loaded_parts)
	if oven_parent_group ~= nil then 
		ref_point_coos = pytha.get_element_ref_point_coordinates(oven_parent_group)
		if #ref_point_coos > 2 then 
			local left_point = {ref_point_coos[1][1], ref_point_coos[1][2], ref_point_coos[1][3]}
			local right_point = {ref_point_coos[2][1], ref_point_coos[2][2], ref_point_coos[2][3]}
			local bottom_point = {ref_point_coos[3][1], ref_point_coos[3][2], ref_point_coos[3][3]}
			width = PYTHAGORAS(right_point[1] - left_point[1], right_point[2] - left_point[2])
			height = PYTHAGORAS(bottom_point[3] - left_point[3])
			pytha.move_element(oven_parent_group, {-left_point[1], -left_point[2], -left_point[3]}) 
			pytha.move_element(oven_parent_group, top_left_corner)
		end
	end
	return oven_parent_group, width, height, ref_point_coos
end

function create_oven_with_blind(general_data, specific_data, appliance_file, origin, shelf_depth, cur_elements, carcass_elements, orientation)
--here the oven is loaded and placed. This function returns the loaded parts as a handle plus the height of the loaded unit
	local oven_width = 0
	local oven_height = 0
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}

	local oven_origin = {origin[1], origin[2], origin[3]}
	if appliance_file then 
		loaded_oven, oven_width, oven_height, ref_point_coos = create_oven(general_data, specific_data, appliance_file, origin) 
		if loaded_oven ~= nil then 
			table.insert(cur_elements, loaded_oven)
			pytha.move_element(loaded_oven, {(specific_data.width - oven_width) / 2, 0, 0})

			if orientation == "bottom" then 
				pytha.move_element(loaded_oven, {0, 0, oven_height})
			else 
				oven_origin[3] = origin[3] - oven_height
			end
			local token = pytha.push_local_coordinates(oven_origin, {u_axis = "x", v_axis = "y", w_axis = "z"})
			local loc_origin = {0,0,0}
			local blind_width = (specific_data.width - oven_width) / 2 - general_data.gap
			if oven_width < specific_data.width - 2 * general_data.thickness then 
				--Inner rail for oven
				
				loc_origin[1] = (specific_data.width - oven_width) / 2 - general_data.gap
				loc_origin[2] = 0
				loc_origin[3] = 0
				new_elem = pytha.create_block(general_data.thickness, 60, oven_height + general_data.top_gap, loc_origin)	--programatically set to 60.
				set_part_attributes(new_elem, "inner_end")
				table.insert(carcass_elements, new_elem)
				loc_origin[1] = specific_data.width - blind_width - general_data.thickness
				new_elem = pytha.create_block(general_data.thickness, 60, oven_height + general_data.top_gap, loc_origin)	--programatically set to 60.  
				set_part_attributes(new_elem, "inner_end")
				table.insert(carcass_elements, new_elem)
			end 
			if oven_width < specific_data.width - 2 * general_data.thickness then 
				local backup_front_style = specific_data.front_style
				local backup_drawer_count = specific_data.drawer_count
				specific_data.front_style = "blind"
				specific_data.drawer_count = 1
				loc_origin[1] = 0
				loc_origin[2] = 0
				loc_origin[3] = - general_data.thickness / 2 + general_data.gap
				recreate_basic_front(general_data, specific_data, 0, oven_height + general_data.thickness / 2 - general_data.gap, blind_width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, loc_origin)	--top gap has to be included in height
				
				loc_origin[1] = specific_data.width - blind_width 
				recreate_basic_front(general_data, specific_data, 0, oven_height + general_data.thickness / 2 - general_data.gap, blind_width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, loc_origin)	--top gap has to be included in height

				specific_data.front_style = backup_front_style
				specific_data.drawer_count = backup_drawer_count
				if blind_width > 2 * general_data.thickness then
					--Inner rail for blind
					
					loc_origin[1] = (specific_data.width - oven_width) / 2 - general_data.gap - general_data.thickness
					loc_origin[2] = 0
					loc_origin[3] = 0
					new_elem = pytha.create_block(general_data.thickness, 60, oven_height + general_data.top_gap, loc_origin)	--programatically set to 60.
					set_part_attributes(new_elem, "inner_end")
					table.insert(carcass_elements, new_elem)
					loc_origin[1] = specific_data.width - blind_width 
					new_elem = pytha.create_block(general_data.thickness, 60, oven_height + general_data.top_gap, loc_origin)	--programatically set to 60.  
					set_part_attributes(new_elem, "inner_end")
					table.insert(carcass_elements, new_elem)
				end 
			end
			pytha.pop_local_coordinates(token)
		end
	end 
	return loaded_oven, oven_width, oven_height, ref_point_coos
end


function appl_to_front_styles(general_data, specific_data, show_dialog, def_folder_key, text)

	local result_path = pyux.list_pyos(specific_data.appliance_file or general_data.default_folders[def_folder_key], show_dialog) or {}
	local selected_i = 0
	
	if show_dialog == true then		--only write the default folder when dialog is really being displayed. Otherwise list might get polluted the first time kitchen wizard is being run
		if #result_path > 0 then		
			general_data.default_folders[def_folder_key] = result_path[1]
		else
			general_data.default_folders[def_folder_key] = nil
		end
	else 
		selected_i = 1
	end
	specific_data.aux_values.appliance_list = {}
	table.insert(specific_data.aux_values.appliance_list, {name = text, 
													ui_function = nil, 
													file_handle = nil})
	for i,k in pairs(result_path) do
		local filename = k:get_name()
		filename = string.sub(filename, 1, -5)	--remove the last four characters (".pyo").
		table.insert(specific_data.aux_values.appliance_list, {name = filename,			--inserted with numeric key into general list of front styles. Values of old folders are not deleted...
													ui_function = nil, 
													file_handle = k})	--no problem to add the file handle to the table here...
	end
	table.insert(specific_data.aux_values.appliance_list, {name = pyloc "--Browse--",
													ui_function = appl_to_front_styles, 
													file_handle = nil,
													folder_key = def_folder_key,
													disp_text = text})
	for i,k in pairs(specific_data.aux_values.appliance_list) do 
		if specific_data.appliance_file and specific_data.appliance_file == k.file_handle then 
			selected_i = i
		end
	end
	if  #specific_data.aux_values.appliance_list > 2 and selected_i == 0 then 
		selected_i = 2
	end
	if selected_i == 0 then 
		selected_i = 1
	end
	specific_data.appliance_file = specific_data.aux_values.appliance_list[selected_i].file_handle
	return selected_i
end

function appl_to_front_styles2(general_data, specific_data, show_dialog, def_folder_key, text)

	local result_path = pyux.list_pyos(specific_data.appliance_file2 or general_data.default_folders[def_folder_key], show_dialog) or {}
	local selected_i = 0

	if show_dialog == true then		--only write the default folder when dialog is really being displayed. Otherwise list might get polluted the first time kitchen wizard is being run
		if #result_path > 0 then	
			general_data.default_folders[def_folder_key] = result_path[1]
		else
			general_data.default_folders[def_folder_key] = nil
		end
	else 
		selected_i = 1
	end
	specific_data.aux_values.appliance_list2 = {}
	table.insert(specific_data.aux_values.appliance_list2, {name = text, -- pyloc "No oven",
													ui_function = nil, 
													file_handle = nil})
	for i,k in pairs(result_path) do
		local filename = k:get_name()
		filename = string.sub(filename, 1, -5)	--remove the last four characters (".pyo").
		
		table.insert(specific_data.aux_values.appliance_list2, {name = filename,			--inserted with numeric key into general list of front styles. Values of old folders are not deleted...
													ui_function = nil, 
													file_handle = k})	--no problem to add the file handle to the table here...
	end
	table.insert(specific_data.aux_values.appliance_list2, {name = pyloc "--Browse--",
													ui_function = appl_to_front_styles2, 
													file_handle = nil,
													folder_key = def_folder_key,
													disp_text = text})

	for i,k in pairs(specific_data.aux_values.appliance_list2) do 
		if specific_data.appliance_file2 and specific_data.appliance_file2 == k.file_handle then 
			selected_i = i
		end
	end
	if  #specific_data.aux_values.appliance_list2 > 2 and selected_i == 0 then 
		selected_i = 2
	end
	if selected_i == 0 then 
		selected_i = 1
	end
	specific_data.appliance_file2 = specific_data.aux_values.appliance_list2[selected_i].file_handle
	
	return selected_i
end
