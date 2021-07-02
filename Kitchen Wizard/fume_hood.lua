
local depth = 500

local function recreate_hood(general_data, specific_data)
	local cur_elements = {}
	
	local base_height = general_data.wall_to_base_spacing + general_data.benchtop_height
	local height = specific_data.height_top - base_height
	local intake_thickness = 53
	local chimney_width = 260
	local chimney_depth = 250
	
	local loc_origin= {}
	loc_origin[1] = 0
	loc_origin[2] = 0
	loc_origin[3] = base_height

	--Intake
	new_elem = pytha.create_block(specific_data.width, depth, intake_thickness, loc_origin)
	set_part_attributes(new_elem, "fume_hood")
	table.insert(cur_elements, new_elem)
	--Chimney
	loc_origin[1] = (specific_data.width - chimney_width) / 2
	loc_origin[2] = depth - chimney_depth
	loc_origin[3] = base_height + intake_thickness
	new_elem = pytha.create_block(chimney_width, chimney_depth, height - intake_thickness, loc_origin)
	set_part_attributes(new_elem, "fume_hood")
	table.insert(cur_elements, new_elem)
	

		
	--Downlight
	--we need to flip the face light source uside down, so we simply use the -z direction. 
	new_elem = pytha.create_rectangle(50, 50, {100, depth - 150 - 25, base_height - 10}, {w_axis = "-z"})
	set_part_attributes(new_elem, "light")
	table.insert(cur_elements, new_elem)
	new_elem = pytha.create_rectangle(50, 50, {specific_data.width - 50, depth - 150 - 25, base_height - 10}, {w_axis = "-z"})
	set_part_attributes(new_elem, "light")
	table.insert(cur_elements, new_elem)
	
	specific_data.aux_values.main_group = pytha.create_group(cur_elements)
	
	return specific_data.aux_values.main_group
end

local function placement_hood(general_data, specific_data)
	specific_data.aux_values.right_connection_point = {specific_data.width, depth,0}
	specific_data.aux_values.left_connection_point = {0, depth,0}
	specific_data.aux_values.right_direction = 0
	specific_data.aux_values.left_direction = 0
end


local function ui_update_hood(general_data, soft_update)

	if soft_update == true then return end

	insert_specific_control(general_data, "height_top", nil)
		
end


--this part needs to be at the end of the file, otherwise the geometry and ui functions are stil nil 
if cabinet_typelist == nil then			
	cabinet_typelist = {}
end
cabinet_typelist.hood = 				
{									
	name = pyloc "Fume hood",
	row = 0x2,
	default_data = {width = 600,},
	geometry_function = recreate_hood,
	placement_function = placement_hood, 
	ui_update_function = ui_update_hood,
	organization_styles = {},
}



