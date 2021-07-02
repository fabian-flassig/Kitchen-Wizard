--Back types list

if back_style_list == nil then
    back_style_list = {}
end

if bottom_style_list == nil then
    bottom_style_list = {}
end

--Internal
local function ui_update_back_internal(general_data, soft_update)

end

local function create_back_internal(general_data, specific_data, width, height, origin, coordinate_system, carcass_elements)   
    local loc_origin = {origin[1], origin[2], origin[3]}

    --specific_data.bottom_style = "bottom_internal"
    loc_origin[1] = origin[1] + general_data.thickness
    --loc_origin[2] = origin[2] + specific_data.depth - general_data.thickness
    loc_origin[3] = origin[3]

    if specific_data.bottom_style == "bottom_external" then
        height = height - general_data.thickness
        loc_origin[3] = origin[3] + general_data.thickness
    end    

    local new_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.thickness, height, loc_origin)
	set_part_attributes(new_elem, "back")
    table.insert(carcass_elements, new_elem)
end

back_style_list.back_internal = {
	name = pyloc "Internal",
	geometry_function = create_back_internal,
	ui_update_function = ui_update_back_internal,
}

--External
local function ui_update_back_external(general_data, soft_update)

end

local function create_back_external(general_data, specific_data, width, height, origin, coordinate_system, carcass_elements)   
    local loc_origin = {origin[1], origin[2], origin[3]}

    loc_origin[1] = origin[1]
    --loc_origin[2] = origin[2] + specific_data.depth - general_data.thickness
    loc_origin[3] = origin[3]

    local new_elem = pytha.create_block(width, general_data.thickness, height, loc_origin)
	set_part_attributes(new_elem, "back")
    table.insert(carcass_elements, new_elem)
end

back_style_list.back_external = {
	name = pyloc "External",
	geometry_function = create_back_external,
	ui_update_function = ui_update_back_external,
}


--Rebate
local function ui_update_back_rebate(general_data, soft_update)

end

local function create_back_rebate(general_data, specific_data, width, height, origin, coordinate_system, carcass_elements)   
    local loc_origin = {origin[1], origin[2], origin[3]}

    loc_origin[1] = origin[1] + general_data.thickness - 5
    --loc_origin[2] = origin[2] + specific_data.depth - general_data.thickness
    loc_origin[3] = origin[3] + general_data.thickness - 5

    local new_elem = pytha.create_block(width - 2 * general_data.thickness + 2*5, general_data.thickness, height - general_data.thickness + 5, loc_origin)
	set_part_attributes(new_elem, "back")
    table.insert(carcass_elements, new_elem)
end

back_style_list.back_rebate = {
	name = pyloc "Rebate",
	geometry_function = create_back_rebate,
	ui_update_function = ui_update_back_rebate,
}

back_style_list.back_none = {
	name = pyloc "None",
	geometry_function = function () end,
	ui_update_function = function () end,
}

bottom_style_list.bottom_external = {
	name = pyloc "Bottom through",
	--geometry_function = create_back_rebate,
	--ui_update_function = ui_update_back_rebate,
}

bottom_style_list.bottom_internal = {
	name = pyloc "Sides through",
	--geometry_function = create_back_rebate,
	--ui_update_function = ui_update_back_rebate,
}