--User Interface generation and update

controls = {} --those are the controls mostly used within this file and not to be modified within a cabinet files
local specific_controls_styles = {} --those are globals for the ui update functions in the specific cabinet files
local main_dialog_handle = nil
local main_prev_control = nil
local control_list_for_specific_dialog = {}

function wizard_dialog(dialog, data)
	main_dialog_handle = dialog
	dialog:set_window_title(pyloc "Kitchen Wizard")
	
	dialog:create_label(1, pyloc "General settings")
	
	local button_ori = dialog:create_button({2,3}, pyloc "Pick origin and direction")
	local button_ori_left = dialog:create_check_box(4, pyloc "Orient leftwards")
	button_ori_left:set_control_checked(data.orient_leftwards)
	
	dialog:create_label(1, pyloc "Benchtop height")
	local bt_height = dialog:create_text_box(2, pyui.format_length(data.benchtop_height))
	dialog:create_label(1, pyloc "Wall cabinet height")
	local general_height_top = dialog:create_text_box(2, pyui.format_length(data.general_height_top))
	
	local handle_settings = dialog:create_button(3, pyloc "Handles and panels")
	local further_settings = dialog:create_button(4, pyloc "General settings")
	local counter_settings = dialog:create_button(3, pyloc "Counter")
	
	controls.specific_area_gb = dialog:create_group_box({1,4}, pyloc "This cabinet")
	main_prev_control = controls.specific_area_gb
	controls.typecombo_label = dialog:create_label(1, pyloc "Type")
	controls.typecombo = dialog:create_drop_list(2)
	controls.subtypecombo_label = dialog:create_label(1, pyloc "Organization")
	controls.subtypecombo = dialog:create_drop_list(2)
		
	controls.appliance_model_label = dialog:create_label(1, pyloc "Sink model")
	controls.appliance_model = dialog:create_drop_list(2)
	controls.appliance_model2_label = dialog:create_label(1, pyloc "Oven model")
	controls.appliance_model2 = dialog:create_drop_list(2)

	controls.button_details = dialog:create_button(1, pyloc "Cabinet details")
	
	dialog:end_group_box()

	
	dialog:create_group_box({1,4}, pyloc "Navigate in cabinets")
	
	controls.button_up = dialog:create_button(1, "\u{21D1}")
	controls.insert_top_left = dialog:create_button(2, pyloc "Insert top left")
	controls.insert_top = dialog:create_button(3, pyloc "Insert on top")
	controls.button_down = dialog:create_button(4, "\u{21D3}")
	
	local button_left = dialog:create_button(1, "\u{21D0}")
	local insert_left = dialog:create_button(2, pyloc "Insert on left")
	local insert_right = dialog:create_button(3, pyloc "Insert on right")
	local button_right = dialog:create_button(4, "\u{21D2}")
	
	dialog:create_align({1,4}) -- So that OK and Cancel will be in the same row
	local button_select = dialog:create_button(1, pyloc "Select Cabinet")
	
	controls.button_delete = dialog:create_button(2, pyloc "Delete This")
	controls.button_switch_left = dialog:create_button(3, pyloc "Switch with left")
	controls.button_switch_right = dialog:create_button(4, pyloc "Switch with right")
	dialog:end_group_box()
	
	dialog:create_ok_button(3)
	dialog:create_cancel_button(4)
	
	dialog:equalize_column_widths({1,2,3,4})
	
-------------------------------------------------------------------------------------------------------
--Here we set the dialog handlers
-------------------------------------------------------------------------------------------------------

	
	button_ori:set_on_click_handler(function()
		-- Pick in graphics
		button_ori:disable_control()
		local ret_wert = pyux.select_coordinate(false, pyloc "Pick origin")
		if ret_wert ~= nil then
			data.origin = ret_wert
			pyux.highlight_coordinate(ret_wert)
		end
		
		local ret_wert = pyux.select_coordinate(false, pyloc "Pick direction along wall")
		if ret_wert ~= nil then
			pyux.highlight_coordinate(ret_wert)
			data.direction = {ret_wert[1] - data.origin[1], ret_wert[2] - data.origin[2], ret_wert[3] - data.origin[3]}
			local dir_length = PYTHAGORAS(data.direction[1], data.direction[2], data.direction[3])
			data.direction[1] = data.direction[1] / dir_length
			data.direction[2] = data.direction[2] / dir_length
			data.direction[3] = data.direction[3] / dir_length
		else 

		end
		button_ori:enable_control()
		pyux.clear_highlights()
		recreate_all(data, true)
	end)
	
	
	button_ori_left:set_on_click_handler(function(state)
		data.orient_leftwards = state
		recreate_all(data, true)
	end)
	
	bt_height:set_on_change_handler(function(text)
		data.benchtop_height = math.max(pyui.parse_length(text) or data.benchtop_height, 0)
		recreate_all(data, true)
	end)

	general_height_top:set_on_change_handler(function(text)
		local old_general_height_top = data.general_height_top
		data.general_height_top = math.max(pyui.parse_length(text) or data.general_height_top, 0)
		for i,spec_data in pairs(data.cabinet_list) do
			if spec_data.row ~= 0x1 and spec_data.height_top == old_general_height_top then
				spec_data.height_top = data.general_height_top
			end
		end
		recreate_all(data, true)
	end)
	
	further_settings:set_on_click_handler(function() 
		open_further_settings_dialog(data)
	end)
	
	counter_settings:set_on_click_handler(function() 
		open_counter_settings_dialog(data)
	end)
	
	
	handle_settings:set_on_click_handler(function() 
		open_handle_settings_dialog(data)
	end)
	controls.button_details:set_on_click_handler(function() 
		open_specific_details_dialog(data)
	end)
----------------------------------------------------------------------
----------------------------------------------------------------------	


	controls.typecombo:set_on_change_handler(function(text, new_index)
		local cab_type = typecombolist[data.cabinet_list[data.current_cabinet].row][new_index]
		assign_cabinet_type(data, data.current_cabinet, cab_type)
		recreate_all(data, false)
	end)
	
	controls.subtypecombo:set_on_change_handler(function(text, new_index)
		local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
		local front_style = spec_type_info.organization_styles[new_index]
		data.cabinet_list[data.current_cabinet].front_style = front_style
		recreate_all(data, false)
	end)
	
	controls.appliance_model:set_on_change_handler(function(text, new_index)
		local specific_data = data.cabinet_list[data.current_cabinet]
		if specific_data.appliance_list[new_index].ui_function then 
			new_index = specific_data.appliance_list[new_index].ui_function(data, specific_data, true)
		end
		specific_data.appliance_file = specific_data.appliance_list[new_index].file_handle
		recreate_all(data, true)
	end)
	
	controls.appliance_model2:set_on_change_handler(function(text, new_index)
		local specific_data = data.cabinet_list[data.current_cabinet]
		pyui.alert(new_index)
		if specific_data.appliance_list2[new_index].ui_function then 
			new_index = specific_data.appliance_list2[new_index].ui_function(data, specific_data, true)
		end
		specific_data.appliance_file2 = specific_data.appliance_list2[new_index].file_handle
		recreate_all(data, true)
	end)
	
----------------------------------------
----------------------------------------

	button_select:set_on_click_handler(function()
		if data.current_cabinet == 1 and #data.cabinet_list == 1 then
			return
		end
		button_select:disable_control()
		local sel_part = pyux.select_part(false)
		pyux.clear_highlights()	
		if sel_part ~= nil then
			for i,spec_data in pairs(data.cabinet_list) do 
				local all_parts = pytha.get_group_descendants(spec_data.main_group)
				for j, part in pairs(all_parts) do
					if sel_part[1] == part then
						data.current_cabinet = i
						button_select:enable_control()
						recreate_all(data, false)
						return
					end
				end
			end			
		end
		button_select:enable_control()
		recreate_all(data, false)
	end)
	controls.button_delete:set_on_click_handler(function() delete_element(data) end)
	controls.button_switch_left:set_on_click_handler(function() switch_with_left(data) end)
	controls.button_switch_right:set_on_click_handler(function() switch_with_right(data) end)
	
	button_left:set_on_click_handler(function(state) 
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			if data.cabinet_list[data.current_cabinet].left_top_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].left_top_element = new_element
				data.cabinet_list[new_element].right_top_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].left_top_element
		else
			if data.cabinet_list[data.current_cabinet].left_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].left_element = new_element
				data.cabinet_list[new_element].right_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].left_element
		end
		recreate_all(data, false)
	end)
	button_right:set_on_click_handler(function(state)
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			if data.cabinet_list[data.current_cabinet].right_top_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].right_top_element = new_element
				data.cabinet_list[new_element].left_top_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].right_top_element
		else
			if data.cabinet_list[data.current_cabinet].right_element == nil then
				local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
				data.cabinet_list[data.current_cabinet].right_element = new_element
				data.cabinet_list[new_element].left_element = data.current_cabinet
			end
			data.current_cabinet = data.cabinet_list[data.current_cabinet].right_element
		end
		recreate_all(data, false)
	end)
	insert_left:set_on_click_handler(function(state)
		local left_element = data.cabinet_list[data.current_cabinet].left_element
		local left_top_element = data.cabinet_list[data.current_cabinet].left_top_element
		local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			data.cabinet_list[new_element].right_top_element = data.current_cabinet
			data.cabinet_list[new_element].left_top_element = data.cabinet_list[data.current_cabinet].left_top_element
			if left_top_element ~= nil then
				data.cabinet_list[left_top_element].right_top_element = new_element
			end
			data.cabinet_list[data.current_cabinet].left_top_element = new_element
		else
			data.cabinet_list[new_element].right_element = data.current_cabinet
			data.cabinet_list[new_element].left_element = data.cabinet_list[data.current_cabinet].left_element
			if left_element ~= nil then
				data.cabinet_list[left_element].right_element = new_element
			end
			data.cabinet_list[data.current_cabinet].left_element = new_element
		end
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	insert_right:set_on_click_handler(function(state)
		local right_element = data.cabinet_list[data.current_cabinet].right_element
		local right_top_element = data.cabinet_list[data.current_cabinet].right_top_element
		local new_element = initialize_cabinet_values(data, typecombolist[data.cabinet_list[data.current_cabinet].row][1])
		if data.cabinet_list[data.current_cabinet].row == 0x2 then 
			data.cabinet_list[new_element].left_top_element = data.current_cabinet
			data.cabinet_list[new_element].right_top_element = data.cabinet_list[data.current_cabinet].right_top_element
			if right_top_element ~= nil then
				data.cabinet_list[right_top_element].left_top_element = new_element
			end
			data.cabinet_list[data.current_cabinet].right_top_element = new_element
		else
			data.cabinet_list[new_element].left_element = data.current_cabinet
			data.cabinet_list[new_element].right_element = data.cabinet_list[data.current_cabinet].right_element
			if right_element ~= nil then
				data.cabinet_list[right_element].left_element = new_element
			end
			data.cabinet_list[data.current_cabinet].right_element = new_element
		end
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	
	controls.button_up:set_on_click_handler(function() move_up(data) end)
	
	controls.button_down:set_on_click_handler(function() move_down(data) end)
	
	controls.insert_top:set_on_click_handler(function(state)
		local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
		if data.cabinet_list[data.current_cabinet].row == 0x3 then 
			data.cabinet_list[new_element].left_top_element = data.current_cabinet
			data.cabinet_list[data.current_cabinet].right_top_element = new_element
		else
			data.cabinet_list[new_element].bottom_element = data.current_cabinet
			data.cabinet_list[data.current_cabinet].top_element = new_element
		end
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	controls.insert_top_left:set_on_click_handler(function(state)
		local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
		data.cabinet_list[new_element].right_top_element = data.current_cabinet
		data.cabinet_list[data.current_cabinet].left_top_element = new_element
		data.current_cabinet = new_element
		recreate_all(data, false)
	end)
	
	recreate_all(data, false)
end

function recreate_all(data, soft_update)
	update_ui(data, soft_update)
	recreate_geometry(data, false)
end

function update_ui(data, soft_update)
	local specific_data = data.cabinet_list[data.current_cabinet]
	
	local spec_type_info = cabinet_typelist[specific_data.this_type]
	local front_style_info = nil
	if specific_data.front_style then 
		front_style_info = organization_style_list[specific_data.front_style]
	end
	local top_style_info = nil
	if specific_data.top_style then 
		top_style_info = organization_style_list[specific_data.top_style]
	end
	local bottom_style_info = nil
	if specific_data.bottom_style then
		bottom_style_info = bottom_style_list[specific_data.bottom_style]
	end
	local back_style_info = nil
	if specific_data.back_style then 
		back_style_info = back_style_list[specific_data.back_style]
	end

	
	
--just update the front controls state. This will be modified with the individual fronts.
	if soft_update == true then 
		spec_type_info.ui_update_function(data, soft_update)
		if front_style_info and front_style_info.ui_update_function then 
			front_style_info.ui_update_function(data, soft_update) 
		end
		if top_style_info and top_style_info.ui_update_function then 
			top_style_info.ui_update_function(data, soft_update) 
		end
		if bottom_style_info and bottom_style_info.ui_update_function  then 
			bottom_style_info.ui_update_function(data, soft_update) 
		end
		if back_style_info and back_style_info.ui_update_function  then 
			back_style_info.ui_update_function(data, soft_update) 
		end
		return
	end

--disable all controls and then just enable necessary ones
	for i, contr in pairs(controls) do
		contr:hide_control()
	end
	controls.specific_area_gb:show_control()
	main_prev_control = controls.specific_area_gb

	--these are always freshly generated as necessary by the specific cabinet files
	for i, contr in pairs(specific_controls_styles) do
		if contr.ctrl_id ~= nil then 
			contr.ctrl_id:delete_control() 
			contr.ctrl_id = nil
		end
		if contr.label_id ~= nil then 
			contr.label_id:delete_control()
			contr.label_id = nil 
		end
	end
	controls.appliance_model:reset_content()
	controls.appliance_model:reset_content()

	control_list_for_specific_dialog = {}
	

	spec_type_info.ui_update_function(data, soft_update)
	if front_style_info and front_style_info.ui_update_function then 
		front_style_info.ui_update_function(data, soft_update) 
	end
	if top_style_info and top_style_info.ui_update_function then 
		top_style_info.ui_update_function(data, soft_update) 
	end
	if bottom_style_info and bottom_style_info.ui_update_function  then 
		bottom_style_info.ui_update_function(data, soft_update) 
	end
	if back_style_info and back_style_info.ui_update_function  then 
		back_style_info.ui_update_function(data, soft_update) 
	end

--show the right arrow and insert buttons
	if specific_data.row == 0x3 then 
		controls.button_up:set_control_text(pyloc "Top" .. " \u{21D0}")
		controls.button_down:set_control_text(pyloc "Top" .. " \u{21D2}")
		controls.insert_top:set_control_text(pyloc "Insert top right")
		controls.insert_top_left:set_control_text(pyloc "Insert top left")
	else 
		controls.button_up:set_control_text("\u{21D1}")
		controls.button_down:set_control_text("\u{21D3}")
		controls.insert_top:set_control_text(pyloc "Insert top")
	end 
	if specific_data.row ~= 0x2 then
		controls.button_up:show_control()
	end
	
	if specific_data.row & 0x1 ~= 0 and specific_data.top_element == nil then
		controls.insert_top:show_control()
	end
	if specific_data.row == 0x3 then
		controls.insert_top_left:show_control()
		controls.button_down:show_control()
	end
	if specific_data.row & 0x1 == 0 then 
		controls.button_down:show_control()
	end
	
--on intention this is done before the comboboxes are refilled, otherwise a different file path will lead to a resizing in the width.	
	main_dialog_handle:update_dialog_layout()



--Cabinet type combo 	
	controls.typecombo:show_control()
	controls.typecombo_label:show_control()
	controls.typecombo:reset_content()
	local current_number = 0
	for i, k in pairs(typecombolist[specific_data.row]) do
		controls.typecombo:insert_control_item(cabinet_typelist[k].name)
		if k == specific_data.this_type then 
			current_number = i
		end 
	end
	controls.typecombo:set_control_selection(current_number)
	
	controls.button_details:show_control()

-- Front subtype combo 	
	if spec_type_info.organization_styles ~= nil and #spec_type_info.organization_styles > 0 then 
		controls.subtypecombo:show_control()
		controls.subtypecombo_label:show_control()
		
		controls.subtypecombo:reset_content()
		local current_front = 0
		for i, k in pairs(spec_type_info.organization_styles) do
			controls.subtypecombo:insert_control_item(organization_style_list[k].name)
			if k == specific_data.front_style then 
				current_front = i
			end 
		end
		controls.subtypecombo:set_control_selection(current_front)
	end
	
	-- Top subtype combo 
	if spec_type_info.top_styles ~= nil and #spec_type_info.top_styles > 0 then 
		insert_specific_control(data, "top_type", nil)
	end

	-- Bottom subtype combo 
	if spec_type_info.bottom_styles ~= nil and #spec_type_info.bottom_styles > 0 then
		insert_specific_control(data, "bottom_type", nil)
	end
	
	-- Back subtype combo 
	if spec_type_info.back_styles ~= nil and #spec_type_info.back_styles > 0 then 
		insert_specific_control(data, "back_type", nil)
	end

	--Appliance combo 1
	local selected_i = 1
	if #specific_data.appliance_list > 0 then
		for i,k in pairs(specific_data.appliance_list) do 
			controls.appliance_model:insert_control_item(k.name)
			if specific_data.appliance_file and specific_data.appliance_file == k.file_handle then 
				selected_i = i
			end
		end
		if selected_i == 1 then 
			specific_data.appliance_file = nil 
		end
		if  #specific_data.appliance_list > 2 and selected_i == 1 then 
			specific_data.appliance_file = specific_data.appliance_list[2].file_handle
			controls.appliance_model:set_control_selection(2)
			selected_i = 2
		else 
			specific_data.appliance_file = specific_data.appliance_list[selected_i].file_handle
			controls.appliance_model:set_control_selection(selected_i)
		end
	end
	
	--Appliance combo 2
	selected_i = 1
	if #specific_data.appliance_list2 > 0 then
		for i,k in pairs(specific_data.appliance_list2) do 
			controls.appliance_model2:insert_control_item(k.name)
			if specific_data.appliance_file2 and specific_data.appliance_file2 == k.file_handle then 
				selected_i = i
			end
		end
		if selected_i == 1 then 
			specific_data.appliance_file2 = nil 
		end
		if  #specific_data.appliance_list2 > 2 and selected_i == 1 then 
			specific_data.appliance_file2 = specific_data.appliance_list2[2].file_handle
			controls.appliance_model2:set_control_selection(2)
			selected_i = 2
		else 
			specific_data.appliance_file2 = specific_data.appliance_list2[selected_i].file_handle
			controls.appliance_model2:set_control_selection(selected_i)
		end
	end


	if specific_data.row == 0x1 then 
		if specific_data.left_element ~= nil then 
			controls.button_switch_left:show_control()
		end
		if specific_data.right_element ~= nil then 
			controls.button_switch_right:show_control()
		end
	elseif specific_data.row == 0x3 then 
		if specific_data.left_element ~= nil or specific_data.left_top_element ~= nil then 
			controls.button_switch_left:show_control()
		end
		if specific_data.right_element ~= nil or specific_data.right_top_element ~= nil then 
			controls.button_switch_right:show_control()
		end
	elseif specific_data.row == 0x2 then 
		if specific_data.left_top_element ~= nil then 
			controls.button_switch_left:show_control()
		end
		if specific_data.right_top_element ~= nil then 
			controls.button_switch_right:show_control()
		end
	end

	if not (data.current_cabinet == 1 and specific_data.left_element == nil and specific_data.right_element == nil) then
		controls.button_delete:show_control()
	end
	
end


function move_up(data)
	local specific_data = data.cabinet_list[data.current_cabinet]
	if specific_data.row == 0x3 then 
		if specific_data.left_top_element == nil then
			local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
			specific_data.left_top_element = new_element
			data.cabinet_list[new_element].right_top_element = data.current_cabinet
		end
		data.current_cabinet = specific_data.left_top_element
	else
		if specific_data.top_element ~= nil then
			data.current_cabinet = specific_data.top_element
		else
		--first check for existing nearby top element, otherwise add new 
			local next_base = specific_data.right_element
			local steps = 1
			local found = nil
			while next_base ~= nil do
				if data.cabinet_list[next_base].top_element ~= nil or data.cabinet_list[next_base].row == 0x3 then
					local next_top = nil
					if data.cabinet_list[next_base].top_element ~= nil then 
						next_top = data.cabinet_list[next_base].top_element
					else 
						next_top = next_base
					end
					for i = 1, steps, 1 do
						if data.cabinet_list[next_top].left_top_element == nil then 
							break
						end
						next_top = data.cabinet_list[next_top].left_top_element
					end
					data.current_cabinet = next_top
					found = 1
					break
				end
				next_base = data.cabinet_list[next_base].right_element
				steps = steps + 1
			end
			if found == nil then 
				steps = 1
				next_base = specific_data.left_element
				while next_base ~= nil do
					if data.cabinet_list[next_base].top_element ~= nil or data.cabinet_list[next_base].row == 0x3 then
						local next_top = nil
						if data.cabinet_list[next_base].top_element ~= nil then 
							next_top = data.cabinet_list[next_base].top_element
						else 
							next_top = next_base
						end
						for i = 1, steps, 1 do
							if data.cabinet_list[next_top].right_top_element == nil then 
								break
							end
							next_top = data.cabinet_list[next_top].right_top_element
						end
						data.current_cabinet = next_top
						found = 1
						break
					end
					next_base = data.cabinet_list[next_base].left_element
					steps = steps + 1
				end
			end
			if found == nil then 
				local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
				specific_data.top_element = new_element
				data.cabinet_list[new_element].bottom_element = data.current_cabinet
				data.current_cabinet = specific_data.top_element
			end
		end
	end
	recreate_all(data, false)
end
function move_down(data)
	local specific_data = data.cabinet_list[data.current_cabinet]
	if specific_data.row == 0x3 then 
		if specific_data.right_top_element == nil then
			local new_element = initialize_cabinet_values(data, typecombolist[0x2][1])
			specific_data.right_top_element = new_element
			data.cabinet_list[new_element].left_top_element = data.current_cabinet
		end
		data.current_cabinet = specific_data.right_top_element
	else
		if specific_data.bottom_element ~= nil then
			data.current_cabinet = specific_data.bottom_element
		else
			local next_top = specific_data.right_top_element
			local steps = 1
			while next_top ~= nil do
				if data.cabinet_list[next_top].bottom_element ~= nil or data.cabinet_list[next_top].row == 0x3 then
					local next_bottom = nil
					if data.cabinet_list[next_top].bottom_element ~= nil then 
						next_bottom = data.cabinet_list[next_top].bottom_element
					else 
						next_bottom = next_top
					end
					for i = 1, steps, 1 do
						if data.cabinet_list[next_bottom].left_element == nil then 
							break
						end
						next_bottom = data.cabinet_list[next_bottom].left_element
					end
					data.current_cabinet = next_bottom
					break
				end
				next_top = data.cabinet_list[next_top].right_top_element
				steps = steps + 1
			end
			steps = 1
			next_top = specific_data.left_top_element
			while next_top ~= nil do
				if data.cabinet_list[next_top].bottom_element ~= nil or data.cabinet_list[next_top].row == 0x3 then
					local next_bottom = nil
					if data.cabinet_list[next_top].bottom_element ~= nil then 
						next_bottom = data.cabinet_list[next_top].bottom_element
					else 
						next_bottom = next_top
					end
					for i = 1, steps, 1 do
						if data.cabinet_list[next_bottom].right_element == nil then 
							break
						end
						next_bottom = data.cabinet_list[next_bottom].right_element
					end
					data.current_cabinet = next_bottom
					break
				end
				next_top = data.cabinet_list[next_top].left_top_element
				steps = steps + 1
			end	
		end
	end
	recreate_all(data, false)
end

function delete_element(data)
	local specific_data = data.cabinet_list[data.current_cabinet]
	if data.current_cabinet == 1 and #data.cabinet_list == 1 then
		return
	end
	if data.current_cabinet == 1 and specific_data.left_element == nil and specific_data.right_element == nil then
		return
	end
	
	local left_element = specific_data.left_element
	local right_element = specific_data.right_element
	local left_top_element = specific_data.left_top_element
	local right_top_element = specific_data.right_top_element
	local top_element = specific_data.top_element
	local bottom_element = specific_data.bottom_element

	--first treat the top rows. 
	if specific_data.row == 0x3 then 
		local bottom_defined = nil
		if left_element ~= nil then
			data.cabinet_list[left_element].top_element = left_top_element
			if left_top_element ~= nil then
				data.cabinet_list[left_top_element].bottom_element = left_element
				bottom_defined = 1
			end
		end
		if right_element ~= nil then
			data.cabinet_list[right_element].top_element = right_top_element
			if right_top_element ~= nil and bottom_defined == nil then
				data.cabinet_list[right_top_element].bottom_element = right_element
			end
		end 
		if left_top_element ~= nil then
			data.cabinet_list[left_top_element].right_top_element = right_top_element
		end
		if right_top_element ~= nil then
			data.cabinet_list[right_top_element].left_top_element = left_top_element
		end
	elseif specific_data.row == 0x2 then 
		if left_top_element ~= nil then
			if bottom_element ~= nil then
			data.cabinet_list[left_top_element].bottom_element = bottom_element
			data.cabinet_list[bottom_element].top_element = left_top_element
			end
		elseif right_top_element ~= nil then
			if bottom_element ~= nil then
				data.cabinet_list[right_top_element].bottom_element = bottom_element
				data.cabinet_list[bottom_element].top_element = right_top_element
			end
		else 
			if bottom_element ~= nil then
				data.cabinet_list[bottom_element].top_element = nil
			end
		end 
		if left_top_element ~= nil then
			data.cabinet_list[left_top_element].right_top_element = right_top_element
		end
		if right_top_element ~= nil then
			data.cabinet_list[right_top_element].left_top_element = left_top_element
		end		
	else 
		if top_element ~= nil then
			if left_element ~= nil then
				if data.cabinet_list[left_element].row == 0x3 then 
					data.cabinet_list[left_element].right_top_element = top_element
					data.cabinet_list[top_element].left_top_element = left_element
					data.cabinet_list[top_element].bottom_element = nil
				elseif data.cabinet_list[left_element].top_element ~= nil then
					data.cabinet_list[data.cabinet_list[left_element].top_element].right_top_element = top_element
					data.cabinet_list[top_element].left_top_element = data.cabinet_list[left_element].top_element
					data.cabinet_list[top_element].bottom_element = nil
				else
					data.cabinet_list[left_element].top_element = top_element
					data.cabinet_list[top_element].bottom_element = left_element
				end
			elseif right_element ~= nil then
				if data.cabinet_list[right_element].row == 0x3 then 
					data.cabinet_list[right_element].left_top_element = top_element
					data.cabinet_list[top_element].right_top_element = right_element
					data.cabinet_list[top_element].bottom_element = nil
				elseif data.cabinet_list[right_element].top_element ~= nil then
					data.cabinet_list[data.cabinet_list[right_element].top_element].left_top_element = top_element
					data.cabinet_list[top_element].right_top_element = data.cabinet_list[right_element].top_element
					data.cabinet_list[top_element].bottom_element = nil
				else
					data.cabinet_list[right_element].top_element = top_element
					data.cabinet_list[top_element].bottom_element = right_element
				end
			end
		end
	end
	--as we start geometry creation at 1 we need a special treatment for this case
	if data.current_cabinet == 1 then
		if left_element ~= nil then
			data.cabinet_list[1] = data.cabinet_list[left_element]
			left_element = 1
		elseif right_element ~= nil then
			data.cabinet_list[1] = data.cabinet_list[right_element]
			right_element = 1
		end 
	end
	if specific_data.row == 0x2 then
		--0x2 never has a left or right element, so we set the next current caabinet either to the bottom, topleft or topright
		if bottom_element ~= nil then
			data.current_cabinet = bottom_element
		elseif left_top_element ~= nil then
			data.current_cabinet = left_top_element
		elseif right_top_element ~= nil then
			data.current_cabinet = right_top_element
		else 
			data.current_cabinet = 1	--fallback never to be reached
		end 
	else
		if left_element ~= nil then
		data.cabinet_list[left_element].right_element = right_element
		end
		if right_element ~= nil then
		data.cabinet_list[right_element].left_element = left_element
		end
	end 
	--we randomly prioritize the left element 
	if left_element ~= nil then
		data.current_cabinet = left_element
	elseif right_element ~= nil then
		data.current_cabinet = right_element
	end 
	recreate_all(data, false)
end

local function swap_base_base(data, left_elem, right_elem)
-- the cabinet 1 has a special meaning for positioning. 
--To avoid special cases for switching with cabinet 1 we swap the whole cabinet structures.
-- (thus all neighbors directly get the correct informationand and we can afterwards revert the neighbor elements of the two cabinets.
	data.cabinet_list[left_elem], data.cabinet_list[right_elem] = data.cabinet_list[right_elem], data.cabinet_list[left_elem]
--now correct again fo the neighbors
	data.cabinet_list[left_elem].left_element, data.cabinet_list[right_elem].left_element = data.cabinet_list[right_elem].left_element, data.cabinet_list[left_elem].left_element
	data.cabinet_list[left_elem].right_element, data.cabinet_list[right_elem].right_element = data.cabinet_list[right_elem].right_element, data.cabinet_list[left_elem].right_element
	data.cabinet_list[left_elem].top_element, data.cabinet_list[right_elem].top_element = data.cabinet_list[right_elem].top_element, data.cabinet_list[left_elem].top_element
end

local function swap_wall_wall(data, left_elem, right_elem)
	data.cabinet_list[left_elem], data.cabinet_list[right_elem] = data.cabinet_list[right_elem], data.cabinet_list[left_elem]
	data.cabinet_list[left_elem].left_top_element, data.cabinet_list[right_elem].left_top_element = data.cabinet_list[right_elem].left_top_element, data.cabinet_list[left_elem].left_top_element
	data.cabinet_list[left_elem].right_top_element, data.cabinet_list[right_elem].right_top_element = data.cabinet_list[right_elem].right_top_element, data.cabinet_list[left_elem].right_top_element
end

local function swap_high_high(data, left_elem, right_elem)
	data.cabinet_list[left_elem], data.cabinet_list[right_elem] = data.cabinet_list[right_elem], data.cabinet_list[left_elem]
	
	data.cabinet_list[left_elem].left_top_element, data.cabinet_list[right_elem].left_top_element = data.cabinet_list[right_elem].left_top_element, data.cabinet_list[left_elem].left_top_element
	data.cabinet_list[left_elem].right_top_element, data.cabinet_list[right_elem].right_top_element = data.cabinet_list[right_elem].right_top_element, data.cabinet_list[left_elem].right_top_element
	data.cabinet_list[left_elem].left_element, data.cabinet_list[right_elem].left_element = data.cabinet_list[right_elem].left_element, data.cabinet_list[left_elem].left_element
	data.cabinet_list[left_elem].right_element, data.cabinet_list[right_elem].right_element = data.cabinet_list[right_elem].right_element, data.cabinet_list[left_elem].right_element
end

function switch_with_left(data)
	local cur_elem = data.current_cabinet

	if data.cabinet_list[cur_elem].row == 0x1 then 
		local left_elem = data.cabinet_list[cur_elem].left_element
		
		if data.cabinet_list[left_elem] ~= nil then 
			if data.cabinet_list[left_elem].row == 0x1 then 
				swap_base_base(data, left_elem, cur_elem)
			elseif data.cabinet_list[left_elem].row == 0x2 then 
				--should not happen!
			elseif data.cabinet_list[left_elem].row == 0x3 then 
				--here we need to be careful with top left and right elements as these do not exist for base cabinets. 
				--In case a top cabinet exists base and top will be treated as one unit while swapping.
				--Otherwise the elements stick to the old cabinet
				local top_element = data.cabinet_list[cur_elem].top_element
				data.cabinet_list[data.cabinet_list[cur_elem].left_element], data.cabinet_list[cur_elem] = data.cabinet_list[cur_elem], data.cabinet_list[data.cabinet_list[cur_elem].left_element]
				--now correct again fo the neighbors
				data.cabinet_list[left_elem].left_element, data.cabinet_list[cur_elem].left_element = data.cabinet_list[cur_elem].left_element, data.cabinet_list[left_elem].left_element
				data.cabinet_list[left_elem].right_element, data.cabinet_list[cur_elem].right_element = data.cabinet_list[cur_elem].right_element, data.cabinet_list[left_elem].right_element
				 
				if top_element ~= nil then 
					top_specific_data = data.cabinet_list[top_element]
					data.cabinet_list[left_elem].left_top_element, top_specific_data.left_top_element = top_specific_data.left_top_element, data.cabinet_list[left_elem].left_top_element
					data.cabinet_list[left_elem].right_top_element, top_specific_data.right_top_element = top_specific_data.right_top_element, data.cabinet_list[left_elem].right_top_element
				end
			end
			data.current_cabinet = left_elem
		end
	elseif data.cabinet_list[cur_elem].row == 0x2 then 
		--wall cabinets created on top of a base cabinet should keep that relation, e.g. for a fume hood...
		local left_top_elem = data.cabinet_list[cur_elem].left_top_element
		if data.cabinet_list[left_top_elem] ~= nil then 
			if data.cabinet_list[left_top_elem].row == 0x1 then 
				--should not happen!
			elseif data.cabinet_list[left_top_elem].row == 0x2 then 
				swap_wall_wall(data, left_top_elem, cur_elem)
			elseif data.cabinet_list[left_top_elem].row == 0x3 then 
				--Any wall cabinet with a high cabinet as a neighbor was created in relation to this. Thus, it can be trated like the wall-wall case		
				swap_wall_wall(data, left_top_elem, cur_elem)
			end
			data.current_cabinet = left_top_elem
		end
	elseif data.cabinet_list[cur_elem].row == 0x3 then 
		local left_elem = data.cabinet_list[cur_elem].left_element
		if data.cabinet_list[left_elem] ~= nil then 
			if data.cabinet_list[left_elem].row == 0x1 then 
				local top_element = data.cabinet_list[left_elem].top_element
				data.cabinet_list[data.cabinet_list[cur_elem].left_element], data.cabinet_list[cur_elem] = data.cabinet_list[cur_elem], data.cabinet_list[data.cabinet_list[cur_elem].left_element]
				--now correct again fo the neighbors
				data.cabinet_list[left_elem].left_element, data.cabinet_list[cur_elem].left_element = data.cabinet_list[cur_elem].left_element, data.cabinet_list[left_elem].left_element
				data.cabinet_list[left_elem].right_element, data.cabinet_list[cur_elem].right_element = data.cabinet_list[cur_elem].right_element, data.cabinet_list[left_elem].right_element
				 
				if top_element ~= nil then 
					top_specific_data = data.cabinet_list[top_element]
					data.cabinet_list[left_elem].left_top_element, top_specific_data.left_top_element = top_specific_data.left_top_element, data.cabinet_list[left_elem].left_top_element
					data.cabinet_list[left_elem].right_top_element, top_specific_data.right_top_element = top_specific_data.right_top_element, data.cabinet_list[left_elem].right_top_element
				end
			elseif data.cabinet_list[left_elem].row == 0x2 then 
				--should not happen!
			elseif data.cabinet_list[left_elem].row == 0x3 then 
				swap_high_high(data, left_elem, cur_elem)
			end
			data.current_cabinet = left_elem
		end
	end
	recreate_all(data, false)
end

function switch_with_right(data)
	local cur_elem = data.current_cabinet
	if data.cabinet_list[cur_elem].row == 0x1 then 
		local right_elem = data.cabinet_list[cur_elem].right_element
		if data.cabinet_list[right_elem] ~= nil then 
			if data.cabinet_list[right_elem].row == 0x1 then 
				swap_base_base(data, cur_elem, right_elem)
			elseif data.cabinet_list[right_elem].row == 0x2 then 
				--should not happen!
			elseif data.cabinet_list[right_elem].row == 0x3 then 
				--here we need to be careful with top left and right elements as these do not exist for base cabinets. 
				--In case a top cabinet exists base and top will be treated as one unit while swapping.
				--Otherwise the elements stick to the old cabinet
				local top_elem = data.cabinet_list[cur_elem].top_element
				data.cabinet_list[right_elem], data.cabinet_list[cur_elem] = data.cabinet_list[cur_elem], data.cabinet_list[right_elem]
				--now correct again fo the neighbors
				data.cabinet_list[right_elem].left_element, data.cabinet_list[cur_elem].left_element = data.cabinet_list[cur_elem].left_element, data.cabinet_list[right_elem].left_element
				data.cabinet_list[right_elem].right_element, data.cabinet_list[cur_elem].right_element = data.cabinet_list[cur_elem].right_element, data.cabinet_list[right_elem].right_element
				 
				if top_elem ~= nil then 
					data.cabinet_list[right_elem].left_top_element, data.cabinet_list[top_elem].left_top_element = data.cabinet_list[top_elem].left_top_element, data.cabinet_list[right_elem].left_top_element
					data.cabinet_list[right_elem].right_top_element, data.cabinet_list[top_elem].right_top_element = data.cabinet_list[top_elem].right_top_element, data.cabinet_list[right_elem].right_top_element
				end
			end
			data.current_cabinet = right_elem
		end
	elseif data.cabinet_list[cur_elem].row == 0x2 then 
		--wall cabinets created on top of a base cabinet should keep that relation, e.g. for a fume hood...
		local right_top_elem = data.cabinet_list[cur_elem].right_top_element
		if data.cabinet_list[right_top_elem] ~= nil then 
			if data.cabinet_list[right_top_elem].row == 0x1 then 
				--should not happen!
			elseif data.cabinet_list[right_top_elem].row == 0x2 then 
				swap_wall_wall(data, cur_elem, right_top_elem)
			elseif data.cabinet_list[right_top_elem].row == 0x3 then 
				--Any wall cabinet with a high cabinet as a neighbor was created in relation to this. Thus, it can be trated like the wall-wall case				
				swap_wall_wall(data, cur_elem, right_top_elem)
			end
			data.current_cabinet = right_top_elem
		end
	elseif data.cabinet_list[cur_elem].row == 0x3 then 
		local right_elem = data.cabinet_list[cur_elem].right_element
		if data.cabinet_list[right_elem] ~= nil then 
			if data.cabinet_list[right_elem].row == 0x1 then 
				local top_elem = data.cabinet_list[right_elem].top_element
				data.cabinet_list[right_elem], data.cabinet_list[cur_elem] = data.cabinet_list[cur_elem], data.cabinet_list[right_elem]
				--now correct again fo the neighbors
				data.cabinet_list[right_elem].left_element, data.cabinet_list[cur_elem].left_element = data.cabinet_list[cur_elem].left_element, data.cabinet_list[right_elem].left_element
				data.cabinet_list[right_elem].right_element, data.cabinet_list[cur_elem].right_element = data.cabinet_list[cur_elem].right_element, data.cabinet_list[right_elem].right_element
				 
				if top_elem ~= nil then 
					data.cabinet_list[right_elem].left_top_element, data.cabinet_list[top_elem].left_top_element = data.cabinet_list[top_elem].left_top_element, data.cabinet_list[right_elem].left_top_element
					data.cabinet_list[right_elem].right_top_element, data.cabinet_list[top_elem].right_top_element = data.cabinet_list[top_elem].right_top_element, data.cabinet_list[right_elem].right_top_element
				end
			elseif data.cabinet_list[right_elem].row == 0x2 then 
				--should not happen!
			elseif data.cabinet_list[right_elem].row == 0x3 then 
				swap_high_high(data, cur_elem, right_elem)
			end
			data.current_cabinet = right_elem
		end
	end
	recreate_all(data, false)
end


specific_controls_styles.top_type = {
	label = pyloc "Top Style",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
												label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
												ctrl_id = dialog_handle:create_drop_list(edit_col, nil, {insert_after = label_id}) 
												ctrl_id:set_on_change_handler(function(text, new_index)
													local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
													data.cabinet_list[data.current_cabinet].top_style = spec_type_info.top_styles[new_index]
													recreate_all(data, false)
												end)
												local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
												ctrl_id:reset_content()
												local current_top = 0
												for i, k in pairs(spec_type_info.top_styles) do
													ctrl_id:insert_control_item(top_style_list[k].name)
													if k == data.cabinet_list[data.current_cabinet].top_style then 
														current_top = i
													end 
												end
												ctrl_id:set_control_selection(current_top)
												return ctrl_id, label_id
											end,}

specific_controls_styles.back_type = {
	label = pyloc "Back Style",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
												label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
												ctrl_id = dialog_handle:create_drop_list(edit_col, nil, {insert_after = label_id}) 
												ctrl_id:set_on_change_handler(function(text, new_index)
													local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
													data.cabinet_list[data.current_cabinet].back_style = spec_type_info.back_styles[new_index]
													recreate_all(data, false)
												end)
												local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
												ctrl_id:reset_content()
												local current_back = 0
												for i, k in pairs(spec_type_info.back_styles) do
													ctrl_id:insert_control_item(back_style_list[k].name)
													if k == data.cabinet_list[data.current_cabinet].back_style then 
														current_back = i
													end 
												end
												ctrl_id:set_control_selection(current_back)
												return ctrl_id, label_id
											end,}

specific_controls_styles.bottom_type = {
	label = pyloc "Bottom Style",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
												label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
												ctrl_id = dialog_handle:create_drop_list(edit_col, nil, {insert_after = label_id}) 
												ctrl_id:set_on_change_handler(function(text, new_index)
													local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
													data.cabinet_list[data.current_cabinet].bottom_style = spec_type_info.bottom_styles[new_index]
													recreate_all(data, false)
												end)
												local spec_type_info = cabinet_typelist[data.cabinet_list[data.current_cabinet].this_type]
												ctrl_id:reset_content()
												local current_bottom = 0
												for i, k in pairs(spec_type_info.bottom_styles) do
													ctrl_id:insert_control_item(bottom_style_list[k].name)
													if k == data.cabinet_list[data.current_cabinet].bottom_style then 
														current_bottom = i
													end 
												end
												ctrl_id:set_control_selection(current_bottom)
												return ctrl_id, label_id
											end,}

specific_controls_styles.width = {
	label = pyloc "Width",
	is_basic = true,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
												label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
												ctrl_id = dialog_handle:create_text_box(edit_col, pyui.format_length(data.cabinet_list[data.current_cabinet].width), {insert_after = label_id}) 
												ctrl_id:set_on_change_handler(function(text)
													data.cabinet_list[data.current_cabinet].width = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].width, 0)
													recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}

specific_controls_styles.width2 = {
	label = pyloc "Right width",
	is_basic = true,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
												label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
												ctrl_id = dialog_handle:create_text_box(edit_col, pyui.format_length(data.cabinet_list[data.current_cabinet].width2), {insert_after = label_id}) 
												ctrl_id:set_on_change_handler(function(text)
													data.cabinet_list[data.current_cabinet].width2 = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].width2, 0)
													recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}
											
specific_controls_styles.depth = {
	label = pyloc "Depth",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_text_box(edit_col, pyui.format_length(data.cabinet_list[data.current_cabinet].depth), {insert_after = label_id}) 
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].depth = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].depth, 0)
												recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}
											
specific_controls_styles.height = {
	label = pyloc "Height",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_text_box(edit_col, pyui.format_length(data.cabinet_list[data.current_cabinet].height), {insert_after = label_id}) 
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].height = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].height, 0)
												recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}
											
specific_controls_styles.height_top = {
	label = pyloc "OA Height",
	is_basic = true,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_text_box(edit_col, pyui.format_length(data.cabinet_list[data.current_cabinet].height_top), {insert_after = label_id}) 
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].height_top = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].height_top, 0)
												recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}
											
specific_controls_styles.shelf_count_0_20 = {
	label = pyloc "Number of shelves",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_text_spin(edit_col, pyui.format_number(data.cabinet_list[data.current_cabinet].shelf_count), {insert_after = label_id}) 
											ctrl_id:set_control_range(0,20)
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].shelf_count = math.max(pyui.parse_number(text) or data.cabinet_list[data.current_cabinet].shelf_count, 0)
												recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}
specific_controls_styles.drawer_count_1_20 = {
	label = pyloc "Number of drawers",
	is_basic = true,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_text_spin(edit_col, pyui.format_number(data.cabinet_list[data.current_cabinet].drawer_count), {insert_after = label_id}) 
											ctrl_id:set_control_range(1,20)
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].drawer_count = math.max(pyui.parse_number(text) or data.cabinet_list[data.current_cabinet].drawer_count, 0)
												recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}

specific_controls_styles.door_width = {
	label = pyloc "Door width",
	is_basic = true,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_text_box(edit_col, pyui.format_length(data.cabinet_list[data.current_cabinet].door_width), {insert_after = label_id}) 
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].door_width = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].door_width, 0)
												recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}

specific_controls_styles.door_side = {
	label = pyloc "Door right side",
	is_basic = true,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											ctrl_id = dialog_handle:create_check_box({label_col, edit_col}, label_text, {insert_after = prev_control}) 		
											ctrl_id:set_control_checked(data.cabinet_list[data.current_cabinet].door_rh)
											ctrl_id:set_on_click_handler(function(state)
												data.cabinet_list[data.current_cabinet].door_rh = state
												recreate_all(data, true)
												end)
												return ctrl_id, nil
											end,}

specific_controls_styles.depth2 = {
	label = pyloc "Depth right",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_text_box(edit_col, pyui.format_length(data.cabinet_list[data.current_cabinet].depth2), {insert_after = label_id}) 
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].depth2 = math.max(pyui.parse_length(text) or data.cabinet_list[data.current_cabinet].depth2, 0)
												recreate_all(data, true)
												end)
												return ctrl_id, label_id
											end,}

specific_controls_styles.drawer_height_list = {
	label = pyloc "Drawer height",
	is_basic = true,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_combo_box(edit_col, nil, {insert_after = label_id}) 
											ctrl_id:set_on_change_handler(function(text)
												data.cabinet_list[data.current_cabinet].drawer_height_list = text 
												recreate_all(data, true)
												end)
											fill_drawer_height_list(data, data.cabinet_list[data.current_cabinet], ctrl_id)
											return ctrl_id, label_id
											end,}

specific_controls_styles.sink_orientation = {
	label = pyloc "Sink orientation",
	is_basic = false,
	create = function(dialog_handle, label_text, data, prev_control, label_col, edit_col) 
											label_id = dialog_handle:create_label(label_col, label_text, {insert_after = prev_control})
											ctrl_id = dialog_handle:create_drop_list(edit_col, nil, {insert_after = label_id}) 
											ctrl_id:reset_content()
											ctrl_id:insert_control_item(pyloc "left")
											ctrl_id:insert_control_item(pyloc "centered")
											ctrl_id:insert_control_item(pyloc "right")
											ctrl_id:insert_control_item(pyloc "flipped, left")
											ctrl_id:insert_control_item(pyloc "flipped, centered")
											ctrl_id:insert_control_item(pyloc "flipped, right")
											ctrl_id:set_control_selection(3 * data.cabinet_list[data.current_cabinet].sink_flipped + data.cabinet_list[data.current_cabinet].sink_position)
											ctrl_id:set_on_change_handler(function(text, new_index)
												data.cabinet_list[data.current_cabinet].sink_position = (new_index - 1) % 3 + 1
												data.cabinet_list[data.current_cabinet].sink_flipped = math.floor((new_index - 1) / 3)
												recreate_all(data, true)
												end)
											return ctrl_id, label_id
										end,}



function insert_specific_control(data, control_id, name)
	label_text = name
	local label_col = 3
	local edit_col = 4
	if control_id == nil then return end
	if specific_controls_styles[control_id] == nil then return end

	if label_text == nil then label_text = specific_controls_styles[control_id].label end
	if specific_controls_styles[control_id].is_basic == true then 
		if specific_controls_styles[control_id].create ~= nil then  
			--assures that each control can only be added once
			if specific_controls_styles[control_id].ctrl_id ~= nil then 
				specific_controls_styles[control_id].ctrl_id:delete_control() 
				specific_controls_styles[control_id].ctrl_id = nil
			end
			if specific_controls_styles[control_id].label_id ~= nil then 
				specific_controls_styles[control_id].label_id:delete_control()
				specific_controls_styles[control_id].label_id = nil 
			end
	
			ctrl_id, label_id = specific_controls_styles[control_id].create(main_dialog_handle, label_text, data, main_prev_control, label_col, edit_col)
			specific_controls_styles[control_id].ctrl_id = ctrl_id
			specific_controls_styles[control_id].label_id = label_id
			main_prev_control = ctrl_id
		end
	end

	table.insert(control_list_for_specific_dialog, {id = control_id, name = label_text})
end

function get_control_handle(control_id)
	if specific_controls_styles[control_id] == nil then return nil end
	return specific_controls_styles[control_id].ctrl_id
end


function open_specific_details_dialog(data)

	pyui.run_modal_subdialog(specific_details, data)
	
end

function specific_details(specific_dialog, data)
	local prev_control = nil
	local label_col = 1
	local edit_col = 2
	specific_dialog:set_window_title(pyloc "Details of cabinet")
	for i, k in pairs(control_list_for_specific_dialog) do 
		local control_id = k.id
		local label_text = k.name
		if control_id ~= nil and 
		specific_controls_styles[control_id] ~= nil and 
		specific_controls_styles[control_id].create ~= nil then  
			
			ctrl_id, label_id = specific_controls_styles[control_id].create(specific_dialog, label_text, data, prev_control, label_col, edit_col)
			prev_control = ctrl_id
		end
	end

	specific_dialog:create_align({1,2})
	local ok = specific_dialog:create_ok_button({1,2})
	specific_dialog:equalize_column_widths({1, 2})



	
end