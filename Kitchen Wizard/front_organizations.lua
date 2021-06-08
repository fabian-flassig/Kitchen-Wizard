--This file includes some particular front styles for straight doors


local single_drawer_setup_list = {{175}, {125}, {75}, {100}, {150},}

local multi_drawer_setup_list = {				-- I guess for the kitchen its better to count the drawers from the top...
							{125,-1,-1},
							{125,125,-1,-1},
							{125,250,-1},
							{-1,-1,-1},}

if organization_style_list == nil then			
	organization_style_list = {}
end

local function door_side_soft_update(general_data, specific_data)
	door_side = get_control_handle("door_side")
	if door_side ~= nil then 
		if specific_data.width - 2 * general_data.gap > 0 then
			if specific_data.width > general_data.max_door_width then
				door_side:disable_control()
			else 
				door_side:enable_control()
			end
		else 
			door_side:enable_control()
		end
	end	
end

function fill_drawer_height_list(general_data, specific_data, ctrl_id)

	local current_selection = 0
	if #organization_style_list[specific_data.front_style].drawer_list > 0 then 
		ctrl_id:reset_content()
		for i, k in pairs(organization_style_list[specific_data.front_style].drawer_list) do
			local text = ""
			for j,l in pairs(k) do
				if l > 0 then 
					text = text .. pyui.format_length(l)
				else 
					text = text .. pyui.format_number(l)
				end
				if j ~= #k then
					text = text .. ","
				end
			end
			ctrl_id:insert_control_item(text)
			if text == specific_data.drawer_height_list then 
				current_selection = i
			end 
		end
		if specific_data.drawer_height_list == "" and current_selection == 0 then 
			local text = ""
			current_selection = 1
			for j,l in pairs(organization_style_list[specific_data.front_style].drawer_list[current_selection]) do
				if l > 0 then 
					text = text .. pyui.format_length(l)
				else 
					text = text .. pyui.format_number(l)
				end
				if j ~= #organization_style_list[specific_data.front_style].drawer_list[current_selection] then
					text = text .. ","
				end
			end
			specific_data.drawer_height_list = text
		end
		
		if current_selection == 0 then 
			ctrl_id:set_control_text(specific_data.drawer_height_list)
		else
			ctrl_id:set_control_selection(current_selection)
		end
	
	end
end


function create_fixed_shelf(general_data, specific_data, width, shelf_depth, origin)
	loc_origin = {}
	loc_origin[1] = origin[1] + general_data.thickness + general_data.fixed_shelf_gap
	loc_origin[2] = origin[2] + general_data.setback_fixed_shelves
	loc_origin[3] = origin[3]
	new_elem = pytha.create_block(width - 2 * general_data.thickness - 2 * general_data.fixed_shelf_gap, shelf_depth - general_data.setback_fixed_shelves, general_data.thickness, loc_origin)
	set_part_attributes(new_elem, "fixed_shelf")
	return new_elem
end

local function create_open_front(general_data, specific_data, width, height, shelf_depth, carcass_elements, shelf_count)
	local loc_origin = {0,0,0}	
	local extra_length = 0
	local depth = shelf_depth - general_data.setback_shelves

	if specific_data.this_type == "blindcorner_tkh" then
		--[[ depth = shelf_depth - 5
		extra_length = specific_data.depth2 + 20
		if specific_data.door_rh then
			loc_origin[1] = general_data.thickness + general_data.shelf_gap
		else
			loc_origin[1] = - specific_data.depth - 20 + general_data.thickness + general_data.shelf_gap + specific_data.depth - specific_data.depth2
		end
		loc_origin[2] = general_data.setback_shelves + 5 ]]
	else
		loc_origin[1] = general_data.thickness + general_data.shelf_gap
		loc_origin[2] = general_data.setback_shelves
	end

	for i = 1, shelf_count, 1 do
		loc_origin[3] = i * (height - general_data.thickness) / (shelf_count + 1)
		local new_elem = pytha.create_block(width - 2 * general_data.thickness - 2 * general_data.shelf_gap + extra_length, depth, general_data.thickness, loc_origin)
		set_part_attributes(new_elem, "adjustable_shelf")
	
		table.insert(carcass_elements, new_elem)
	end
end
local function create_open_front_call(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, base_origin)
	create_open_front(general_data, specific_data, width, height, shelf_depth, carcass_elements, specific_data.shelf_count)
end

--TKH Base Open
local function ui_update_open_front(general_data, soft_update)
	if soft_update == false then 
		insert_specific_control(general_data, "shelf_count_0_20", nil)
	end
end

--TKH Door
function ui_update_intelli_doors(general_data, soft_update)

	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	if soft_update == false then 
		insert_specific_control(general_data, "door_side", nil)	
	end
	door_side_soft_update(general_data, specific_data)
end
function ui_update_intelli_doors_shelves(general_data, soft_update)	
	ui_update_open_front(general_data, soft_update)
	ui_update_intelli_doors(general_data, soft_update)
end
local function create_intelli_doors(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local door_height = height - top_gap
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap

	if specific_data.fingerpull then
		door_height = door_height - 22
	end

	local door_elem = nil
	local elevation_elem = nil
	local plan_elem = nil

	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = general_data.gap
		loc_origin[2] = - door_to_carcass
		loc_origin[3] = 0

		if width > general_data.max_door_width then	--create two doors
			local door_width = width / 2 - 2 * general_data.gap
		--left handed door
			loc_origin[1] = general_data.gap
			create_door_tkh(general_data, specific_data, door_width, door_height, loc_origin, false, nil, ext_elements, base_origin)
		--right handed door
			loc_origin[1] = width - door_width - general_data.gap
			create_door_tkh(general_data, specific_data, door_width, door_height, loc_origin, true, nil, ext_elements, base_origin)
		else
		--only one door 
			loc_origin[1] = general_data.gap
			create_door_tkh(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, nil, ext_elements, base_origin)

		end
	end
end
local function create_intelli_doors_shelves(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)

	create_open_front(general_data, specific_data, width, height, shelf_depth, carcass_elements, specific_data.shelf_count)
	create_intelli_doors(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
end



function get_drawer_heights(general_data, specific_data, total_height)
	local total_rel_factor = 0
	local total_abs_length = 0
	local converted_heights = {}
	local heights_number = {pyui.parse_number(specific_data.drawer_height_list)}
	local raw_heights_length = {pyui.parse_length(specific_data.drawer_height_list)}
	if total_height == nil then return raw_heights_length[1] or 0 end
	for i,k in pairs(heights_number) do
		if k > 0 then 
			heights_number[i] = raw_heights_length[i]
		end
	end
	local relative_exists = 0
	for i = 1, specific_data.drawer_count, 1 do
		if heights_number[i] == nil then heights_number[i] = -1 end
		if math.abs(heights_number[i]) < 1e-8 then
			heights_number[i] = -1	--any zero value is set to -1
		end
		if relative_exists == 0 and i == specific_data.drawer_count then 
			heights_number[i] = -1
		end
		if heights_number[i] < 0 then
			relative_exists = 1
			total_rel_factor = total_rel_factor + math.abs(heights_number[i])
		else
			if total_abs_length + heights_number[i] >= total_height - (i - 1) * general_data.gap then		--before the total height get too big
				for j = i, #heights_number, 1 do
					heights_number[j] = -1
				end
				total_rel_factor = total_rel_factor + math.abs(heights_number[i])
			else 
				total_abs_length = total_abs_length + heights_number[i]
			end
		end
	end
	--in case all drawers have absolute heights, the last is being set to relative
	if total_rel_factor == 0 then 
		heights_number[specific_data.drawer_count] = -1
		total_rel_factor = 1
	end
	for i = 1, specific_data.drawer_count, 1 do
		if heights_number[i] > 0 then 
			table.insert(converted_heights, heights_number[i])
		else 
			relative_exists = 1
			table.insert(converted_heights, (total_height - total_abs_length - (specific_data.drawer_count - 1) * general_data.gap) * math.abs(heights_number[i]) / total_rel_factor)
		end
	end
	return converted_heights
end

local function ui_update_drawers_tkh(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	if soft_update == true then return end
	
	insert_specific_control(general_data, "drawer_count_1_20", nil)
	
	insert_specific_control(general_data, "drawer_height_list", pyloc "Drawer heights")
	
end
local function create_drawers_tkh(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, first_blind, base_origin)
	local loc_origin = {0,0,0}	
	local door_height = height - top_gap
	local converted_drawer_height_list = get_drawer_heights(general_data, specific_data, door_height)
	local drawer_elem = nil
	local elevation_elem = nil
	local plan_elem = nil
	local blind_elem = nil


	--Drawer
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = general_data.gap
		loc_origin[2] = - general_data.door_carcass_gap - general_data.door_thickness
		loc_origin[3] = 0
		
		local plan_origin = {loc_origin[1], loc_origin[2], loc_origin[3]}
		plan_origin[1] = loc_origin[1] + (width - 2 * general_data.gap) / 2
		plan_origin[2] = loc_origin[2] - general_data.top_over - 80 - 30 * (specific_data.drawer_count - 1) - 5
		if first_blind == false or specific_data.drawer_count > 1 then 
			plan_elem = pytha.create_polygon({{plan_origin[1], plan_origin[2], plan_origin[3]},						--Arrow plan drawing
												{plan_origin[1] - 25, plan_origin[2], plan_origin[3]},
												{plan_origin[1] - 25, plan_origin[2] - 50, plan_origin[3]},
												{plan_origin[1] - 50, plan_origin[2] - 50, plan_origin[3]},
												{plan_origin[1], plan_origin[2] - 100, plan_origin[3]},
												{plan_origin[1] + 50, plan_origin[2] - 50, plan_origin[3]},
												{plan_origin[1] + 25, plan_origin[2] - 50, plan_origin[3]},
												{plan_origin[1] + 25, plan_origin[2], plan_origin[3]}})
			set_part_attributes(plan_elem, "floor_plan")
			table.insert(ext_elements, plan_elem)
		end
		plan_origin[1] = loc_origin[1] + 50 * (specific_data.drawer_count - 1)
		plan_origin[2] = loc_origin[2] - general_data.top_over - 80 - 30 * (specific_data.drawer_count - 1)
		
		for i = specific_data.drawer_count, 1, -1 do
			if i == 1 and first_blind then
				drawer_elem, blind_elem = create_blind_front(general_data, specific_data, width - 2 * general_data.gap, 
												converted_drawer_height_list[i], 
												loc_origin, ext_elements)
			else 
				drawer_elem, elevation_elem = create_drawer_tkh(general_data, specific_data, width - 2 * general_data.gap, shelf_depth,  
										converted_drawer_height_list[i], loc_origin, ext_elements, base_origin)
				pytha.set_element_name(drawer_elem, string.format("%s_%d", attribute_list["drawer"].name, i))

				loc_origin[3] = loc_origin[3] + converted_drawer_height_list[i] + general_data.gap
				plan_elem = pytha.create_polygon({{plan_origin[1], plan_origin[2], plan_origin[3]},
												{plan_origin[1], plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap - 2 * (i-1) * 50, plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap - 2 * (i-1) * 50, plan_origin[2], plan_origin[3]}})
				plan_origin[1] = plan_origin[1] - 50
				plan_origin[2] = plan_origin[2] + 30
				set_part_attributes(plan_elem, "floor_plan")
				table.insert(ext_elements, plan_elem)
			end
		end
		
	end

	if specific_data.drawer_count > 1 then
		if specific_data.fingerpull then
			loc_origin = {0,0,0}


			for i = specific_data.drawer_count, 2, -1 do
				loc_origin[3] = loc_origin[3] + converted_drawer_height_list[i] - 57 - general_data.top_gap
				new_elem = pytha.create_block(width, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
				set_part_attributes(new_elem, "fingerpull_rail")
				table.insert(carcass_elements, new_elem)
				loc_origin[1] = loc_origin[1] + general_data.thickness
				loc_origin[2] = loc_origin[2] + general_data.finger_rail_thickness
				new_elem = pytha.create_block(width - 2 * general_data.thickness, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
				set_part_attributes(new_elem, "cr_front")
				table.insert(carcass_elements, new_elem)
				loc_origin[3] = loc_origin[3] + 57 + general_data.top_gap
				loc_origin[1] = loc_origin[1] - general_data.thickness
				loc_origin[2] = loc_origin[2] - general_data.finger_rail_thickness
			end	

		end

	end

	local rp_pos = {0, general_data.door_carcass_gap, height}
	if drawer_elem ~= nil then
		pytha.create_element_ref_point(drawer_elem, rp_pos)
		rp_pos[1] = rp_pos[1] + width
		pytha.create_element_ref_point(drawer_elem, rp_pos)
		rp_pos[1] = 0
		rp_pos[3] = 0
		pytha.create_element_ref_point(drawer_elem, rp_pos)
		rp_pos[3] = height
		rp_pos[2] = - general_data.door_thickness
		pytha.create_element_ref_point(drawer_elem, rp_pos)
	end
end


local function create_drawers_call(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	create_drawers_tkh(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, false, base_origin)
end


local function ui_update_intelli_doors_drawer_tkh(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	if soft_update == false then 
		insert_specific_control(general_data, "shelf_count_0_20", nil)
		insert_specific_control(general_data, "drawer_height_list", nil)
		insert_specific_control(general_data, "door_side", nil)	
	end
	door_side_soft_update(general_data, specific_data)

end
local function create_intelli_doors_drawer_tkh(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local door_height = height - drawer_height - top_gap


	if drawer_height > 0 then
		door_height = door_height - general_data.gap
	end


	create_intelli_doors(general_data, specific_data, width, door_height + top_gap, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	
	if drawer_height > 0 then
		local drawer_elem = nil
		local elevation_elem = nil
		local plan_elem = nil
		loc_origin[3] = loc_origin[3] + door_height + general_data.gap
		loc_origin[2] = - general_data.door_carcass_gap - general_data.door_thickness
		loc_origin[1] = general_data.gap

		drawer_elem, elevation_elem = create_drawer_tkh(general_data, specific_data, width - 2 * general_data.gap, shelf_depth,
										drawer_height, loc_origin, ext_elements, base_origin)
		pytha.set_element_name(drawer_elem, string.format("%s_%d", attribute_list["drawer"].name, 1))


		loc_origin[1] = general_data.gap
		local plan_origin = {loc_origin[1], loc_origin[2], loc_origin[3]}
		plan_origin[1] = loc_origin[1] + (width - 2 * general_data.gap) / 2
		plan_origin[2] = loc_origin[2] - 50 - 5

		plan_elem = pytha.create_polygon({{plan_origin[1], plan_origin[2], plan_origin[3]},						--Arrow plan drawing
											{plan_origin[1] - 25, plan_origin[2], plan_origin[3]},
											{plan_origin[1] - 25, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1] - 50, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1], plan_origin[2] - 100, plan_origin[3]},
											{plan_origin[1] + 50, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1] + 25, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1] + 25, plan_origin[2], plan_origin[3]}})
		set_part_attributes(plan_elem, "floor_plan")
		table.insert(ext_elements, plan_elem)
		plan_origin[1] = loc_origin[1]
		plan_origin[2] = plan_origin[2] + 5
		plan_elem = pytha.create_polygon({{plan_origin[1], plan_origin[2], plan_origin[3]},
												{plan_origin[1], plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap, plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap, plan_origin[2], plan_origin[3]}})
		set_part_attributes(plan_elem, "floor_plan")
		table.insert(ext_elements, plan_elem)

		if specific_data.fingerpull then
			loc_origin[1] = 0
			loc_origin[2] = general_data.door_thickness + general_data.door_carcass_gap + general_data.top_over
			loc_origin[3] = height - drawer_height - general_data.finger_rail_width
	
			new_elem = pytha.create_block(specific_data.width, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
			set_part_attributes(new_elem, "fingerpull_rail")
			table.insert(carcass_elements, new_elem)
			loc_origin[1] = loc_origin[1] + general_data.thickness
			loc_origin[2] = loc_origin[2] + general_data.finger_rail_thickness
			new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
			set_part_attributes(new_elem, "cr_front")
			table.insert(carcass_elements, new_elem)
		else
			loc_origin[1] = 0
			loc_origin[2] = 0
			loc_origin[3] = height - drawer_height - top_gap - (general_data.thickness + general_data.gap) / 2
			new_elem = create_fixed_shelf(general_data, specific_data, width, shelf_depth, loc_origin)
			table.insert(carcass_elements, new_elem)
		end	

	end
end
local function create_intelli_doors_drawer_shelves(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local door_height = height - drawer_height - top_gap

	if drawer_height > 0 then
		door_height = door_height - general_data.gap
	end

	create_open_front(general_data, specific_data, width, door_height, shelf_depth, carcass_elements, specific_data.shelf_count)
	create_intelli_doors_drawer_tkh(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)

end




 local function create_intelli_doors_blind(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local door_height = height - drawer_height - top_gap


	if drawer_height > 0 then
		door_height = door_height - general_data.gap
	end

	create_open_front(general_data, specific_data, width, door_height, shelf_depth, carcass_elements, specific_data.shelf_count)

	create_intelli_doors(general_data, specific_data, width, door_height + top_gap, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	
	if drawer_height > 0 then
		local drawer_elem = nil
		local blind_elem = nil
		local plan_elem = nil
		loc_origin[3] = loc_origin[3] + door_height + general_data.gap
		loc_origin[2] = - general_data.door_carcass_gap - general_data.door_thickness
		loc_origin[1] = general_data.gap
		local plan_origin = {loc_origin[1], loc_origin[2], loc_origin[3]}

		drawer_elem, blind_elem = create_blind_front(general_data, specific_data, width - 2 * general_data.gap, 
										drawer_height, loc_origin, ext_elements)
										
		plan_origin[1] = loc_origin[1]
		plan_origin[2] = plan_origin[2] + 5
		plan_elem = pytha.create_polygon({{plan_origin[1], plan_origin[2], plan_origin[3]},
												{plan_origin[1], plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap, plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap, plan_origin[2], plan_origin[3]}})
		set_part_attributes(plan_elem, "floor_plan")
		table.insert(ext_elements, plan_elem)

		--[[ if specific_data.fingerpull then
			loc_origin[1] = 0
			loc_origin[2] = general_data.door_thickness + general_data.door_carcass_gap + general_data.top_over
			loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - drawer_height - general_data.finger_rail_width
	
			new_elem = pytha.create_block(specific_data.width, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
			set_part_attributes(new_elem, "fingerpull_rail")
			table.insert(carcass_elements, new_elem)
			loc_origin[1] = loc_origin[1] + general_data.thickness
			loc_origin[2] = loc_origin[2] + general_data.finger_rail_thickness
			new_elem = pytha.create_block(specific_data.width - 2 * general_data.thickness, general_data.finger_rail_thickness, general_data.finger_rail_width + 10, loc_origin)
			set_part_attributes(new_elem, "cr_front")
			table.insert(carcass_elements, new_elem)
		else
			loc_origin[1] = general_data.thickness + 1
			loc_origin[2] = 0
			loc_origin[3] = general_data.benchtop_height - general_data.benchtop_thickness - drawer_height - 2 * top_gap - 5
			new_elem = pytha.create_block(width - 2 * general_data.thickness - 2, specific_data.depth - general_data.door_thickness - general_data.door_carcass_gap - general_data.top_over - general_data.thickness, general_data.thickness, loc_origin)
			set_part_attributes(new_elem, "fixed_shelf")
			table.insert(carcass_elements, new_elem)
		end	 ]]

	end
end
local function ui_update_intelli_doors_blind(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	if soft_update == false then 
		insert_specific_control(general_data, "shelf_count_0_20", nil)
		insert_specific_control(general_data, "drawer_height_list", nil)
		insert_specific_control(general_data, "door_side", nil)	
	end
	door_side_soft_update(general_data, specific_data)
	
end

local function create_drawers_and_blind(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	create_drawers_tkh(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, true, base_origin)
end


local function ui_oven_and_blind(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	
	if soft_update == true then return end
end


local function create_oven_and_blind(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	create_drawers_tkh(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, true, base_origin)
end


function ui_update_single_door(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]
	
	if soft_update == true then return end
	
	insert_specific_control(general_data, "door_side", nil)
end
local function create_single_door(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local door_height = height - top_gap
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap

	if specific_data.fingerpull then
		door_height = door_height - 22
	end

	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = general_data.gap
		loc_origin[2] = - door_to_carcass
		loc_origin[3] = 0
		create_door_tkh(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, specific_data.door_rh, nil, ext_elements, base_origin)

	end
end
local function create_lift_door(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local door_height = height - top_gap
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap

	if specific_data.fingerpull then
		door_height = door_height - 22
	end

	create_open_front(general_data, specific_data, width, height, shelf_depth, carcass_elements, specific_data.shelf_count)
	
	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = general_data.gap
		loc_origin[2] = - door_to_carcass
		loc_origin[3] = 0
		create_lift_door_base(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, ext_elements, base_origin)

	end
end

local function ui_single_door_and_drawer(general_data, soft_update)
	ui_update_single_door(general_data, soft_update)
	local specific_data = general_data.cabinet_list[general_data.current_cabinet]

	if soft_update == true then return end

	
	fill_drawer_height_list(general_data, specific_data)
	--controls.drawer_height_list:set_control_selection(1)
end
local function create_single_door_and_drawer(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local drawer_height = get_drawer_heights(general_data, specific_data)
	local door_height = height - drawer_height - top_gap

	if drawer_height > 0 then
		door_height = door_height - general_data.gap
	end

	create_single_door(general_data, specific_data, width, door_height + top_gap, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	
	if drawer_height > 0 then
		local drawer_elem = nil
		local elevation_elem = nil
		local plan_elem = nil
		loc_origin[3] = loc_origin[3] + door_height + general_data.gap
		loc_origin[2] = general_data.door_carcass_gap - general_data.door_thickness
		loc_origin[1] = general_data.gap

		drawer_elem, elevation_elem = create_drawer_tkh(general_data, specific_data, width - 2 * general_data.gap, shelf_depth,
										drawer_height, 
										loc_origin, ext_elements, base_origin)
		pytha.set_element_name(drawer_elem, string.format("%s_%d", attribute_list["drawer"].name, 1))

		loc_origin[1] = general_data.gap
		local plan_origin = {loc_origin[1], loc_origin[2], loc_origin[3]}
		plan_origin[1] = loc_origin[1] + (width - 2 * general_data.gap) / 2
		plan_origin[2] = loc_origin[2] - 50 - 5

		plan_elem = pytha.create_polygon({{plan_origin[1], plan_origin[2], plan_origin[3]},						--Arrow plan drawing
											{plan_origin[1] - 25, plan_origin[2], plan_origin[3]},
											{plan_origin[1] - 25, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1] - 50, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1], plan_origin[2] - 100, plan_origin[3]},
											{plan_origin[1] + 50, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1] + 25, plan_origin[2] - 50, plan_origin[3]},
											{plan_origin[1] + 25, plan_origin[2], plan_origin[3]}})
		set_part_attributes(plan_elem, "floor_plan")
		table.insert(ext_elements, plan_elem)
		plan_origin[1] = loc_origin[1]
		plan_origin[2] = plan_origin[2] + 5
		plan_elem = pytha.create_polygon({{plan_origin[1], plan_origin[2], plan_origin[3]},
												{plan_origin[1], plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap, plan_origin[2] - 5, plan_origin[3]},
												{plan_origin[1] + width - 2 * general_data.gap, plan_origin[2], plan_origin[3]}})
		set_part_attributes(plan_elem, "floor_plan")
		table.insert(ext_elements, plan_elem)

		loc_origin[1] = 0
		loc_origin[2] = 0
		loc_origin[3] = height - drawer_height - top_gap - (general_data.thickness + general_data.gap) / 2
		new_elem = create_fixed_shelf(general_data, specific_data, width, shelf_depth, loc_origin)
		table.insert(carcass_elements, new_elem)
	end
end


function ui_update_drop_down_door(general_data, soft_update)
	
	if soft_update == true then return end
	
end

local function create_drop_down_door(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	local loc_origin = {0,0,0}	
	local door_height = height - top_gap
	local door_to_carcass = general_data.door_thickness + general_data.door_carcass_gap

	if specific_data.fingerpull then
		door_height = door_height - 22
	end
	--Door
	if width - 2 * general_data.gap > 0 then
		loc_origin[1] = general_data.gap
		loc_origin[2] = - door_to_carcass
		loc_origin[3] = 0
		create_dropdown_door(general_data, specific_data, width - 2 * general_data.gap, door_height, loc_origin, ext_elements, base_origin)
	end
end


function ui_update_oven_drawers_intelli_doors(general_data, soft_update)
	ui_update_drawers_tkh(general_data, soft_update)
	ui_update_intelli_doors_shelves(general_data, soft_update)
	if soft_update == true then return end
end

local function create_intelli_doors_2_shelves(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)

	create_open_front(general_data, specific_data, width, height, shelf_depth, carcass_elements, 2)
	create_intelli_doors(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
end
local function create_intelli_doors_1_shelves(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)

	create_open_front(general_data, specific_data, width, height, shelf_depth, carcass_elements, 1)
	create_intelli_doors(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
end
local function create_intelli_doors_0_shelves(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
	create_intelli_doors(general_data, specific_data, width, height, shelf_depth, top_gap, carcass_elements, ext_elements, base_origin)
end


organization_style_list.open = {
	name = pyloc "Open",
	geometry_function = create_open_front_call,
	ui_update_function = ui_update_open_front,
}

organization_style_list.intelli_doors = {
	name = pyloc "Door",
	geometry_function = create_intelli_doors_shelves,
	ui_update_function = ui_update_intelli_doors_shelves,
}

organization_style_list.intelli_doors_no_shelves = {
	name = pyloc "Door",
	geometry_function = create_intelli_doors_0_shelves,
	ui_update_function = ui_update_intelli_doors,
}
organization_style_list.drawers = {
	name = pyloc "Drawers",
	geometry_function = create_drawers_call,
	ui_update_function = ui_update_drawers_tkh,
	drawer_list = multi_drawer_setup_list,
}
organization_style_list.intelli_doors_and_drawer = {
	name = pyloc "Drawer and Doors",
	geometry_function = create_intelli_doors_drawer_shelves,
	ui_update_function = ui_update_intelli_doors_drawer_tkh,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.blind = {
	name = pyloc "Blind",
	geometry_function = create_oven_and_blind,
	ui_update_function = ui_oven_and_blind,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.drawers_and_blind = {
	name = pyloc "Blind and Drawers",
	geometry_function = create_drawers_and_blind,
	ui_update_function = ui_update_drawers_tkh,
	drawer_list = multi_drawer_setup_list,
}
organization_style_list.intelli_doors_and_blind = {
	name = pyloc "Blind and Doors",
	geometry_function = create_intelli_doors_blind,
	ui_update_function = ui_update_intelli_doors_blind,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.single_door = {
	name = pyloc "Door",
	geometry_function = create_single_door,
	ui_update_function = ui_update_single_door,
}
organization_style_list.single_door_and_drawer = {
	name = pyloc "Drawer and Doors",
	geometry_function = create_single_door_and_drawer,
	ui_update_function = ui_single_door_and_drawer,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.drop_down_door = {
	name = pyloc "Drop Down Door",
	geometry_function = create_drop_down_door,
	ui_update_function = ui_update_drop_down_door,
}
organization_style_list.split_drawers_intelli_doors = {
	name = pyloc "Drawers and Doors",
	geometry_function = {create_drawers_call, create_intelli_doors_2_shelves},
	ui_update_function = ui_update_oven_drawers_intelli_doors,
	drawer_list = multi_drawer_setup_list,
}

organization_style_list.split_intelli_doors_doors = {
	name = pyloc "Doors and Doors",
	geometry_function = {create_intelli_doors_1_shelves, create_intelli_doors_shelves},
	ui_update_function = ui_update_intelli_doors_shelves,
	drawer_list = multi_drawer_setup_list,
}

organization_style_list.lift_door = {
	name = pyloc "Lift door",
	geometry_function = create_lift_door,
	ui_update_function = ui_update_open_front,
}

organization_style_list.fridge_lift = {
	name = pyloc "Lift door above",
	geometry_function = {nil, create_lift_door,},
	ui_update_function = ui_update_open_front,
}

organization_style_list.fridge_doors = {
	name = pyloc "Doors above",
	geometry_function = {nil, create_intelli_doors_shelves,},
	ui_update_function = ui_update_intelli_doors_shelves,
}
organization_style_list.drawer_fridge = {
	name = pyloc "Drawer below",
	geometry_function = {create_drawers_call, nil},
	ui_update_function = ui_update_drawers_tkh,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.doors_fridge = {
	name = pyloc "Doors below",
	geometry_function = {create_intelli_doors_shelves, nil},
	ui_update_function = ui_update_intelli_doors_shelves,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.drawer_fridge_lift = {
	name = pyloc "Drawer and Lift Door",
	geometry_function = {create_drawers_call, create_lift_door},
	ui_update_function = ui_update_drawers_tkh,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.drawer_fridge_doors = {
	name = pyloc "Drawer and Doors",
	geometry_function = {create_drawers_call, create_intelli_doors_shelves},
	ui_update_function = ui_update_oven_drawers_intelli_doors,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.doors_fridge_doors = {
	name = pyloc "Doors and Doors",
	geometry_function = {create_intelli_doors_shelves, create_intelli_doors_shelves},
	ui_update_function = ui_update_intelli_doors_shelves,
	drawer_list = single_drawer_setup_list,
}
organization_style_list.doors_fridge_lift = {
	name = pyloc "Doors and Lift Door",
	geometry_function = {create_intelli_doors_shelves, create_lift_door},
	ui_update_function = ui_update_intelli_doors_shelves,
	drawer_list = single_drawer_setup_list,
}