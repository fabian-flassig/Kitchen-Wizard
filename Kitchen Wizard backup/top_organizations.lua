--Top types list

if top_style_list == nil then
    top_style_list = {}
end

--2 Horizontal Rails
local function ui_update_top_horizontal(general_data, soft_update)
    
	
end

local function create_top_horizontal(general_data, specific_data, width, depth, origin, coordinate_system, carcass_elements, return_handles)   
    local loc_origin = {origin[1], origin[2], origin[3]}
    
	local top_elem = nil
	
	if specific_data.fingerpull then
		top_elem = create_finger_rail(general_data, specific_data, width, loc_origin)
		table.insert(carcass_elements, top_elem)
		loc_origin[2] = origin[2] + general_data.finger_rail_thickness
	end

	loc_origin[3] = origin[3] - general_data.thickness
    --Front rail
	top_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin)
	set_part_attributes(top_elem, "cr_front", return_handles)

	table.insert(carcass_elements, top_elem)
	
	--Back rail
	loc_origin[2] = depth - general_data.width_rail
	top_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin)
	set_part_attributes(top_elem, "cr_back", return_handles)
	table.insert(carcass_elements, top_elem)
end

top_style_list.top_horizontal = {
	name = pyloc "Horizontal Rails",
	geometry_function = create_top_horizontal,
	ui_update_function = ui_update_top_horizontal,
}

--Back Horizontal, Front Vertical
local function ui_update_top_vertical(general_data, soft_update)
   
	
end

local function create_top_vertical(general_data, specific_data, width, depth, origin, coordinate_system, carcass_elements, return_handles)   
	local width_rail_vert = nil
	local top_elem = nil
    local loc_origin = {origin[1], origin[2], origin[3]}
	
	if specific_data.fingerpull then
		top_elem = create_finger_rail(general_data, specific_data, width, loc_origin)
		table.insert(carcass_elements, top_elem)
		loc_origin[2] = origin[2] + general_data.finger_rail_thickness
		width_rail_vert = general_data.finger_rail_width
	else
		width_rail_vert = general_data.width_vertical_rail
	end
    loc_origin[3] = origin[3] - width_rail_vert
    
    --Front rail
	top_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.thickness, width_rail_vert, loc_origin)
	set_part_attributes(top_elem, "cr_front", return_handles)

	table.insert(carcass_elements, top_elem)
	
	--Back rail
    loc_origin[2] = depth - general_data.width_rail
    loc_origin[3] = origin[3] - general_data.thickness
	top_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.width_rail, general_data.thickness, loc_origin)
	set_part_attributes(top_elem, "cr_back", return_handles)

	table.insert(carcass_elements, top_elem)
end

top_style_list.top_vertical = {
	name = pyloc "Vertical Rail",
	geometry_function = create_top_vertical,
	ui_update_function = ui_update_top_vertical,
}

--Back Vertical Rail
local function ui_update_top_vertical(general_data, soft_update)
	
end

local function create_top_back_vertical(general_data, specific_data, width, depth, origin, coordinate_system, carcass_elements, return_handles)   
	local width_rail_vert = nil
	local top_elem = nil
    local loc_origin = {origin[1], origin[2], origin[3]}
	
	--Back rail
    loc_origin[2] = depth - general_data.thickness
    loc_origin[3] = origin[3] - general_data.width_vertical_rail
	top_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.thickness, general_data.width_vertical_rail, loc_origin)
	set_part_attributes(top_elem, "cr_back", return_handles)

	table.insert(carcass_elements, top_elem)
end

top_style_list.top_back_vertical = {
	name = pyloc "Back Vertical Rail",
	geometry_function = create_top_back_vertical,
	ui_update_function = ui_update_top_vertical,
}

--Two Vertical Rails
local function ui_update_top_vertical(general_data, soft_update)
   
	
end

local function create_top_both_vertical(general_data, specific_data, width, depth, origin, coordinate_system, carcass_elements, return_handles)   
	local width_rail_vert = nil
	local top_elem = nil
    local loc_origin = {origin[1], origin[2], origin[3]}
	
	if specific_data.fingerpull then
		top_elem = create_finger_rail(general_data, specific_data, width, loc_origin)
		table.insert(carcass_elements, top_elem)
		loc_origin[2] = origin[2] + general_data.finger_rail_thickness
		width_rail_vert = general_data.finger_rail_width
	else
		width_rail_vert = general_data.width_vertical_rail
	end
    loc_origin[3] = origin[3] - width_rail_vert
    
    --Front rail
	top_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.thickness, width_rail_vert, loc_origin)
	set_part_attributes(top_elem, "cr_front", return_handles)

	table.insert(carcass_elements, top_elem)
	
	--Back rail
    loc_origin[2] = depth - general_data.thickness
	top_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.thickness, width_rail_vert, loc_origin)
	set_part_attributes(top_elem, "cr_back", return_handles)

	table.insert(carcass_elements, top_elem)
end

top_style_list.both_vertical = {
	name = pyloc "Two Vertical Rails",
	geometry_function = create_top_both_vertical,
	ui_update_function = ui_update_top_vertical,
}

--No Top
local function ui_update_no_top(general_data, soft_update)
end

local function create_no_top(general_data, specific_data, width, depth, origin, coordinate_system, carcass_elements)   
	--just an empty function. Currently used for sink
end

top_style_list.no_top = {
	name = pyloc "No Top",
	geometry_function = create_no_top,
	ui_update_function = ui_update_no_top,
}

--Solid Top
local function ui_update_top_solid(general_data, soft_update)
  
	
end

local function create_top_solid(general_data, specific_data, width, depth, origin, coordinate_system, carcass_elements, return_handles)   
    local loc_origin = {origin[1], origin[2], origin[3]}
	local top_elem = nil
	
	if specific_data.fingerpull then
		top_elem = create_finger_rail(general_data, specific_data, width, loc_origin)
		table.insert(carcass_elements, top_elem)
		loc_origin[2] = origin[2] + general_data.finger_rail_thickness
	end

    loc_origin[3] = origin[3] - general_data.thickness
    
	local top_elem = pytha.create_block(width - 2 * general_data.thickness, depth - origin[2], general_data.thickness, loc_origin)
	set_part_attributes(top_elem, "top", return_handles)

	table.insert(carcass_elements, top_elem)
	
end

top_style_list.top_solid = {
	name = pyloc "Solid Top",
	geometry_function = create_top_solid,
	ui_update_function = ui_update_top_solid,
}


-- Fingerpull Sides
function recreate_fingerpull(general_data, specific_data, width, new_elem, origin, return_handles)
	local subtract_elements = {}
	local loc_origin = {origin[1], origin[2], origin[3]}

	local converted_drawer_height_list = get_drawer_heights(general_data, specific_data, specific_data.height)
	--Elements to subtract for FP

--	loc_origin[1] = 0
--	loc_origin[2] = general_data.benchtop_over + general_data.door_thk + general_data.door_gap
	loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - general_data.finger_rail_width
	
	local sub_elem1 = pytha.create_block(width, general_data.finger_rail_thickness, general_data.finger_rail_width, loc_origin)
	table.insert(subtract_elements,sub_elem1)
	loc_origin[2] = origin[2] + general_data.finger_rail_thickness
	local sub_elem2 = pytha.create_block(width, 8, 13, loc_origin)
	table.insert(subtract_elements,sub_elem2)
    
   	if specific_data.front_style == "straight_drawers" then
		if specific_data.drawer_count > 1 then
			if specific_data.fingerpull then
				loc_origin[1] = 0
				loc_origin[2] = general_data.door_thickness + general_data.door_carcass_gap + general_data.top_over
				loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - specific_data.height

				for i = specific_data.drawer_count, 2, -1 do
					loc_origin[3] = loc_origin[3] + converted_drawer_height_list[i] - 57 - general_data.top_gap
					sub_elem1 = pytha.create_block(width, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
					set_part_attributes(sub_elem1, "fingerpull_rail", return_handles)
					table.insert(subtract_elements, sub_elem1)
					loc_origin[2] = loc_origin[2] + general_data.finger_rail_thickness
					sub_elem2 = pytha.create_block(width, 8, 13, loc_origin)
					table.insert(subtract_elements,sub_elem2)
					loc_origin[3] = loc_origin[3] + general_data.finger_rail_width + 10 - 13
					sub_elem2 = pytha.create_block(width, 8, 13, loc_origin)
					table.insert(subtract_elements,sub_elem2)
					loc_origin[3] = loc_origin[3] + 13 - 10 - general_data.finger_rail_width + 57 + general_data.top_gap
					loc_origin[2] = general_data.door_thickness + general_data.door_carcass_gap + general_data.top_over
				end	

			end

		end
	end

	if specific_data.front_style == "intelli_doors_and_drawer" then
		local drawer_height = get_drawer_heights(general_data, specific_data)
		if drawer_height ~= 0 then
			if specific_data.fingerpull then
				loc_origin[1] = 0
				loc_origin[2] = general_data.door_thickness + general_data.door_carcass_gap + general_data.top_over
				loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - drawer_height - general_data.finger_rail_width

				sub_elem1 = pytha.create_block(width, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
				set_part_attributes(sub_elem1, "fingerpull_rail", return_handles)
				table.insert(subtract_elements, sub_elem1)
				loc_origin[2] = loc_origin[2] + general_data.finger_rail_thickness
				sub_elem2 = pytha.create_block(width, 8, 13, loc_origin)
				table.insert(subtract_elements,sub_elem2)
				loc_origin[3] = loc_origin[3] + general_data.finger_rail_width + 10 - 13
				sub_elem2 = pytha.create_block(width, 8, 13, loc_origin)
				table.insert(subtract_elements,sub_elem2)
				loc_origin[3] = loc_origin[3] + 13 - 10 - general_data.finger_rail_width + 57 + general_data.top_gap
				loc_origin[2] = general_data.door_thickness + general_data.door_carcass_gap + general_data.top_over
			end
		end
	end

	new_elem = pytha.boole_part_difference(new_elem, subtract_elements)
	pytha.delete_element(subtract_elements)
    
    return new_elem
end

--Fingerpull Rail
function create_finger_rail(general_data, specific_data, width, origin, return_handles)
	local loc_origin = {origin[1], origin[2], origin[3]}

	loc_origin[1] = origin[1] - general_data.thickness
	loc_origin[3] = origin[3] - general_data.finger_rail_width

	local finger_elem = pytha.create_block(width, general_data.finger_rail_thickness, general_data.finger_rail_width, loc_origin)
	set_part_attributes(finger_elem, "fingerpull_rail", return_handles)
	return finger_elem
end