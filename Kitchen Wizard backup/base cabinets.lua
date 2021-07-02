--Base cabinets (straight, sink, hob, hob&oven)
--some functions are reused in different cabinet files, like e.g. the plan_detail_base or placement

function recreate_plan_details_base(general_data, specific_data, cur_elements)
	--Plan detail
	local plan_elements = {}
	local loc_origin = {0, specific_data.depth, 0}
	
	local door_to_carcass = 0
	if specific_data.front_style == "base_open" then
		door_to_carcass = - general_data.door_thickness - general_data.door_carcass_gap
	end
	
	new_elem = pytha.create_polyline("open", {{loc_origin[1], loc_origin[2], loc_origin[3]}, 
										{loc_origin[1], loc_origin[2] - specific_data.depth + door_to_carcass, loc_origin[3]},
										{loc_origin[1] + specific_data.width, loc_origin[2] - specific_data.depth + door_to_carcass, loc_origin[3]},
										{loc_origin[1] + specific_data.width, loc_origin[2], loc_origin[3]}})
	set_part_attributes(new_elem, "floor_plan")
	table.insert(plan_elements, new_elem)


	plan_elements = pytha.create_group(plan_elements, {name = attribute_list["floor_plan"].name})

	table.insert(cur_elements, plan_elements)
end

function create_profile_from_poly(poly_array, height, loc_origin, element_table, part_type_key)
	fla_handle = pytha.create_polygon(poly_array)
	profile = pytha.create_profile(fla_handle, height)[1]
	if part_type_key ~= nil then 
		set_part_attributes(profile, part_type_key)
	end
	pytha.delete_element(fla_handle)
	pytha.move_element(profile, loc_origin)
	table.insert(element_table, profile)
end
function calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)
	return door_to_carcass + carcass_depth - groove_dist_back_off
end
function recreate_back(general_data, specific_data, height, width, carcass_depth, base_height, carcass_elements, ignore_bottom_setting)
	local back_height = height
	local loc_origin = {0, 0, 0}
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	--Back
	local back_width = width - 2 * (general_data.thickness - general_data.groove_depth)
	loc_origin[1] = general_data.thickness - general_data.groove_depth
	loc_origin[2] = calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)
	loc_origin[3] = base_height

	if specific_data.back_style == "back_external" then
		loc_origin[1] = 0 
		back_width = width
	end
	if ignore_bottom_setting == nil then 
		if specific_data.row == 0x2 then
			loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
			back_height = height - 2 * general_data.thickness + 2 * general_data.groove_depth
		else
			if specific_data.back_style == "back_rebate" then
				loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
				back_height = height - general_data.thickness + general_data.groove_depth
			elseif specific_data.back_style == "back_internal" then
				if specific_data.bottom_style == "bottom_external" then
					loc_origin[3] = base_height + general_data.thickness - general_data.groove_depth
					back_height = height - general_data.thickness + general_data.groove_depth
				end
			end
		end
	end
	new_elem = pytha.create_block(back_width, general_data.thickness_back, back_height, loc_origin)
	set_part_attributes(new_elem, "back")
	table.insert(carcass_elements, new_elem)
end

function recreate_carcass_base(general_data, specific_data, base_height, height, width, carcass_depth, coordinate_system, carcass_elements)
	local new_elem = nil
	local return_handles = {}
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local side_length = carcass_depth
	local loc_origin = {0, 0, base_height}
	if specific_data.back_style == "back_external" then
		side_length = carcass_depth - general_data.thickness_back
	end
	local side_height = height
	if specific_data.bottom_style == "bottom_external" then
		loc_origin[3] = base_height + general_data.thickness
		side_height = height - general_data.thickness
	end
		
	--Left side
	loc_origin[2] = door_to_carcass
	new_elem = pytha.create_block(general_data.thickness, side_length, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, width, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_lh", return_handles)
	table.insert(carcass_elements, new_elem)
	--Right side
	loc_origin[1] = width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, side_length, side_height, loc_origin)
	if specific_data.fingerpull then
		loc_origin[3] = base_height
		recreate_fingerpull(general_data, specific_data, width, new_elem, loc_origin)
	end 
	set_part_attributes(new_elem, "end_rh", return_handles)
	table.insert(carcass_elements, new_elem)
	
	--Bottom
	loc_origin[1] = general_data.thickness
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height
	local bottom_style_info = nil
	if specific_data.bottom_style then
		bottom_style_info = bottom_style_list[specific_data.bottom_style]
	end
	local bottom_width = width - 2 * general_data.thickness
	local bottom_depth = carcass_depth
	local top_depth = carcass_depth + door_to_carcass
	if specific_data.bottom_style == "bottom_external" then
		bottom_width = width
		loc_origin[1] = 0
	end
	if specific_data.row == 0x2 then --this will make the bottom and top go all the way to the wall
		bottom_depth = side_length
		top_depth = side_length
	else
		if specific_data.back_style == "back_rebate" then
			bottom_depth = carcass_depth
			top_depth = carcass_depth - general_data.thickness_back + door_to_carcass
		elseif specific_data.back_style == "back_external" then
			bottom_depth = carcass_depth - general_data.thickness_back
			top_depth = carcass_depth - general_data.thickness_back + door_to_carcass
		elseif specific_data.back_style == "back_internal" then
			if specific_data.bottom_style == "bottom_external" then
				bottom_depth = carcass_depth
			else
				bottom_depth = carcass_depth - groove_dist_back_off
			end
			top_depth = carcass_depth - groove_dist_back_off + door_to_carcass
		end
	end
	
	new_elem = pytha.create_block(bottom_width, bottom_depth, general_data.thickness, loc_origin)
	set_part_attributes(new_elem, "bottom", return_handles)
	table.insert(carcass_elements, new_elem)

	--Top
	loc_origin[1] = general_data.thickness
	loc_origin[2] = door_to_carcass
	loc_origin[3] = base_height + height
	local top_style_info = nil
	if specific_data.top_style then
		top_style_info = top_style_list[specific_data.top_style]
		top_style_info.geometry_function(general_data, specific_data, width, top_depth, loc_origin, coordinate_system, carcass_elements, return_handles)
	end

	return return_handles
end

function recreate_basic_front(general_data, specific_data, base_height, height, width, shelf_depth, top_gap, coordinate_system, carcass_elements, cur_elements, loc_origin, index)
	--Front
	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local front_style_info = nil
	local ext_elements = {}
	if specific_data.front_style then
		loc_origin[1] = loc_origin[1] + door_to_carcass * coordinate_system[2][1]
		loc_origin[2] = loc_origin[2] + door_to_carcass * coordinate_system[2][2]
		loc_origin[3] = loc_origin[3] + base_height
		
		options = {u_axis = coordinate_system[1], v_axis = coordinate_system[2], w_axis = coordinate_system[3]}
		local token = pytha.push_local_coordinates(loc_origin, options)
		front_style_info = organization_style_list[specific_data.front_style]
		if type(front_style_info.geometry_function) == "table" and front_style_info.geometry_function[index] ~= nil then --this allows for split fronts
			front_style_info.geometry_function[index](general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, loc_origin, cur_elements) 
		elseif type(front_style_info.geometry_function) == "function" then 
			front_style_info.geometry_function(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, loc_origin, cur_elements) 
		end
		pytha.pop_local_coordinates(token)
	end	
	if specific_data.front_style ~= "base_open" and #ext_elements > 0  then
		ext_elements = pytha.create_group(ext_elements, {name = attribute_list["externals"].name})
		table.insert(cur_elements, ext_elements)
	end
end


function create_straight_kickboard(general_data, specific_data, base_height, width, cur_elements)
	specific_data.kickboard_handle_left = pytha.create_block(width, general_data.kickboard_thickness, base_height - general_data.kickboard_margin, {0, general_data.kickboard_setback, general_data.kickboard_margin})
	table.insert(cur_elements, specific_data.kickboard_handle_left)
	specific_data.kickboard_handle_right = specific_data.kickboard_handle_left
end

function create_straight_benchtop(general_data, specific_data, width)
	local benchtop = pytha.create_rectangle(width, general_data.top_over + specific_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
	specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness)[1]
	pytha.delete_element(benchtop)
end

function  groove_dist_back_off_calc(general_data, specific_data)
	local groove_dist = general_data.groove_dist
	if specific_data.groove_dist ~= nil then 
		groove_dist = specific_data.groove_dist
	end
	if specific_data.back_style == "back_rebate" then
		return general_data.thickness_back
	elseif specific_data.back_style == "back_external" then
		return general_data.thickness_back
	elseif specific_data.back_style == "back_internal" then
		return groove_dist + general_data.thickness_back
	end
	return groove_dist + general_data.thickness_back
end

function door_carcass_calc(general_data, specific_data)
	local door_to_carcass = 0
	if specific_data.front_style == "base_open" then
		door_to_carcass = - general_data.door_thickness - general_data.door_carcass_gap
	end
	return door_to_carcass
end

function get_cabinet_row_height_base_height(general_data, specific_data)
	local base_height = 0
	local height = 0
	if specific_data.row == 0x1 then 
		base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness 
		height = specific_data.height
	elseif specific_data.row == 0x2 then 
		base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
		height = specific_data.height_top - base_height
	elseif specific_data.row == 0x3 then 
		base_height = general_data.benchtop_height - general_data.general_height_base - general_data.benchtop_thickness
		height = specific_data.height_top - base_height
	end
	return base_height, height
end


local function recreate_carcass(general_data, specific_data, cur_elements)

	local door_to_carcass = door_carcass_calc(general_data, specific_data)
	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	--if the kitchen is L-shaped. The angle is inherited from the previous cabinet
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local loc_origin = {0, 0, base_height}
	local carcass_depth = specific_data.depth - door_to_carcass
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local carcass_elements = {}
	local new_elem = nil
	local shelf_depth = calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)

	recreate_carcass_base(general_data, specific_data, base_height, specific_data.height, specific_data.width, carcass_depth, coordinate_system, carcass_elements)
	--Back
	recreate_back(general_data, specific_data, specific_data.height, specific_data.width, carcass_depth, base_height, carcass_elements)
	--Front
	recreate_basic_front(general_data, specific_data, base_height, specific_data.height, specific_data.width, shelf_depth, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0})


	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)

	--Kickboard
	create_straight_kickboard(general_data, specific_data, base_height, specific_data.width, cur_elements)
	--Benchtop
	create_straight_benchtop(general_data, specific_data, specific_data.width)

	
	recreate_plan_details_base(general_data, specific_data, cur_elements)
end



local function recreate_base(general_data, specific_data)

	local cur_elements = {}
	recreate_carcass(general_data, specific_data, cur_elements)

	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end

function placement_base(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, specific_data.depth,0}
	specific_data.left_connection_point = {0, specific_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

local function ui_update_base(general_data, soft_update)

	if soft_update == true then return end

	insert_specific_control(general_data, "width", nil)
	insert_specific_control(general_data, "height", nil)
	insert_specific_control(general_data, "depth", nil)	
		
end


--Sink (or hob) cabinet 
local function recreate_sink(general_data, specific_data)

	local cur_elements = {}
	
	recreate_carcass(general_data, specific_data, cur_elements)
	

	local base_height = general_data.benchtop_height - specific_data.height - general_data.benchtop_thickness
	local loc_origin = {0, 0, base_height}

--------------------
	local loaded_sink = create_sink(general_data, specific_data, specific_data.appliance_file) 
	table.insert(cur_elements, loaded_sink)
--------------------	
	
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end


--Empty space with Benchtop  (or hob) cabinet 
local function recreate_empty(general_data, specific_data)

	local cur_elements = {}
	
	--Benchtop
	local benchtop = pytha.create_rectangle(specific_data.width, general_data.top_over + specific_data.depth, {0, -general_data.top_over, general_data.benchtop_height - general_data.benchtop_thickness})
	specific_data.elem_handle_for_top = pytha.create_profile(benchtop, general_data.benchtop_thickness)[1]
	pytha.delete_element(benchtop)

--	recreate_plan_details_base(general_data, specific_data, cur_elements)

	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end
	
local function ui_update_sink(general_data, soft_update)
	if soft_update == true then return end

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	
	ui_update_base(general_data, soft_update)

	insert_specific_control(general_data, "sink_orientation", nil)	

	controls.appliance_model_label:show_control()
	controls.appliance_model_label:set_control_text(pyloc "Sink model")
	controls.appliance_model:show_control()
	sinks_to_front_styles(general_data, specific_data, false)

end	

--Empty space with Front for dishwasher 
local function recreate_dishwasher_fridge(general_data, specific_data, type)
	local new_elem = nil
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local cur_elements = {}
	local offset = specific_data.depth2
	local base_height = general_data.benchtop_height - general_data.benchtop_thickness - specific_data.height 
	local loc_origin = {0, 0, base_height}
	local carcass_elements = {}

	new_elem = pytha.create_block(specific_data.width, specific_data.depth, specific_data.height, loc_origin)
	set_part_attributes(new_elem, type)
	new_elem = pytha.create_group(new_elem, {name = attribute_list[type].name})
	table.insert(cur_elements, new_elem)
	pytha.set_group_replace_properties(new_elem, {origin_u = 'mid', origin_v = 'high', origin_w = 'low', zoom_u = true, zoom_v = false, zoom_w = false})

	recreate_basic_front(general_data, specific_data, base_height, specific_data.height, specific_data.width, 0, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0})
	if #carcass_elements > 0 then 
		carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
		table.insert(cur_elements, carcass_elements)
	end

	--Kickboard (general_data.kickboard_margin is subtracted internally again)
	create_straight_kickboard(general_data, specific_data, base_height - offset + general_data.kickboard_margin, specific_data.width, cur_elements)
	--Benchtop
	create_straight_benchtop(general_data, specific_data, specific_data.width)
	recreate_plan_details_base(general_data, specific_data, cur_elements)

	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end
local function recreate_dishwasher(general_data, specific_data)
	
	return recreate_dishwasher_fridge(general_data, specific_data, "dishwasher")
end
local function recreate_fridge(general_data, specific_data)
	
	return recreate_dishwasher_fridge(general_data, specific_data, "fridge")
end


local function ui_update_hob(general_data, soft_update)
	if soft_update == true then return end

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	
	ui_update_base(general_data, soft_update)
	
	controls.appliance_model_label:show_control()
	controls.appliance_model_label:set_control_text(pyloc "Hob model")
	controls.appliance_model:show_control()

	hobs_to_front_styles(general_data, specific_data, false)

end
local function ui_update_empty(general_data, soft_update)
	if soft_update == true then return end

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	
	insert_specific_control(general_data, "width", nil)

end
local function ui_update_dishwasher(general_data, soft_update)
	if soft_update == true then return end

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	
	insert_specific_control(general_data, "width", nil)
	insert_specific_control(general_data, "height", nil)
	insert_specific_control(general_data, "depth2", pyloc "Gap in Kickboard")

end
local function ui_update_fridge(general_data, soft_update)
	if soft_update == true then return end

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	insert_specific_control(general_data, "width", nil)
	insert_specific_control(general_data, "height", nil)
	insert_specific_control(general_data, "depth2", pyloc "Ventilation Gap")
end
	
--here we register the cabinet to the typelist 
--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			--might still be undefined here
	cabinet_typelist = {}
end

cabinet_typelist.base = 					--used to reference the cabinet in the list
{									
	name = pyloc "Base cabinet",			--displayed in drop List and used as group name
	row = 0x1,									--0x1 base, 0x2 wall, 0x3 high (high covers both rows)
	default_data = {width = 600,
					top_style = "top_horizontal",}, 				--default data that is set to individual values			
	geometry_function = recreate_base,	 	--function to create geometry
	placement_function = placement_base, 	--function to calculate the placement points
	ui_update_function = ui_update_base, 	--function to set values and update UI
	organization_styles = {"intelli_doors",		--Front partition styles that are allowed for this cabinet type				
							"intelli_doors_and_drawer",
							"drawers",		
							"open",		
							},	
	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"top_horizontal",
					"top_vertical",
					"top_solid",},
}


cabinet_typelist.sink = 			
{									
	name = pyloc "Sink cabinet",		
	row = 0x1,							
	default_data = function(general_data, specific_data) specific_data.width = 600
														specific_data.shelf_count = 0
														specific_data.drawer_count = 1
														specific_data.sink_flipped = 0
														specific_data.sink_position = 2 --1: left, 2: center, 3: right	 
														specific_data.appliance_file = general_data.default_folders.sink_folder 
														end,		
	geometry_function = recreate_sink,	 
	placement_function = placement_base, 	
	ui_update_function = ui_update_sink,
	organization_styles = {"intelli_doors_and_blind",	
							"intelli_doors",
							"drawers",
							"open",	
							"drawers_and_blind"},	

	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"both_vertical", "top_horizontal", "top_vertical", "no_top",},
}

cabinet_typelist.hob = 			
{									
	name = pyloc "Hob cabinet",		
	row = 0x1,							
	default_data = function(general_data, specific_data) specific_data.width = 600
														specific_data.sink_flipped = 0
														specific_data.sink_position = 2 --1: left, 2: center, 3: right	 
														specific_data.appliance_file = general_data.default_folders.hob_folder 
														end,
	geometry_function = recreate_sink,	 	--can use the same loading algorithm for the pure hob (which is always centered to the cabinet)	
	placement_function = placement_base, 	
	ui_update_function = ui_update_hob,
	organization_styles = {"intelli_doors",	
							"intelli_doors_and_drawer",
							"drawers",
							"intelli_doors_and_blind",
							"drawers_and_blind", 
							"open"},	

	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"both_vertical", "top_horizontal", "top_vertical", "top_solid", "no_top",},
}
cabinet_typelist.empty = 			
{									
	name = pyloc "Empty space",		
	row = 0x1,							
	default_data = {width = 600, kickboard_handle_left = "stop", kickboard_handle_right = "stop",},
	geometry_function = recreate_empty,	 	--can use the same loading algorithm for the pure hob (which is always centered to the cabinet)	
	placement_function = placement_base, 	
	ui_update_function = ui_update_empty,
	organization_styles = {},	
	back_styles = {},
	bottom_styles = {},
	top_styles = {},
}
cabinet_typelist.dishwasher = 			
{									
	name = pyloc "Dishwasher",		
	row = 0x1,							
	default_data = {width = 600, depth2 = 20},
	geometry_function = recreate_dishwasher,	 	--can use the same loading algorithm for the pure hob (which is always centered to the cabinet)	
	placement_function = placement_base, 	
	ui_update_function = ui_update_dishwasher,
	organization_styles = {"drop_down_door",},
	back_styles = {},
	bottom_styles = {},
	top_styles = {},
}
cabinet_typelist.fridge = 			
{									
	name = pyloc "Low fridge cabinet",		
	row = 0x1,							
	default_data = {width = 600, depth2 = 0},
	geometry_function = recreate_fridge,	 	--can use the same loading algorithm for the pure hob (which is always centered to the cabinet)	
	placement_function = placement_base, 	
	ui_update_function = ui_update_fridge,
	organization_styles = {"single_door",},
	back_styles = {},
	bottom_styles = {},
	top_styles = {},
}
