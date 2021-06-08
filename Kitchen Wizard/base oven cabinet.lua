--Base oven cabinets (is different from the base cabinets with regards to the back)


local function recreate_hob_and_oven_base(general_data, specific_data, cur_elements)

	
-------------------
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local carcass_depth = specific_data.depth - door_to_carcass
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local carcass_elements = {}
	local new_elem = nil
	
	local side_length = carcass_depth
	if specific_data.back_style == "back_external" then
		side_length = carcass_depth - general_data.thickness_back
	end
	local side_height = specific_data.height
	if specific_data.bottom_style == "bottom_external" then
		loc_origin[3] = base_height + general_data.thickness
		side_height = specific_data.height - general_data.thickness
	end
		
	--Left side
	loc_origin[2] = door_to_carcass
	new_elem = pytha.create_block(general_data.thickness, side_length, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, specific_data.width, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_lh")
	table.insert(carcass_elements, new_elem)
	--Right side
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, side_length, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, specific_data.width, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_rh")
	table.insert(carcass_elements, new_elem)
	
	--Bottom
	loc_origin[1] = general_data.thickness
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height
	local bottom_style_info = nil
	if specific_data.bottom_style then
		bottom_style_info = bottom_style_list[specific_data.bottom_style]
	end
	local bottom_width = specific_data.width - 2 * general_data.thickness
	local bottom_depth = carcass_depth
	local top_depth = carcass_depth + door_to_carcass
	if specific_data.bottom_style == "bottom_external" then
		bottom_width = specific_data.width
		loc_origin[1] = 0
	end
	if specific_data.back_style == "back_rebate" then
		bottom_depth = carcass_depth
--		top_depth = carcass_depth - general_data.thickness_back + door_to_carcass
	elseif specific_data.back_style == "back_external" then
		bottom_depth = carcass_depth - general_data.thickness_back
		top_depth = carcass_depth - general_data.thickness_back + door_to_carcass
	elseif specific_data.back_style == "back_internal" then
		if specific_data.bottom_style == "bottom_external" then
			bottom_depth = carcass_depth
		else
			bottom_depth = carcass_depth - groove_dist_back_off
		end
--		top_depth = carcass_depth - groove_dist_back_off + door_to_carcass
	end
	
	new_elem = pytha.create_block(bottom_width, bottom_depth, general_data.thickness, loc_origin)
	set_part_attributes(new_elem, "bottom")
	table.insert(carcass_elements, new_elem)

	--Top
	loc_origin[1] = general_data.thickness
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height + specific_data.height
	local top_style_info = nil
	if specific_data.top_style then
		top_style_info = top_style_list[specific_data.top_style]
		top_style_info.geometry_function(general_data, specific_data, specific_data.width, top_depth, loc_origin, coordinate_system, carcass_elements)
	end

	--Front
	loc_origin[1] = 0 --general_data.gap
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height + specific_data.height - general_data.top_gap
	local shelf_depth = door_to_carcass + carcass_depth - general_data.setback_fixed_shelves - groove_dist_back_off
	local oven_width = 0
	local oven_height = 0
	if specific_data.appliance_file2 then 
		loaded_oven, oven_width, oven_height = create_oven_with_blind(general_data, specific_data, specific_data.appliance_file2, loc_origin, shelf_depth, cur_elements, carcass_elements, "top")
	else 
			
	end 

	--fixed_shelf
	loc_origin[1] = 0
	loc_origin[2] = general_data.setback_fixed_shelves
	loc_origin[3] = base_height + specific_data.height - oven_height - general_data.thickness - general_data.top_gap
	new_elem = create_fixed_shelf(general_data, specific_data, specific_data.width, shelf_depth, loc_origin)
	table.insert(carcass_elements, new_elem)

	recreate_basic_front(general_data, specific_data, base_height, specific_data.height - oven_height - general_data.thickness / 2, specific_data.width, shelf_depth, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0})
	
	--The back rail is placed completely at the back, not at the rebate depth. Can be modified here
	local back_height = specific_data.height - oven_height - general_data.top_gap
	local back_width = specific_data.width - 2 * (general_data.thickness - general_data.groove_depth)
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = door_to_carcass + carcass_depth - groove_dist_back_off
	loc_origin[3] = base_height
	if specific_data.back_style == "back_rebate" then
		loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
		back_height = back_height - general_data.thickness + general_data.groove_depth
	elseif specific_data.back_style == "back_external" then
		loc_origin[1] = 0 
		back_width = specific_data.width
	elseif specific_data.back_style == "back_internal" then
		if specific_data.bottom_style == "bottom_external" then
			loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
			back_height = back_height - general_data.thickness + general_data.groove_depth
		end
	end
	new_elem = pytha.create_block(back_width, general_data.thickness_back, back_height, loc_origin)
	set_part_attributes(new_elem, "back")
	table.insert(carcass_elements, new_elem)
	


	carcass_elements = pytha.create_group(carcass_elements)	
	pytha.set_element_name(carcass_elements, "Base_Carcass")
	table.insert(cur_elements, carcass_elements)

	--Kickboard
	create_straight_kickboard(general_data, specific_data, base_height, specific_data.width, cur_elements)
	--Benchtop
	create_straight_benchtop(general_data, specific_data, specific_data.width)
	
	recreate_plan_details_base(general_data, specific_data, cur_elements)


end

	
local function recreate_hob_and_oven(general_data, specific_data)

	local cur_elements = {}
	
	recreate_hob_and_oven_base(general_data, specific_data, cur_elements)
	
--------------------
	local loaded_sink = create_sink(general_data, specific_data, specific_data.appliance_file) 
	table.insert(cur_elements, loaded_sink)
	
--------------------	
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end
	
local function ui_update_hob_oven(general_data, soft_update)
	ui_update_intelli_doors(general_data, soft_update)	--by default we add the doors. Can of course be modified
	if soft_update == true then return end

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	insert_specific_control(general_data, "width", nil)
	insert_specific_control(general_data, "height", nil)
	insert_specific_control(general_data, "depth", nil)

	controls.appliance_model2_label:show_control()
	controls.appliance_model2_label:set_control_text(pyloc "Oven model")
	controls.appliance_model2:show_control()
	controls.appliance_model_label:show_control()
	controls.appliance_model_label:set_control_text(pyloc "Hob model")
	controls.appliance_model:show_control()
	

	hobs_to_front_styles(general_data, specific_data, false)
	ovens_to_front_styles2(general_data, specific_data, false)

end
	

if cabinet_typelist == nil then		
	cabinet_typelist = {}
end

cabinet_typelist.hob_and_oven = 			
{									
	name = pyloc "Hob and oven cabinet",		
	row = 0x1,							
	default_data = function(general_data, specific_data) specific_data.width = 600
														specific_data.sink_flipped = 0
														specific_data.sink_position = 2 --1: left, 2: center, 3: right	 
														specific_data.appliance_file = general_data.default_folders.hob_folder  
														specific_data.appliance_file2 = general_data.default_folders.oven_folder
														specific_data.drawer_count = 1 end,
	geometry_function = recreate_hob_and_oven,	 	
	placement_function = placement_base, 	
	ui_update_function = ui_update_hob_oven,
	organization_styles = {"drawers",	
							"blind",
							"intelli_doors_no_shelves",},	
	back_styles = {"back_internal", },
						--"back_external", 
						--"back_rebate",}, --for air circulation, stub back for lower drawers is created by the oven loading routine
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"top_back_vertical", "no_top",},
}
	