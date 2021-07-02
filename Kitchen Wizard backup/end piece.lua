--Blind End Side

function get_blind_end_row_height_base_height(general_data, specific_data)
	local base_height = 0
	local height = 0
	if specific_data.row == 0x1 then 
		height = general_data.benchtop_height - general_data.benchtop_thickness 
	elseif specific_data.row == 0x2 then 
		base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
		height = specific_data.height_top - base_height
	elseif specific_data.row == 0x3 then 
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

	specific_data.kickboard_handle_right = nil
	specific_data.kickboard_handle_left = nil
	specific_data.main_group = pytha.create_group(cur_elements)
	
	if specific_data.row == 0x1 then 
		--Benchtop
		create_straight_benchtop(general_data, specific_data, specific_data.width)
	end
	return specific_data.main_group
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


	
	local new_elem = pytha.create_block(general_data.thickness, specific_data.width2, height, loc_origin)
	set_part_attributes(new_elem, "inner_end")
	table.insert(carcass_elements, new_elem)
	
	loc_origin[1] = specific_data.width - general_data.thickness
	new_elem = pytha.create_block(general_data.thickness, specific_data.width2, height, loc_origin)
	set_part_attributes(new_elem, "inner_end")
	table.insert(carcass_elements, new_elem)

	--Front
	recreate_basic_front(general_data, specific_data, base_height, height, specific_data.width, specific_data.width2, general_data.top_gap, coordinate_system, carcass_elements, cur_elements, {0,0,0})

	if specific_data.row == 0x1 then 
		--Benchtop
		create_straight_benchtop(general_data, specific_data, specific_data.width)
	end
	specific_data.kickboard_handle_right = nil
	specific_data.kickboard_handle_left = nil
	if specific_data.row ~= 0x2 then 	
		--Kickboard
		create_straight_kickboard(general_data, specific_data, base_height, specific_data.width, cur_elements)
	end
	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end


local function placement_blind(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, specific_data.depth,0}
	specific_data.left_connection_point = {0, specific_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
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
					shelf_count = 1},
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
					shelf_count = 1},
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
					shelf_count = 1},		
	geometry_function = recreate_filler,
	placement_function = placement_blind, 	
	ui_update_function = ui_update_blind,
	organization_styles = {"blind"},
}

