--Top shelf

local function recreate_top(general_data, specific_data)

	local cur_elements = {}
	specific_data.elem_handle_for_top = nil
	local base_height = general_data.benchtop_height
	local height = specific_data.height_top - base_height
	
	local loc_origin = {}
	local carcass_elements = {}
	local coordinate_system = {{1, 0, 0}, {0, 1, 0}, {0,0,1}}
	local door_to_carcass = door_carcass_calc(general_data, specific_data)

	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height
	local carcass_depth = specific_data.depth - door_to_carcass
	local groove_dist_back_off = groove_dist_back_off_calc(general_data, specific_data)
	local shelf_depth = calculate_back_y_offset(general_data, specific_data, door_to_carcass, carcass_depth, groove_dist_back_off)
	recreate_carcass_base(general_data, specific_data, base_height, height, specific_data.width, carcass_depth, coordinate_system, carcass_elements)
	--Back
	recreate_back(general_data, specific_data, height, specific_data.width, carcass_depth, base_height, carcass_elements)

	--Front
	recreate_basic_front(general_data, specific_data, base_height + general_data.gap, height - general_data.gap, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0})
		
	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)

	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end

local function placement_top(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, specific_data.depth,0}
	specific_data.left_connection_point = {0, specific_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end

local function ui_update_top(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	
	if soft_update == true then return end

	insert_specific_control(general_data, "width", nil)
	insert_specific_control(general_data, "height_top", nil)
	insert_specific_control(general_data, "depth", nil)
	
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.top = 				
{									
	name = pyloc "Top cabinet",
	row = 0x2,
	default_data = function(general_data, specific_data) specific_data.width = 600
														specific_data.depth = general_data.depth_wall
					end,
	geometry_function = recreate_top,
	placement_function = placement_top, 
	ui_update_function = ui_update_top,
	organization_styles = {"open",},
}



