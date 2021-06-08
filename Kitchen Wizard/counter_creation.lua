--Creating a counter desk in front of a kitchen

function open_counter_settings_dialog(data)

	pyui.run_modal_subdialog(counter_dialog, data)
	
end
function counter_dialog(dialog, data)
	dialog:set_window_title(pyloc "Counter")
	local controls = {}
	local button_counter_check = dialog:create_check_box({1,2}, pyloc "Create Counter")
	button_counter_check:set_control_checked(data.counter_settings.active)
	
	dialog:create_align({1,4})

	controls.type_label = dialog:create_label(1, pyloc "Shape")
	controls.type_combo = dialog:create_drop_list(2)
	controls.type_combo:reset_content()
	controls.type_combo:insert_control_item(pyloc "Back Board")
	controls.type_combo:insert_control_item(pyloc "L-Shape")
	controls.type_combo:insert_control_item(pyloc "Mitered L-Shape")
	controls.type_combo:insert_control_item(pyloc "Massive Block")
	controls.type_combo:insert_control_item(pyloc "Frame")
	controls.type_combo:set_control_selection(data.counter_settings.shape)

	controls.height_label = dialog:create_label(3, pyloc "Height")
	controls.height = dialog:create_text_box(4, pyui.format_length(data.counter_settings.height))
	controls.top_depth_label = dialog:create_label(1, pyloc "Counter top depth")
	controls.top_depth = dialog:create_text_box(2, pyui.format_length(data.counter_settings.top_depth))
	controls.top_thickness_label = dialog:create_label(1, pyloc "Counter top thickness")
	controls.top_thickness = dialog:create_text_box(2, pyui.format_length(data.counter_settings.top_thickness))
	controls.wall_thickness_label = dialog:create_label(1, pyloc "Counter wall thickness")
	controls.wall_thickness = dialog:create_text_box(2, pyui.format_length(data.counter_settings.wall_thickness))
	controls.top_benchtop_overlap_label = dialog:create_label(3, pyloc "Overlap with benchtop")
	controls.top_benchtop_overlap = dialog:create_text_box(4, pyui.format_length(data.counter_settings.top_benchtop_overlap))
	controls.overlap_left_label = dialog:create_label(3, pyloc "Protrusion on left")
	controls.overlap_left = dialog:create_text_box(4, pyui.format_length(data.counter_settings.overlap_left))
	controls.overlap_right_label = dialog:create_label(3, pyloc "Protrusion on right")
	controls.overlap_right = dialog:create_text_box(4, pyui.format_length(data.counter_settings.overlap_right))
	
	dialog:create_group_box({1,4}, pyloc "Section settings")
	controls.curve_radius = {}
	controls.curve_radius_label = {}
	controls.segments = {}
	controls.segments_label = {}
	for i = 1, #data.counter_settings.polygonal_settings.points - 1 do
		controls.curve_radius_label[i] = dialog:create_label(1, pyloc "Section" .. " " .. i .. " " .. pyloc "Radius")
		controls.curve_radius[i] = dialog:create_text_box(2, pyui.format_length(data.counter_settings.polygonal_settings.segments[i].radius))
		controls.segments_label[i] = dialog:create_label(3, pyloc "Segments")
		controls.segments[i] = dialog:create_text_box(4, pyui.format_number(data.counter_settings.polygonal_settings.segments[i].segments))
		controls.curve_radius[i]:set_on_change_handler(function(text, new_index)
			data.counter_settings.polygonal_settings.segments[i].radius = math.max(pyui.parse_length(text) or data.counter_settings.polygonal_settings.segments[i].radius, 0)
			recreate_counter_ui(data, controls)
		end)
		controls.segments[i]:set_on_change_handler(function(text, new_index)
			data.counter_settings.polygonal_settings.segments[i].segments = math.max(pyui.parse_length(text) or data.counter_settings.polygonal_settings.segments[i].segments, 0)
			recreate_counter_ui(data, controls)
		end)
	end

	dialog:end_group_box()

	dialog:create_align({1,4})
	local ok = dialog:create_ok_button({3,4})

	button_counter_check:set_on_click_handler(function(state)
		data.counter_settings.active = state
		recreate_counter_ui(data, controls)
	end)
	
	controls.type_combo:set_on_change_handler(function(text, new_index)
		data.counter_settings.shape = new_index
		recreate_counter_ui(data, controls)
	end)
	
	controls.height:set_on_change_handler(function(text)
		data.counter_settings.height = math.max(pyui.parse_length(text) or data.counter_settings.height, 0)
		recreate_counter_ui(data, controls)
	end)
	
	controls.top_thickness:set_on_change_handler(function(text)
		data.counter_settings.top_thickness = math.max(pyui.parse_length(text) or data.counter_settings.top_thickness, 0)
		recreate_counter_ui(data, controls)
	end)
	
	controls.wall_thickness:set_on_change_handler(function(text)
		data.counter_settings.wall_thickness = math.max(pyui.parse_length(text) or data.counter_settings.wall_thickness, 0)
		recreate_counter_ui(data, controls)
	end)
	
	controls.top_depth:set_on_change_handler(function(text)
		data.counter_settings.top_depth = math.max(pyui.parse_length(text) or data.counter_settings.top_depth, 0)
		recreate_counter_ui(data, controls)
	end)
	
	controls.top_benchtop_overlap:set_on_change_handler(function(text)
		data.counter_settings.top_benchtop_overlap = math.max(pyui.parse_length(text) or data.counter_settings.top_benchtop_overlap, 0)
		recreate_counter_ui(data, controls)
	end)
	
	controls.overlap_left:set_on_change_handler(function(text)
		data.counter_settings.overlap_left = math.max(pyui.parse_length(text) or data.counter_settings.overlap_left, 0)
		recreate_counter_ui(data, controls)
	end)
	
	controls.overlap_right:set_on_change_handler(function(text)
		data.counter_settings.overlap_right = math.max(pyui.parse_length(text) or data.counter_settings.overlap_right, 0)
		recreate_counter_ui(data, controls)
	end)
	update_counter_ui(data, controls)
end
function recreate_counter_ui(data, controls)
	update_counter_ui(data, controls)
	recreate_all(data, true)
end
function in_types(shape, ...)
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
       if shape == arg then return true end
    end
	return false
end
function update_counter_ui(data, controls)
	controls.type_label:enable_control(data.counter_settings.active)
	controls.type_combo:enable_control(data.counter_settings.active)
	controls.height_label:enable_control(data.counter_settings.active)
	controls.height:enable_control(data.counter_settings.active)
	controls.top_depth_label:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 2,3,4,5))
	controls.top_depth:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 2,3,4,5))
	controls.top_thickness_label:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 2,3,5))
	controls.top_thickness:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 2,3,5))
	controls.wall_thickness_label:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 1,2,3,4,5))
	controls.wall_thickness:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 1,2,3,4,5))
	controls.top_benchtop_overlap_label:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 2,4,5))
	controls.top_benchtop_overlap:enable_control(data.counter_settings.active and in_types(data.counter_settings.shape, 2,4,5))
	controls.overlap_left_label:enable_control(data.counter_settings.active)
	controls.overlap_left:enable_control(data.counter_settings.active)
	controls.overlap_right_label:enable_control(data.counter_settings.active)
	controls.overlap_right:enable_control(data.counter_settings.active)
	for i, k in ipairs(controls.curve_radius) do
		k:enable_control(data.counter_settings.active)
	end
	for i, k in ipairs(controls.curve_radius_label) do
		k:enable_control(data.counter_settings.active)
	end
	for i, k in ipairs(controls.segments) do
		k:enable_control(data.counter_settings.active)
	end
	for i, k in ipairs(controls.segments_label) do
		k:enable_control(data.counter_settings.active)
	end
end

function create_counter_geometry(data)
	local benchtop_elements = {}
	local counter_data = data.counter_settings
	local poly = counter_data.polygonal_settings
	local points = {}
	local segs = {}
	for i,k in pairs(poly.points) do
		points[i] = k
	end
	for i,k in pairs(poly.segments) do
		segs[i] = k
	end
	if counter_data.overlap_left > 0 then 
		local distance = PYTHAGORAS(points[2][1] - points[1][1], points[2][2] - points[1][2])
		local r = segs[1].radius
		local dir_parallel = {(points[2][1] - points[1][1]) / distance, (points[2][2] - points[1][2]) / distance}
		local dir_perp = {dir_parallel[2], -dir_parallel[1]}
		if r > 0 and distance / r / 2 < 1 then 
			local beta = ASIN(distance / r / 2)
			local alpha = ACOS((0.5 * distance + counter_data.overlap_left) / r)
			local seg_count = math.max(1, math.floor(segs[1].segments * (90 - alpha - beta) / beta / 2 + 0.5))
			local coords = {points[1][1] + dir_parallel[1] * (distance / 2 - r * COS(alpha)) + dir_perp[1] * r * (COS(beta) - SIN(alpha)),
							points[1][2] + dir_parallel[2] * (distance / 2 - r * COS(alpha)) + dir_perp[2] * r * (COS(beta) - SIN(alpha)),
							points[1][3]}
			table.insert(points, 1, {coords[1], coords[2], coords[3]})
			table.insert(segs, 1, {orientation = "cw", select_arc = "small", radius = r, segments = seg_count, normal = "z"})
		else 
			local coords = {points[1][1] - dir_parallel[1] * counter_data.overlap_left,
							points[1][2] + dir_parallel[2] * counter_data.overlap_left,
							points[1][3]}
			points[1] = coords	--no additional segments are created to give nicer results
--			table.insert(points, 1, {coords[1], coords[2], coords[3]})
--			table.insert(segs, 1, {})
		end		
	end
	if counter_data.overlap_right > 0 then 
		local distance = PYTHAGORAS(points[#points][1] - points[#points - 1][1], points[#points][2] - points[#points - 1][2])
		local r = segs[#points - 1].radius
		local dir_parallel = {(points[#points][1] - points[#points - 1][1]) / distance, (points[#points][2] - points[#points - 1][2]) / distance}
		local dir_perp = {dir_parallel[2], -dir_parallel[1]}
		if r > 0 and distance / r / 2 < 1 then 
			local beta = ASIN(distance / r / 2)
			local alpha = ACOS((0.5 * distance + counter_data.overlap_right) / r)
			local seg_count = math.max(1, math.floor(segs[#points - 1].segments * (90 - alpha - beta) / beta / 2 + 0.5))
		
			local coords = {points[#points][1] - dir_parallel[1] * (distance / 2 - r * COS(alpha)) + dir_perp[1] * r * (COS(beta) - SIN(alpha)),
							points[#points][2] - dir_parallel[2] * (distance / 2 - r * COS(alpha)) + dir_perp[2] * r * (COS(beta) - SIN(alpha)),
							points[#points][3]}
			table.insert(points, {coords[1], coords[2], coords[3]})
			table.insert(segs, #points - 1, {orientation = "cw", select_arc = "small", radius = r, segments = seg_count, normal = "z"})
		else 
			local coords = {points[#points][1] + dir_parallel[1] * counter_data.overlap_right,
							points[#points][2] + dir_parallel[2] * counter_data.overlap_right,
							points[#points][3]}
			points[#points] = coords
--			table.insert(points, {coords[1], coords[2], coords[3]})
--			table.insert(segs, #points - 1, {})
		end
	end
	local w_dir = {points[1][1] - points[2][1], points[1][2] - points[2][2], 0}
	local options = {w_axis = w_dir, v_axis = "z"}
	local w_dir2 = {points[#points - 1][1] - points[#points][1], points[#points - 1][2] - points[#points][2], 0}
	local options2 = {w_axis = w_dir2, v_axis = "z"}

	local distance = PYTHAGORAS(points[2][1] - points[1][1], points[2][2] - points[1][2])
	local r = segs[1].radius
	if r > 0 and distance / r / 2 < 1 then 
		local beta = ASIN(distance / r / 2)
		local dir_parallel = {(points[2][1] - points[1][1]) / distance, (points[2][2] - points[1][2]) / distance}
		local dir_perp = {dir_parallel[2], -dir_parallel[1]}
		local center1 = {points[1][1] + dir_parallel[1] * distance / 2 + dir_perp[1] * r * COS(beta), 
						points[1][2] + dir_parallel[2] * distance / 2 + dir_perp[2] * r * COS(beta), 
						points[1][3]}
		local true_dir_perp1 = {center1[1] - points[1][1], center1[2] - points[1][2], 0}
		options = {u_axis = true_dir_perp1, v_axis = "z"}
	end
	
	distance = PYTHAGORAS(points[#points][1] - points[#points - 1][1], points[#points][2] - points[#points - 1][2])
	r = segs[#points - 1].radius
	if r > 0 and distance / r / 2 < 1 then 
		beta = ASIN(distance / r / 2)
		dir_parallel = {(points[#points][1] - points[#points - 1][1]) / distance, (points[#points][2] - points[#points - 1][2]) / distance}
		dir_perp = {dir_parallel[2], -dir_parallel[1]}
		center2 = {points[#points][1] - dir_parallel[1] * distance / 2 + dir_perp[1] * r * COS(beta), 
						points[#points][2] - dir_parallel[2] * distance / 2 + dir_perp[2] * r * COS(beta), 
						points[#points][3]}
		local true_dir_perp2 = {center2[1] - points[#points][1], center2[2] - points[#points][2], 0}
		options2 = {u_axis = true_dir_perp2, v_axis = "z"}
	end

	local sweep = nil
--	local clean_line = pytha.create_polyline("open", points)	
	local line = pytha.create_polyline_ex("open", points, segs)	
	local cross_section = nil
	if counter_data.shape == 1 then --Back Board
		if counter_data.wall_thickness > 0 then 
			cross_section = pytha.create_polygon({{-counter_data.wall_thickness,0}, 
														{0,0}, 
														{0,counter_data.height}, 
														{-counter_data.wall_thickness,counter_data.height}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_wall")
			end
			pytha.delete_element(cross_section)
		end
	elseif counter_data.shape == 2 then --L-Shape
		if counter_data.wall_thickness > 0 then 
			cross_section = pytha.create_polygon({{-counter_data.wall_thickness, 0}, 
														{0, 0}, 
														{0, counter_data.height - counter_data.top_thickness}, 
														{-counter_data.wall_thickness, counter_data.height - counter_data.top_thickness}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_wall")
			end
			pytha.delete_element(cross_section)
		end
		if counter_data.top_thickness > 0 then 
			cross_section = pytha.create_polygon({{-counter_data.top_depth + counter_data.top_benchtop_overlap, counter_data.height - counter_data.top_thickness}, 
														{counter_data.top_benchtop_overlap, counter_data.height - counter_data.top_thickness}, 
														{counter_data.top_benchtop_overlap, counter_data.height}, 
														{-counter_data.top_depth + counter_data.top_benchtop_overlap, counter_data.height}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_top")
			end
			pytha.delete_element(cross_section)
		end
	elseif counter_data.shape == 3 then --Mitered L-Shape
		if counter_data.wall_thickness > 0 then 
			cross_section = pytha.create_polygon({{-counter_data.wall_thickness, 0}, 
														{0, 0}, 
														{0, counter_data.height}, 
														{-counter_data.wall_thickness, counter_data.height - counter_data.top_thickness}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_wall")
			end
			pytha.delete_element(cross_section)
		end
		if counter_data.top_thickness > 0 then 
			cross_section = pytha.create_polygon({{-counter_data.top_depth, counter_data.height - counter_data.top_thickness}, 
														{-counter_data.wall_thickness, counter_data.height - counter_data.top_thickness}, 
														{0, counter_data.height}, 
														{-counter_data.top_depth, counter_data.height}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_top")
			end
			pytha.delete_element(cross_section)
		end
	
	elseif counter_data.shape == 4 then --Massive Block
		if counter_data.height > data.benchtop_height then 
			cross_section = pytha.create_polygon({{-counter_data.top_depth + counter_data.top_benchtop_overlap, data.benchtop_height}, 
														{counter_data.top_benchtop_overlap, data.benchtop_height}, 
														{counter_data.top_benchtop_overlap, counter_data.height}, 
														{-counter_data.top_depth + counter_data.top_benchtop_overlap, counter_data.height}},
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_top")
			end
			pytha.delete_element(cross_section)
		end
		if counter_data.wall_thickness > 0 then 
			cross_section = pytha.create_polygon({{-counter_data.wall_thickness, 0}, 
														{0, 0}, 
														{0, data.benchtop_height}, 
														{-counter_data.wall_thickness, data.benchtop_height}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_wall")
			end
			pytha.delete_element(cross_section)
		end

	elseif counter_data.shape == 5 then --Frame, NEEDS WORK
		if counter_data.height > data.benchtop_height then 
			cross_section = pytha.create_polygon({{-counter_data.top_depth + counter_data.top_benchtop_overlap, counter_data.height - counter_data.top_thickness}, 
														{counter_data.top_benchtop_overlap, counter_data.height - counter_data.top_thickness}, 
														{counter_data.top_benchtop_overlap, counter_data.height}, 
														{-counter_data.top_depth + counter_data.top_benchtop_overlap, counter_data.height}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_top")
			end
			pytha.delete_element(cross_section)
		end
		local token = pytha.push_local_coordinates(points[1], options)
		local wall = pytha.create_block(-counter_data.top_depth, counter_data.height - counter_data.top_thickness, -counter_data.wall_thickness, {counter_data.top_benchtop_overlap,0,0})
		pytha.pop_local_coordinates(token)
		if wall ~= nil then 
			table.insert(benchtop_elements, wall)
			set_part_attributes(wall, "counter_wall")
		end
		token = pytha.push_local_coordinates(points[#points], options2)
		local wall2 = pytha.create_block(-counter_data.top_depth, counter_data.height - counter_data.top_thickness, counter_data.wall_thickness, {counter_data.top_benchtop_overlap,0,0})
		pytha.pop_local_coordinates(token)
		if wall2 ~= nil then 
			table.insert(benchtop_elements, wall2)
			set_part_attributes(wall2, "counter_wall")
		end
		if counter_data.wall_thickness > 0 then 
			cross_section = pytha.create_polygon({{-counter_data.wall_thickness, 0}, 
														{0, 0}, 
														{0, counter_data.height - counter_data.top_thickness}, 
														{-counter_data.wall_thickness, counter_data.height - counter_data.top_thickness}}, 
														points[1], options)
			sweep = pytha.create_sweep(line, cross_section)[1]
			wall = pytha.copy_element(wall, {0,0,0})[1]
			wall2 = pytha.copy_element(wall2, {0,0,0})[1]
			if sweep ~= nil and wall ~= nil and wall2 ~= nil then 
				sweep = pytha.boole_part_difference(sweep, {wall, wall2})
			end
			if sweep ~= nil then 
				table.insert(benchtop_elements, sweep)
				set_part_attributes(sweep, "counter_wall")
			end
			pytha.delete_element(cross_section)
		end
	end
	pytha.delete_element(line)
--	pytha.delete_element(clean_line)
	for i=1, #poly.segments - 1 do
		local bt_points = {}
		local bt_segs = {}
		bt_points[1] = {poly.points[i + 1][1], poly.points[i + 1][2], poly.points[i + 1][3]}
		bt_points[2] = {poly.points[i][1], poly.points[i][2], poly.points[i][3]}
		bt_segs[1] = {orientation = "ccw", select_arc = "small", radius = poly.segments[i].radius, segments = poly.segments[i].segments}
		bt_segs[2] = {}
		local bt_face = pytha.create_polygon_ex({{bt_points, bt_segs}}, {0, 0, data.benchtop_height - data.benchtop_thickness})
		if bt_face ~= nil then 
			local benchtop = pytha.create_profile(bt_face, data.benchtop_thickness)[1]
			if benchtop ~= nil then 
				set_part_attributes(benchtop, "benchtop")
				table.insert(data.benchtop, benchtop)
			end
			pytha.delete_element(bt_face)	
		end
	end
	if #benchtop_elements > 0 then 
		counter_data.main_group = pytha.create_group(benchtop_elements, {name = attribute_list["counter"].name})
	end
	if counter_data.main_group ~= nil then 
	table.insert(data.cur_elements, counter_data.main_group)
	end
end


  
