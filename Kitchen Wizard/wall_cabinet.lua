--wall cabinet with two doors

local function recreate_wall(general_data, specific_data)
	local cur_elements = {}
	
	local base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
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
	recreate_basic_front(general_data, specific_data, base_height, height, specific_data.width, shelf_depth, 0, coordinate_system, carcass_elements, cur_elements, {0,0,0})

	--Downlight
	--we need to flip the face light source uside down, so we simply use the -z direction. 
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width / 2 + 25, math.max(specific_data.depth - 150, specific_data.depth / 2) - 25, base_height - 10}, {w_axis = "-z"})
	set_part_attributes(new_elem, "light")
	table.insert(carcass_elements, new_elem)

	carcass_elements = pytha.create_group(carcass_elements, {name = attribute_list["carcass"].name})	
	table.insert(cur_elements, carcass_elements)
		
	specific_data.main_group = pytha.create_group(cur_elements)
	return specific_data.main_group
end

local function placement_wall(general_data, specific_data)
	specific_data.right_connection_point = {specific_data.width, specific_data.depth,0}
	specific_data.left_connection_point = {0, specific_data.depth,0}
	specific_data.right_direction = 0
	specific_data.left_direction = 0
end


local function ui_update_wall(general_data, soft_update)
	
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	if soft_update == false then 
		insert_specific_control(general_data, "width", nil)
		insert_specific_control(general_data, "height_top", nil)
		insert_specific_control(general_data, "depth", nil)
	end
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.wall = 				
{									
	name = pyloc "Wall cabinet",
	row = 0x2,
	default_data = function(general_data, specific_data) specific_data.width = 600
														specific_data.depth = general_data.depth_wall
					end,
	geometry_function = recreate_wall,
	placement_function = placement_wall, 
	ui_update_function = ui_update_wall,
	organization_styles = {"intelli_doors",  
							"lift_door",  
							"open",},
	back_styles = {"back_internal", 
					"back_external", 
					"back_rebate",},
	bottom_styles = {"bottom_internal",
					 "bottom_external",},
	top_styles = {"top_solid"},
}



