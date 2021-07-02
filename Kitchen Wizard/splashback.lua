--Creating a splashback

function open_splashback_settings_dialog(data)

	pyui.run_modal_subdialog(splashback_dialog, data)
	
end
function splashback_dialog(dialog, data)
	dialog:set_window_title(pyloc "Splashback")
	local controls = {}
	local button_splashback_check = dialog:create_check_box({1,2}, pyloc "Splashback")
	button_splashback_check:set_control_checked(data.splashback_settings.splashback)
	local button_wall_edging_check = dialog:create_check_box({3,4}, pyloc "Wall edging trim")
	button_wall_edging_check:set_control_checked(data.splashback_settings.wall_edging)
	
	dialog:create_align({1,4})

	controls.splashback_thickness_label = dialog:create_label(1, pyloc "Splashback thickness")
	controls.splashback_thickness = dialog:create_text_box(2, pyui.format_length(data.splashback_settings.splashback_thickness))
	controls.splashback_gap_label = dialog:create_label(1, pyloc "Gap to wall cabinets")
	controls.splashback_gap = dialog:create_text_box(2, pyui.format_length(data.splashback_settings.splashback_gap))
	
	controls.wall_edging_thickness_label = dialog:create_label(3, pyloc "Wall edging thickness")
	controls.wall_edging_thickness = dialog:create_text_box(4, pyui.format_length(data.splashback_settings.wall_edging_thickness))
	controls.wall_edging_height_label = dialog:create_label(3, pyloc "Wall edging height")
	controls.wall_edging_height = dialog:create_text_box(4, pyui.format_length(data.splashback_settings.wall_edging_height))

	dialog:create_align({1,4})
	local ok = dialog:create_ok_button({3,4})

	button_splashback_check:set_on_click_handler(function(state)
		data.splashback_settings.splashback = state
		recreate_splashback_ui(data, controls)
	end)

	button_wall_edging_check:set_on_click_handler(function(state)
		data.splashback_settings.wall_edging = state
		recreate_splashback_ui(data, controls)
	end)
	
	controls.splashback_thickness:set_on_change_handler(function(text)
		data.splashback_settings.splashback_thickness = math.max(pyui.parse_length(text) or data.splashback_settings.splashback_thickness, 0)
		recreate_splashback_ui(data, controls)
	end)
	
	controls.splashback_gap:set_on_change_handler(function(text)
		data.splashback_settings.splashback_gap = math.max(pyui.parse_length(text) or data.splashback_settings.splashback_gap, 0)
		recreate_splashback_ui(data, controls)
	end)
	
	controls.wall_edging_thickness:set_on_change_handler(function(text)
		data.splashback_settings.wall_edging_thickness = math.max(pyui.parse_length(text) or data.splashback_settings.wall_edging_thickness, 0)
		recreate_splashback_ui(data, controls)
	end)
	
	controls.wall_edging_height:set_on_change_handler(function(text)
		data.splashback_settings.wall_edging_height = math.max(pyui.parse_length(text) or data.splashback_settings.wall_edging_height, 0)
		recreate_splashback_ui(data, controls)
	end)
	update_splashback_ui(data, controls)
end
function recreate_splashback_ui(data, controls)
	update_splashback_ui(data, controls)
	recreate_all(data, true)
end
function in_types(shape, ...)
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
       if shape == arg then return true end
    end
	return false
end

function update_splashback_ui(data, controls)
	controls.splashback_thickness:enable_control(data.splashback_settings.splashback)
	controls.splashback_thickness_label:enable_control(data.splashback_settings.splashback)
	controls.splashback_gap:enable_control(data.splashback_settings.splashback)
	controls.splashback_gap_label:enable_control(data.splashback_settings.splashback)
	
	controls.wall_edging_thickness:enable_control(data.splashback_settings.wall_edging)
	controls.wall_edging_thickness_label:enable_control(data.splashback_settings.wall_edging)
	controls.wall_edging_height:enable_control(data.splashback_settings.wall_edging)
	controls.wall_edging_height_label:enable_control(data.splashback_settings.wall_edging)
end

function create_splashback_geometry(data, splashback_poly)
	
	local splashback_elements = {}
	local wall_edging_elements = {}
	for i, poly in ipairs(splashback_poly) do
		local cross_section = nil
		local w_dir = {poly[1][1] - poly[2][1], poly[1][2] - poly[2][2], 0}
		local options = {w_axis = w_dir, v_axis = "z"}

		local line = pytha.create_polyline("open", poly)
		local offset_we = 0
		local sb_thick = data.splashback_settings.splashback_thickness
		local sb_gap = data.splashback_settings.splashback_gap
		local we_height = data.splashback_settings.wall_edging_height
		local we_thick = data.splashback_settings.wall_edging_thickness
		if data.splashback_settings.wall_edging == true then
			offset_we = we_height
			cross_section = pytha.create_polygon({{0, 0}, {we_thick, 0}, {we_thick, we_height}, {0, we_height}}, 
													{poly[1][1], poly[1][2], data.benchtop_height}, options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(wall_edging_elements, sweep)
				set_part_attributes(sweep, "wall_edging_trim")
			end
			pytha.delete_element(cross_section)
		end
		if data.splashback_settings.splashback == true then

			cross_section = pytha.create_polygon({{0, 0}, {sb_thick, 0}, {sb_thick, data.wall_to_base_spacing - offset_we - sb_gap}, {0, data.wall_to_base_spacing - offset_we - sb_gap}}, 
													{poly[1][1], poly[1][2], data.benchtop_height + offset_we}, options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(splashback_elements, sweep)
				set_part_attributes(sweep, "splashback")
			end
			pytha.delete_element(cross_section)
		end


		pytha.delete_element(line)

	end
	if #splashback_elements > 0 then 
		sp_group = pytha.create_group(splashback_elements, {name = attribute_list["splashback"].name})
		if sp_group ~= nil then 
			table.insert(data.cur_elements, sp_group)
		end
	end
	if #wall_edging_elements > 0 then 
		we_group = pytha.create_group(wall_edging_elements, {name = attribute_list["wall_edging_trim"].name})
		if we_group ~= nil then 
			table.insert(data.cur_elements, we_group)
		end
	end

end


  
