

function exit_question(dialog, data)
	
	dialog:set_window_title(pyloc "Kitchen Wizard")

	dialog:create_standalone_label({1,2}, pyloc "Really exit Kitchen Wizard?")

	dialog:create_ok_button(1)
	dialog:create_cancel_button(2)
	dialog:equalize_column_widths({1,2})
end


function open_layer_dialog(data)

	pyui.run_modal_subdialog(layers_dialog, data)
	
end

 
local function pairs_sorted(attributes)	--sorting the entries alphabetically
	local a = {}
	for n in pairs(attributes) do
		table.insert(a, n) 
	end
	table.sort(a)
	local i = 0 
	local iter = function () 
	  i = i + 1
	  if a[i] == nil then return nil
	  else return a[i], attributes[a[i]]
	  end
	end
	return iter
end 

function layers_dialog(dialog, data)
	
	dialog:set_window_title(pyloc "Kitchen Element Settings")
	
	dialog:create_standalone_label({1,7}, pyloc "Layer range 0 to 256, 0: active layer")
	dialog:create_label(1, pyloc "Type", {align = "center"})
	dialog:create_label({2,3}, pyloc "Name", {align = "center"})
	dialog:create_label(4, pyloc "Layer", {align = "center"})
	dialog:create_label(5, pyloc "Pen", {align = "center"})
	dialog:create_label(6, pyloc "Linetype", {align = "center"})
--	dialog:create_label(7, pyloc "Material", {align = "center"})
	dialog:create_align({1,6})
	dialog:create_scrollable_group_box({1,7})
	for i, k in pairs_sorted(attribute_list) do
		local text = dialog:create_label(1, k.display_name)
		local name_list_values = pytha.get_attribute_list_values("name")
		local name = nil
		if #name_list_values > 0 then 
			name = dialog:create_combo_box({2,3}, k.name)
			name:reset_content()
			local current_sel = 0
			for j, l in pairs(name_list_values) do
				name:insert_control_item(l)
				if l == k.name then 
					current_sel = j
				end
			end
			if current_sel > 0 then 
				name:set_control_selection(current_sel)
			else 
				name:set_control_text(k.name)
			end 
		else 
			name = dialog:create_text_box({2, 3}, k.name)
		end

		local layer = dialog:create_text_box(4, pyui.format_number(k.layer))
		local pen = dialog:create_pen_list(5)
		pen:set_control_selection(k.pen)
		local linetype = dialog:create_linetype_list(6)
		linetype:set_control_selection(k.linetype)

--[[ 		local material = dialog:create_button(7, pyloc "none")
		if k.material then
			material:set_control_text(k.material:get_name())
		end ]]
		
--[[ 		material:set_on_click_handler(function(state)
			k.material = pyux.select_material(k.material)
			if k.material then
				material:set_control_text(k.material:get_name())
			else 
				material:set_control_text(pyloc "none")
			end
			recreate_all(data, true)
		end) ]]
		name:set_on_change_handler(function(text, new_index)
			if new_index ~= nil and text ~= nil then 
				local pos1 = string.find(text, ";")
				if pos1 ~= nil then 
				text = string.sub(text, 1, pos1 - 1)
				end
			end
			k.name = text or k.name
			recreate_all(data, true)
		end)
		layer:set_on_change_handler(function(text)
			k.layer = math.min(math.max(pyui.parse_number(text) or k.layer, 0), 256)
			recreate_all(data, true)
		end)
		pen:set_on_change_handler(function(text, new_index)
			k.pen = math.min(math.max(new_index or k.pen, 0), 256)
			recreate_all(data, true)
		end)
		linetype:set_on_change_handler(function(text, new_index)
			k.linetype = math.max(new_index or k.linetype, 0)
			recreate_all(data, true)
		end)
	end
	dialog:end_group_box()
	dialog:create_align({1,6})
	local ok = dialog:create_ok_button({5,6})
	dialog:equalize_column_widths({2,3,4,5,6})
	
end


function open_materials_dialog(data)

	pyui.run_modal_subdialog(materials_dialog, data)
	
end


function materials_dialog(dialog, data)
	
	dialog:set_window_title(pyloc "Materials")
	
	dialog:create_label(1, pyloc "Element type", {align = "center"})
	dialog:create_label({2,3}, pyloc "Material", {align = "center"})
	dialog:create_align({1,3})
--	dialog:create_group_box({1,3})
	for i, k in pairs_sorted(material_list) do
		local text = dialog:create_label(1, k.display_name)

		local material = dialog:create_button({2,3}, pyloc "none")
		if k.material then
			material:set_control_text(k.material:get_name())
		end
		
		material:set_on_click_handler(function(state)
		k.material = pyux.select_material(k.material)
		if k.material then
			material:set_control_text(k.material:get_name())
		else 
			material:set_control_text(pyloc "none")
		end
		recreate_all(data, true)
		end)
	end
--	dialog:end_group_box()
	dialog:create_align({1,3})
	local ok = dialog:create_ok_button(3)
	dialog:equalize_column_widths({1,2,3})
	
end

function open_further_settings_dialog(data)

	pyui.run_modal_subdialog(settings_dialog, data)
	
end

function settings_dialog(dialog, data)
	
	dialog:set_window_title(pyloc "General Settings")
	
	dialog:create_label(1, pyloc "Depth Base")
	local depth = dialog:create_text_box(2, pyui.format_length(data.depth))
	dialog:create_label(1, pyloc "Depth Wall")
	local depth_wall = dialog:create_text_box(2, pyui.format_length(data.depth_wall))
	dialog:create_label(1, pyloc "Base cabinet height")
	local general_height_base = dialog:create_text_box(2, pyui.format_length(data.general_height_base))
	dialog:create_label(1, pyloc "Splashback height")
	local wall_to_base_spacing = dialog:create_text_box(2, pyui.format_length(data.wall_to_base_spacing))
	dialog:create_label(1, pyloc "Max door width")
	local max_door_width = dialog:create_text_box(2, pyui.format_length(data.max_door_width))

	dialog:create_label(1, pyloc "Board thickness")
	local thickness = dialog:create_text_box(2, pyui.format_length(data.thickness))
	dialog:create_label(1, pyloc "Back thickness")
	local thickness_back = dialog:create_text_box(2, pyui.format_length(data.thickness_back))
	dialog:create_label(1, pyloc "Gaps")
	local gap = dialog:create_text_box(2, pyui.format_length(data.gap))
	
	dialog:create_label(3, pyloc "Horizontal Rail Width")
	local width_rail = dialog:create_text_box(4, pyui.format_length(data.width_rail))
	dialog:create_label(3, pyloc "Vertical Rail Width")
	local width_vertical_rail = dialog:create_text_box(4, pyui.format_length(data.width_vertical_rail))
	dialog:create_label(3, pyloc "Shelves Tolerance")
	local shelf_gap = dialog:create_text_box(4, pyui.format_length(data.shelf_gap))
	dialog:create_label(3, pyloc "Shelves Setback")
	local shelves_setback = dialog:create_text_box(4, pyui.format_length(data.setback_shelves))
	dialog:create_label(3, pyloc "Shelves Setback")
	local shelves_setback = dialog:create_text_box(4, pyui.format_length(data.setback_shelves))
	local button_create_symbols = dialog:create_check_box({3,4}, pyloc "Create Drawing Symbols")
	button_create_symbols:set_control_checked(data.drawing_symbols)
	dialog:create_align({1,4})
	dialog:create_group_box({1,2}, pyloc "Benchtop")
	dialog:create_label(1, pyloc "Benchtop Thickness")
	local bt_thick = dialog:create_text_box(2, pyui.format_length(data.benchtop_thickness))
	dialog:create_label(1, pyloc "Benchtop Protrusion")
	local bt_over = dialog:create_text_box(2, pyui.format_length(data.top_over))
	dialog:create_label(1, pyloc "Benchtop Gap")
	local bt_gap = dialog:create_text_box(2, pyui.format_length(data.top_gap))
	dialog:end_group_box()
	dialog:create_group_box({3,4}, pyloc "Kickboard")
	dialog:create_label(3, pyloc "Kickboard Thickness")
	local kb_thickness = dialog:create_text_box(4, pyui.format_length(data.kickboard_thickness))
	dialog:create_label(3, pyloc "Kickboard Setback")
	local kb_setback = dialog:create_text_box(4, pyui.format_length(data.kickboard_setback))
	dialog:create_label(3, pyloc "Kickboard Gap")
	local kb_margin = dialog:create_text_box(4, pyui.format_length(data.kickboard_margin))
	dialog:end_group_box()
	
	dialog:create_align({1,4})
	local layer_button = dialog:create_button({1,2}, pyloc "Element Names and Settings")

	local ok = dialog:create_ok_button({3,4})
	
	bt_thick:set_on_change_handler(function(text)
		data.benchtop_thickness = math.max(pyui.parse_length(text) or data.benchtop_thickness, 0)
		recreate_all(data, true)
	end)
	
	
	depth:set_on_change_handler(function(text)
		local old_general_depth = data.depth
		data.depth = math.max(pyui.parse_length(text) or data.depth, 0)
		for i,spec_data in pairs(data.cabinet_list) do
			if spec_data.depth == old_general_depth then
				spec_data.depth = data.depth
			end
			if spec_data.depth2 == old_general_depth then
				spec_data.depth2 = data.depth
			end
		end
		recreate_all(data, true)
	end)
	
	depth_wall:set_on_change_handler(function(text)
		local old_general_depth = data.depth_wall
		data.depth_wall = math.max(pyui.parse_length(text) or data.depth_wall, 0)
		for i,spec_data in pairs(data.cabinet_list) do
			if spec_data.depth == old_general_depth then
				spec_data.depth = data.depth_wall
			end
			if spec_data.depth2 == old_general_depth then
				spec_data.depth2 = data.depth_wall
			end
		end
		recreate_all(data, true)
	end)
	general_height_base:set_on_change_handler(function(text)
		local old_general_height_base = data.general_height_base
		data.general_height_base = math.max(pyui.parse_length(text) or data.general_height_base, 0)
		for i,spec_data in pairs(data.cabinet_list) do
			if spec_data.aux_values.row ~= 0x2 and spec_data.height == old_general_height_base then
				spec_data.height = data.general_height_base
			end
		end
		recreate_all(data, true)
	end)
	
	wall_to_base_spacing:set_on_change_handler(function(text)
		data.wall_to_base_spacing = math.max(pyui.parse_length(text) or data.wall_to_base_spacing, 0)
		recreate_all(data, true)
	end)
	
	max_door_width:set_on_change_handler(function(text)
		data.max_door_width = math.max(pyui.parse_length(text) or data.max_door_width, 0)
		recreate_all(data, true)
	end)


	bt_over:set_on_change_handler(function(text)
		data.top_over = math.max(pyui.parse_length(text) or data.top_over, 0)
		recreate_all(data, true)
	end)

	bt_gap:set_on_change_handler(function(text)
		data.top_gap = math.max(pyui.parse_length(text) or data.top_gap, 0)
		recreate_all(data, true)
	end)

	gap:set_on_change_handler(function(text)
		data.gap = math.max(pyui.parse_length(text) or data.gap, 0)
		recreate_all(data, true)
	end)
	
	thickness:set_on_change_handler(function(text)
		data.thickness = math.max(pyui.parse_length(text) or data.thickness, 0)
		recreate_all(data, true)
	end)
	
	thickness_back:set_on_change_handler(function(text)
		data.thickness_back = math.max(pyui.parse_length(text) or data.thickness_back, 0)
		recreate_all(data, true)
	end)
	
	kb_thickness:set_on_change_handler(function(text)
		data.kickboard_thickness = math.max(pyui.parse_length(text) or data.kickboard_thickness, 0)
		recreate_all(data, true)
	end)
	
	kb_setback:set_on_change_handler(function(text)
		data.kickboard_setback =pyui.parse_length(text) or data.kickboard_setback
		recreate_all(data, true)
	end)
	
	kb_margin:set_on_change_handler(function(text)
		data.kickboard_margin = math.max(pyui.parse_length(text) or data.kickboard_margin, 0)
		recreate_all(data, true)
	end)
	
	shelves_setback:set_on_change_handler(function(text)
		data.setback_shelves = math.max(pyui.parse_length(text) or data.setback_shelves, 0)
		recreate_all(data, true)
	end)
	
	width_rail:set_on_change_handler(function(text)
		data.width_rail = math.max(pyui.parse_length(text) or data.width_rail, 0)
		recreate_all(data, true)
	end)
	
	width_vertical_rail:set_on_change_handler(function(text)
		data.width_vertical_rail = math.max(pyui.parse_length(text) or data.width_vertical_rail, 0)
		recreate_all(data, true)
	end)
	
	shelf_gap:set_on_change_handler(function(text)
		data.shelf_gap = math.max(pyui.parse_length(text) or data.shelf_gap, 0)
		recreate_all(data, true)
	end)
	
	layer_button:set_on_click_handler(function() 
		open_layer_dialog(data)
	end)
	
	button_create_symbols:set_on_click_handler(function(state) 
		data.drawing_symbols = state
		recreate_all(data, true)
	end)
end



function open_handle_settings_dialog(data)

	pyui.run_modal_subdialog(handle_dialog, data)
	
end

function handle_dialog(dialog, data)
	local controls = {}
	dialog:set_window_title(pyloc "Handles and Panels")
	
	dialog:create_group_box({1,2}, pyloc "Handles")

	type_label = dialog:create_label(1, pyloc "Type")
	type_combo = dialog:create_drop_list(2)
	type_combo:reset_content()
	local current_number = 0
	type_combo:insert_control_item(pyloc "No Handle")
	type_combo:insert_control_item(pyloc "Handle")
	type_combo:insert_control_item(pyloc "Knob")
	type_combo:insert_control_item(pyloc "From library")
--	type_combo:insert_control_item(pyloc "Fingerpull")
	type_combo:set_control_selection(data.handle_type)

--	dialog:create_group_box({1,2}, pyloc "Doors")
	controls.ori_combo_label = dialog:create_label(1, pyloc "Handle orientation")
	controls.ori_combo = dialog:create_drop_list(2)
	controls.ori_combo:reset_content()
	local current_number = 0
	controls.ori_combo:insert_control_item(pyloc "Vertical")
	controls.ori_combo:insert_control_item(pyloc "Horizontal")
	controls.ori_combo:insert_control_item(pyloc "Horizontal, centered")
	
	controls.ori_combo:set_control_selection(data.handle_position)
--	dialog:end_group_box()
	
	dialog:create_group_box({1,2}, pyloc "Distance from edge")
	controls.handle_dist_vert_label = dialog:create_label(1, pyloc "Vertical")
	controls.handle_dist_vert = dialog:create_text_box(2, pyui.format_length(data.handle_dist_vert))
	controls.handle_dist_hori_label = dialog:create_label(1, pyloc "Horizontal")
	controls.handle_dist_hori = dialog:create_text_box(2, pyui.format_length(data.handle_dist_hori))
	dialog:end_group_box()

	controls.handle_length_label = dialog:create_label(1, pyloc "Handle length")
	controls.handle_length = dialog:create_text_box(2, pyui.format_length(data.handle_length))

	dialog:create_group_box({1,2}, pyloc "Handle from library")
	controls.handle_file = dialog:create_button({1,2}, pyloc "Browse")

	dialog:end_group_box()
	dialog:end_group_box()
	
	dialog:create_group_box({3,4}, pyloc "Front Panels")

	panel_type_label = dialog:create_label(3, pyloc "Type")
	panel_type_combo = dialog:create_drop_list(4)
	panel_type_combo:reset_content()
	for i, k in pairs(panel_options) do
		panel_type_combo:insert_control_item(k.name)
	end
	panel_type_combo:set_control_selection(math.max(1, math.min(data.panel_type, #panel_options)))

	controls.door_thickness_label = dialog:create_label(3, pyloc "Front Thickness")
	controls.door_thickness = dialog:create_text_box(4, pyui.format_length(data.door_thickness))
	controls.panel_frame_width_label = dialog:create_label(3, pyloc "Frame Width")
	controls.panel_frame_width = dialog:create_text_box(4, pyui.format_length(data.panel_frame_width))
	controls.panel_central_thickness_label = dialog:create_label(3, pyloc "Central panel thickness")
	controls.panel_central_thickness = dialog:create_text_box(4, pyui.format_length(data.panel_central_thickness))

	dialog:create_group_box({3,4}, pyloc "Panel from library")
	controls.panel_file = dialog:create_button({3,4}, pyloc "Browse")

	dialog:end_group_box()

	dialog:end_group_box()

	dialog:create_align({1,4})
	local ok = dialog:create_ok_button({3,4})
	dialog:equalize_column_widths({1, 2, 3, 4})

	
	panel_type_combo:set_on_change_handler(function(text, new_index)
		data.panel_type = new_index	
		if data.panel_type == 4 and data.default_folders.panel_folder == nil then 	--index in array in door_and_handle.
			browse_front(data)
		end
		update_handle_ui(data, controls)
		recreate_all(data, false)
	end)
	
	controls.door_thickness:set_on_change_handler(function(text)
		data.door_thickness = math.max(pyui.parse_length(text) or data.door_thickness, 0)
		recreate_all(data, true)
	end)
	
	controls.panel_frame_width:set_on_change_handler(function(text)
		data.panel_frame_width = math.max(pyui.parse_length(text) or data.panel_frame_width, 0)
		recreate_all(data, true)
	end)
	
	controls.panel_central_thickness:set_on_change_handler(function(text)
		data.panel_central_thickness = math.max(pyui.parse_length(text) or data.panel_central_thickness, 0)
		recreate_all(data, true)
	end)
	
	type_combo:set_on_change_handler(function(text, new_index)
		data.handle_type = new_index
		if data.handle_type == 4 and data.default_folders.handle_folder == nil then 
			browse_handle(data)
		end
		update_handle_ui(data, controls)
		recreate_all(data, true)
	end)
	controls.ori_combo:set_on_change_handler(function(text, new_index)
		data.handle_position = new_index
		recreate_all(data, true)
	end)
	controls.handle_length:set_on_change_handler(function(text)
		data.handle_length = math.max(pyui.parse_length(text) or data.handle_length, 0)
		recreate_all(data, true)
	end)
	controls.handle_dist_vert:set_on_change_handler(function(text)
		data.handle_dist_vert = math.max(pyui.parse_length(text) or data.handle_dist_vert, 0)
		recreate_all(data, true)
	end)
	controls.handle_dist_hori:set_on_change_handler(function(text)
		data.handle_dist_hori = math.max(pyui.parse_length(text) or data.handle_dist_hori, 0)
		recreate_all(data, true)
	end)
	
	controls.handle_file:set_on_click_handler(function(state)
		browse_handle(data)
		update_handle_ui(data, controls)
		recreate_all(data, false)
	end)
	
	controls.panel_file:set_on_click_handler(function(state)
		browse_front(data)
		update_handle_ui(data, controls)
		recreate_all(data, false)
	end)

	update_handle_ui(data, controls)
end

function browse_handle(data)
	local result_path = pyux.select_pyo(data.default_folders.handle_folder)
	if result_path ~= nil then 
		data.default_folders.handle_folder = result_path
	end
end
function browse_front(data)
	local result_path = pyux.select_pyo(data.default_folders.panel_folder)
	if result_path ~= nil then 
		data.default_folders.panel_folder = result_path
	end
end

function update_handle_ui(data, controls)
	controls.panel_file:disable_control()
	controls.door_thickness_label:enable_control()
	controls.door_thickness:enable_control()
	if data.panel_type == 1 then 
		controls.panel_frame_width_label:disable_control()
		controls.panel_frame_width:disable_control()
		controls.panel_central_thickness_label:disable_control()
		controls.panel_central_thickness:disable_control()
	elseif data.panel_type == 4 then 
		controls.panel_file:enable_control()
		controls.panel_frame_width_label:disable_control()
		controls.panel_frame_width:disable_control()
		controls.panel_central_thickness_label:disable_control()
		controls.panel_central_thickness:disable_control()
		controls.door_thickness_label:disable_control()
		controls.door_thickness:disable_control()
		--now update the front thickness
		local panel_group = nil
		local panel_parts = nil
		if data.panel_type == 4 and data.default_folders.panel_folder then
			depth = 0
			panel_group, ref_point_coos, panel_parts = load_front_panel(data, 600, 600)
			if panel_group == nil or ref_point_coos == nil then return end
			if #ref_point_coos > 3 then 
				data.door_thickness = PYTHAGORAS(ref_point_coos[4][1] - ref_point_coos[1][1], ref_point_coos[4][2] - ref_point_coos[1][2], ref_point_coos[4][3] - ref_point_coos[1][3])
			end
			pytha.delete_element(panel_parts)
			controls.door_thickness:set_control_text(pyui.format_length(data.door_thickness)) 
		end

	else 
		controls.panel_frame_width_label:enable_control()
		controls.panel_frame_width:enable_control()
		controls.panel_central_thickness_label:enable_control()
		controls.panel_central_thickness:enable_control()
	end
	controls.handle_file:disable_control()
	controls.handle_dist_hori_label:disable_control()
	controls.handle_dist_hori:disable_control()
	controls.handle_dist_vert_label:disable_control()
	controls.handle_dist_vert:disable_control()
	controls.handle_length_label:disable_control()
	controls.handle_length:disable_control()
	controls.ori_combo_label:disable_control()
	controls.ori_combo:disable_control()
	if data.handle_type == 2 then 
		controls.handle_dist_hori_label:enable_control()
		controls.handle_dist_hori:enable_control()
		controls.handle_dist_vert_label:enable_control()
		controls.handle_dist_vert:enable_control()
		controls.handle_length_label:enable_control()
		controls.handle_length:enable_control()
		controls.ori_combo_label:enable_control()
		controls.ori_combo:enable_control()
	elseif data.handle_type == 3 then 
		controls.handle_dist_hori_label:enable_control()
		controls.handle_dist_hori:enable_control()
		controls.handle_dist_vert_label:enable_control()
		controls.handle_dist_vert:enable_control()
		controls.ori_combo_label:enable_control()
		controls.ori_combo:enable_control()
	elseif data.handle_type == 4 then 
		controls.handle_file:enable_control()
		controls.handle_dist_hori_label:enable_control()
		controls.handle_dist_hori:enable_control()
		controls.handle_dist_vert_label:enable_control()
		controls.handle_dist_vert:enable_control()
		controls.ori_combo_label:enable_control()
		controls.ori_combo:enable_control()

	end
	local handle_name = pyloc "Browse"
	if data.default_folders.handle_folder ~= nil then 
		handle_name = data.default_folders.handle_folder:get_name()
		handle_name = string.sub(handle_name, 1, -5)	--remove the last four characters (".pyo").
	end
	controls.handle_file:set_control_text(handle_name)

	local panel_name = pyloc "Browse"
	if data.default_folders.panel_folder ~= nil then 
		panel_name = data.default_folders.panel_folder:get_name()
		panel_name = string.sub(panel_name, 1, -5)	--remove the last four characters (".pyo").
	end
	controls.panel_file:set_control_text(panel_name)
end
