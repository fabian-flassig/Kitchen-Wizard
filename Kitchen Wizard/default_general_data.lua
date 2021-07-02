

--this table can be used to sort elements in the combobox. 
--Upper cabinets of course will be displayed independently from lower cabinets
cabinet_sorting_for_combobox = {}
cabinet_sorting_for_combobox[0x1] = {
		"base",
		"sink",
		"hob",
		"hob_and_oven",
		"dishwasher",
		"fridge",
		"blind_end", 
		"filler", 
		"corner",
		"diagonal",
		"angle",
		"high", 
		"high_appliance1",
		"high_appliance2",
		"high_fridge",
		"diagonal_high",
		"blind_end_high",
		"filler_high",
		"angle_high",
		"empty",
}
--currently we set the sorting to be identical for all rows
cabinet_sorting_for_combobox[0x2] = {
		"wall",
		"hood",
		"cornerwall",
		"top",
		"diagonal_wall",
		"blind_end_wall",
		"filler_wall",
		"angle_wall",
}
cabinet_sorting_for_combobox[0x3] = cabinet_sorting_for_combobox[0x1] --[[{
--		"tall_tkh",
		"high", 
		"high_appliance1",
		"high_appliance2",
		"high_fridge",
		"diagonal_high",
		"blind_end_high",
		"filler_high",
		"base",
		"corner",
		"diagonal",
		"sink", 
		"hob",
		"hob_and_oven",
		"dishwasher",
		"fridge",
		"blind_end", 
		"filler", 
		"empty"
}]]--

typecombolist = {}

local function pairs_sorted_typelist(typelist)	--sorting the entries alphabetically. Slightly different to the function used in the auxiliary dialogs for the attributes
	local a = {}
	for n in pairs(typelist) do
		table.insert(a, n) 
	end
	table.sort(a, function(elem1,elem2) return typelist[elem1].name < typelist[elem2].name end)
	local i = 0 
	local iter = function () 
	  i = i + 1
	  if a[i] == nil then return nil
	  else return a[i], typelist[a[i]]
	  end
	end
	return iter
end 


function init_typecombolist()

	typecombolist = {}
	typecombolist[0x1] = {}
	typecombolist[0x2] = {}
	typecombolist[0x3] = {}
	for i, k in pairs_sorted_typelist(cabinet_typelist) do
		if k.row == 0x2 then 
			table.insert(typecombolist[0x2], i)
		else 
			table.insert(typecombolist[0x1], i)
			table.insert(typecombolist[0x3], i)
		end
	end
	--here we sort for the combobox order.
	for i, tc_row in pairs(typecombolist) do	--iterate 0x1-0x3
		for u, sort_type in pairs(cabinet_sorting_for_combobox[i]) do
			for j, cab_type in pairs(tc_row) do 	--iterate the entries
				if cab_type == sort_type then
					table.remove(tc_row, j)
					table.insert(tc_row, u, cab_type)
					goto next_term
				end
			end
			::next_term::
		end
	end
	

end
local counter_settings = {
	cur_elements = {},
	main_group = nil,

	active = false,
	shape = 1,
	height = 1100,
	top_thickness = 38,
	wall_thickness = 19,
	top_depth = 350, 
	top_benchtop_overlap = 50, 
	polygonal_settings = {points = {}, segments = {}},
	overlap_left = 0,
	overlap_right = 0,
}
local splashback_settings = {
	cur_elements = {},
	main_group = nil,

	splashback = false,
	wall_edging = false,
	
	splashback_thickness = 8,
	splashback_gap = 0,
	wall_edging_thickness = 23,
	wall_edging_height = 23,
}

--this data simply stores the old values of individual cabinets so that the new cabinet can get the same values.
default_specific_type_data = {}

--default general values. Feel free to adapt the numeric values!
general_default_data = {
		dialog = nil,
		cur_elements = {},
		main_group = nil,
		orient_leftwards = false,
		benchtop_height = 900,	--in main
		handle_length = 128,		--in handle setting
		handle_type = 2,			--in handle setting
		handle_position = 1,		--in handle setting
		handle_dist_vert = 50,		--in handle setting
		handle_dist_hori = 40,		--in handle setting
		benchtop_thickness = 38,		--in setting
		general_height_base = 780,	--in main
		general_height_top = 2320,	--in main
		wall_to_base_spacing = 562,	--in main
		thickness = 19,				--in setting
		kickboard_thickness = 19,	--in setting
		kickboard_setback = 25,		--in setting
		kickboard_margin = 3,		--in setting
		thickness_back = 8,			--on intention only programatically			
		groove_dist = 20,			--on intention only programatically
		groove_depth = 9,			--on intention only programatically
		depth = 550,				--in main
		depth_wall = 330,			--in main
		setback_shelves = 5,		--in setting
		max_door_width = 650,		--in setting
		setback_fixed_shelves = 1,
		fixed_shelf_gap = 0.5,				
		width_rail = 160,			--in setting
		width_vertical_rail = 80,	--in settings
		top_gap = 3,		--in setting
		top_over = 50,		--in setting
		gap = 3,		--in setting
		door_thickness = 19,	--in setting
		door_carcass_gap = 0,
		panel_type = 1,			--in handle_settings
		panel_frame_width = 80,
		panel_central_thickness = 14,
		finger_rail_width = 60,
		finger_rail_thickness = 19,
		finger_gap = 22,
		shelf_gap = 1,			--in setting
		drawing_symbols = false,			--in setting
		origin = {0,0,0},
		direction = {1,0,0},
		cabinet_list = {},
		current_cabinet = nil,
		benchtop = {},
		kickboards = {},
		benchtop_templates = {},
		default_folders = {sink_folder = nil, handle_folder = nil, hob_folder = nil, oven_folder = nil, microwave_folder = nil, fridge_folder = nil, garbage_bin_folder = nil, panel_folder = nil},
		counter_settings = counter_settings,
		splashback_settings = splashback_settings,
}
--default values for individual cabinets
function initialize_cabinet_values(data, cab_type)
	table.insert(data.cabinet_list, {this_type = nil,
				width = 600,
				width2 = 1000,	--right side of corner cabinets
				height = data.general_height_base,
				height_top = data.general_height_top,	
				depth = data.depth, --need to add dialog for changing depth for each cabinet
				depth2 = data.depth,
				depth_wall = data.depth_wall,	
				shelf_count = 2,
				drawer_count = 3,
				door_width = 600,
				angle = 90,
				door_rh = false,
				fingerpull = false,
				front_style = nil,
				back_style = nil,
				bottom_style = nil,
				top_style = nil,
				drawer_height_list = "",
				appliance_file = nil,
				appliance_file2 = nil,

				------------------------------------below are values that dont influence the geometry and will not be transferred to a new cabinet of this type
				aux_values = {
					row = nil,
					right_element = nil,
					left_element = nil, 
					right_top_element = nil,
					left_top_element = nil, 
					top_element = nil, 
					bottom_element = nil, 
					right_connection_point = {0,0,0},
					left_connection_point = {0,0,0},
					right_direction = 0,
					left_direction = 0,
					main_group = nil,
					elem_handle_for_top = nil,
					kickboard_handle_left = nil,
					kickboard_handle_right = nil,
					appliance_list = {},
					appliance_list2 = {},
				}
				})	
	 if cab_type ~= nil then 
		assign_cabinet_type(data, #data.cabinet_list, cab_type)
	end
	return #data.cabinet_list
end

function write_data_to_default_specific_type_data(specific_data)
	default_specific_type_data[specific_data.this_type] = {}
	def_data = default_specific_type_data[specific_data.this_type]
	for i,k in pairs(specific_data) do
		if i ~= "aux_values" then
			def_data[i] = k
		end
	end
end
--sets the cabinet type 
function assign_cabinet_type(data, cabinet_nr, cab_type)

	local specific_type_data = default_specific_type_data[cab_type]	--backup values from previous creation of this cabinet
	local specific_data = data.cabinet_list[cabinet_nr]
	local spec_default_data = cabinet_typelist[cab_type].default_data
	specific_data.front_style = nil
	if cabinet_typelist[cab_type].organization_styles ~= nil and  #cabinet_typelist[cab_type].organization_styles > 0 then 
		specific_data.front_style = cabinet_typelist[cab_type].organization_styles[1]
	end
	specific_data.top_style = nil
	if cabinet_typelist[cab_type].top_styles ~= nil and #cabinet_typelist[cab_type].top_styles > 0 then 
		specific_data.top_style = cabinet_typelist[cab_type].top_styles[1]
	end
	specific_data.bottom_style = nil
	if cabinet_typelist[cab_type].bottom_styles ~= nil and  #cabinet_typelist[cab_type].bottom_styles > 0 then 
		specific_data.bottom_style = cabinet_typelist[cab_type].bottom_styles[1]
	end
	specific_data.back_style = nil
	if cabinet_typelist[cab_type].back_styles ~= nil and  #cabinet_typelist[cab_type].back_styles > 0 then 
		specific_data.back_style = cabinet_typelist[cab_type].back_styles[1]
	end
	specific_data.this_type = cab_type
	specific_data.aux_values.row = cabinet_typelist[cab_type].row
	specific_data.aux_values.elem_handle_for_top = nil
	specific_data.aux_values.kickboard_handle_left = nil
	specific_data.aux_values.kickboard_handle_right = nil

	if type(spec_default_data) == "function" then
		spec_default_data(data, specific_data)
	elseif type(spec_default_data) == "table" then
		for i,k in pairs(spec_default_data) do
			specific_data[i] = k
		end 
	end

	if specific_type_data ~= nil then
		for i,k in pairs(specific_type_data) do
			specific_data[i] = k
		end 
	end
	
end


function merge_data(merge_from, merge_to)  	
	for i,k in pairs(merge_from) do
		if k ~= merge_from.cabinet_list then
			merge_to[i] = k
		end
	end
	for u,spec_from in pairs(merge_from.cabinet_list) do
		if merge_to.cabinet_list[u] == nil then
			merge_to.cabinet_list[u] = {}
		end
		local spec_to = merge_to.cabinet_list[u]
		for i,k in pairs(spec_from) do
			spec_to[i] = k
		end
	end
end

--The attributes can be modified in the dialog as well as translated. If you define a new part type please add it to this list!
attribute_list = {
	cr_front = {display_name = pyloc "Rail Front", name = pyloc "Rail Front", layer = 0, pen = 1, linetype = 1, class = "inner"},
	cr_back = {display_name = pyloc "Rail Back", name = pyloc "Rail Back", layer = 0, pen = 1, linetype = 1, class = "inner"},
	door_lh = {display_name = pyloc "Door LH", name = pyloc "Door LH", layer = 0, pen = 1, linetype = 1, class = "front"},
	door_rh = {display_name = pyloc "Door RH", name = pyloc "Door RH", layer = 0, pen = 1, linetype = 1, class = "front"},
	end_rh = {display_name = pyloc "End RH", name = pyloc "End RH", layer = 0, pen = 1, linetype = 1, class = "inner"},
	end_lh = {display_name = pyloc "End LH", name = pyloc "End LH", layer = 0, pen = 1, linetype = 1, class = "inner"},
	inner_end = {display_name = pyloc "End", name = pyloc "End", layer = 0, pen = 1, linetype = 1, class = "inner"},
	bottom = {display_name = pyloc "Bottom", name = pyloc "Bottom", layer = 0, pen = 1, linetype = 1, class = "inner"},
	back = {display_name = pyloc "Back", name = pyloc "Back", layer = 0, pen = 1, linetype = 1, class = "inner"},
	top = {display_name = pyloc "Top", name = pyloc "Top", layer = 0, pen = 1, linetype = 1, class = "inner"},
	adjustable_shelf = {display_name = pyloc "Adjustable Shelf", name = pyloc "Adjustable Shelf", layer = 0, pen = 1, linetype = 1, class = "inner"},
	fixed_shelf = {display_name = pyloc "Fixed Shelf", name = pyloc "Fixed Shelf", layer = 0, pen = 1, linetype = 1, class = "inner"},
	fingerpull_rail = {display_name = pyloc "Fingerpull Rail", name = pyloc "Fingerpull Rail", layer = 0, pen = 1, linetype = 1, class = "inner"},
	cleat = {display_name = pyloc "Cleat", name = pyloc "Cleat", layer = 0, pen = 1, linetype = 1, class = "inner"},
	blind_panel = {display_name = pyloc "Blind Panel", name = pyloc "Blind Panel", layer = 0, pen = 1, linetype = 1, class = "inner"},
	kickboard = {display_name = pyloc "Kickboard", name = pyloc "Kickboard", layer = 0, pen = 1, linetype = 1, class = "kickboard"},
	benchtop = {display_name = pyloc "Benchtop", name = pyloc "Benchtop", layer = 0, pen = 1, linetype = 1, class = "benchtop"},
	light = {display_name = pyloc "Light_375", name = pyloc "Light_375", layer = 0, pen = 1, linetype = 1},
	handle = {display_name = pyloc "Handle", name = pyloc "Handle", layer = 0, pen = 1, linetype = 1, class = "handle"},
--	dr_bottom = {display_name = pyloc "Drawer Bottom", name = pyloc "Drawer Bottom", layer = 0, pen = 1, linetype = 1, class = "inner"},
	dr_front = {display_name = pyloc "Drawer Front", name = pyloc "Drawer Front", layer = 0, pen = 1, linetype = 1, class = "front"},
--	dr_left = {display_name = pyloc "Drawer Left", name = pyloc "Drawer Left", layer = 0, pen = 1, linetype = 1, class = "inner"},
--	dr_right = {display_name = pyloc "Drawer Right", name = pyloc "Drawer Right", layer = 0, pen = 1, linetype = 1, class = "inner"},
--	dr_back = {display_name = pyloc "Drawer Back", name = pyloc "Drawer Back", layer = 0, pen = 1, linetype = 1, class = "inner"},
	dr_box = {display_name = pyloc "Drawer Box", name = pyloc "Drawer Box", layer = 0, pen = 1, linetype = 1, class = "inner"},
	drawer = {display_name = pyloc "Drawer", name = pyloc "Drawer", layer = 0, pen = 1, linetype = 1},
	corner_angle = {display_name = pyloc "Corner Angle", name = pyloc "Corner Angle", layer = 0, pen = 1, linetype = 1, class = "front"}, 
	corner_blind = {display_name = pyloc "Corner Blind", name = pyloc "Corner Blind", layer = 0, pen = 1, linetype = 1, class = "inner"},
	fume_hood = {display_name = pyloc "Fume Hood", name = pyloc "Fume Hood", layer = 0, pen = 1, linetype = 1, class = "fume_hood"},
	blind_end = {display_name = pyloc "Blind End", name = pyloc "Blind End", layer = 0, pen = 1, linetype = 1, class = "end_side"},
	floor_plan = {display_name = pyloc "Floor Plan", name = pyloc "Floor Plan", layer = 9, pen = 3, linetype = 4},
	door_swing = {display_name = pyloc "Elevation Door Swing", name = pyloc "Elevation Door Swing", layer = 8, pen = 3, linetype = 4},
	blind_front = {display_name = pyloc "Blind Front", name = pyloc "Blind Front", layer = 0, pen = 1, linetype = 1, class = "front"},
	blind_mount = {display_name = pyloc "Blind Mount", name = pyloc "Blind Mount", layer = 0, pen = 1, linetype = 1, class = "inner"},
	bore_hole = {display_name = pyloc "Bore Hole", name = pyloc "Bore Hole", layer = 0, pen = 1, linetype = 1},
	counter_wall = {display_name = pyloc "Counter Wall", name = pyloc "Counter Wall", layer = 0, pen = 1, linetype = 1, class = "counter_wall"},
	counter_top = {display_name = pyloc "Counter Top", name = pyloc "Counter Top", layer = 0, pen = 1, linetype = 1, class = "counter_top"},
	counter = {display_name = pyloc "Counter", name = pyloc "Counter", layer = 0, pen = 1, linetype = 1},
	externals = {display_name = pyloc "Externals", name = pyloc "Externals", layer = 0, pen = 1, linetype = 1},
	carcass = {display_name = pyloc "Carcass", name = pyloc "Carcass", layer = 0, pen = 1, linetype = 1},
	back_massive = {display_name = pyloc "Back board", name = pyloc "Back board", layer = 0, pen = 1, linetype = 1, class = "inner"},
	dropdown_door = {display_name = pyloc "Dropdown Door", name = pyloc "Dropdown Door", layer = 0, pen = 1, linetype = 1, class = "front"},
	dishwasher = {display_name = pyloc "Dishwasher", name = pyloc "Dishwasher", layer = 0, pen = 1, linetype = 1},
	lift_door = {display_name = pyloc "Lift Door", name = pyloc "Lift Door", layer = 0, pen = 1, linetype = 1, class = "front"},
	fridge = {display_name = pyloc "Fridge", name = pyloc "Fridge", layer = 0, pen = 1, linetype = 1},
	splashback = {display_name = pyloc "Splashback", name = pyloc "Splashback", layer = 0, pen = 1, linetype = 1, class = "splashback"},
	wall_edging_trim = {display_name = pyloc "Wall Edging Trim", name = pyloc "Wall Edging Trim", layer = 0, pen = 1, linetype = 1, class = "benchtop"},
}

material_list = {
	inner = {display_name = pyloc "Carcass elements", material = nil},
	front1 = {display_name = pyloc "Front Base", material = nil},
	front2 = {display_name = pyloc "Front Wall", material = nil},
	front3 = {display_name = pyloc "Front High", material = nil},
	kickboard = {display_name = pyloc "Kickboard", material = nil},
	benchtop = {display_name = pyloc "Benchtop", material = nil},
	handle = {display_name = pyloc "Handle", material = nil},
	fume_hood = {display_name = pyloc "Fume Hood", material = nil},
	end_side = {display_name = pyloc "End", material = nil},
	counter_wall = {display_name = pyloc "Counter Wall", material = nil},
	counter_top = {display_name = pyloc "Counter Top", material = nil},
	splashback = {display_name = pyloc "Splashback", material = nil},

}

function set_part_attributes(element, attr_type, handle_table, row)
	if attribute_list[attr_type] == nil or element == nil then 
		pyui.alert(pyloc "This element type has not been properly registered: " .. attr_type)
		attribute_list[attr_type] = {name = attr_type, layer = 0, pen = 1, linetype = 1, class = nil}
	end
	if element ~= nil then
		
		pytha.set_element_attributes(element, attribute_list[attr_type])

		local mat_key = attribute_list[attr_type].class
		if mat_key == "front" then
			if row ~= nil then 
				mat_key = "front" .. row
			else
				mat_key = "front" .. 1
			end
		end
		if attribute_list[attr_type].class ~= nil then
			if material_list[mat_key].material ~= nil then	--materials still need a special treatment
				pytha.set_element_material(element, material_list[mat_key].material)
			end 
		end

		if handle_table ~= nil then 
			handle_table[attr_type] = element
		end
	end
end

function load_attributes()
	loaded_attributes = pyio.load_values("attributes")
	if loaded_attributes ~= nil then 
		for i,k in pairs(loaded_attributes) do
			if attribute_list[i] == nil then 
				attribute_list[i] = {}
			end
			for j,l in pairs(k) do 
				attribute_list[i][j] = l	--allows adding new attributes without getting into conflict with the saved values
			end
		end 
	end
	return 
end

function load_materials()
	loaded_materials = pyio.load_values("materials")
	if loaded_materials ~= nil then 
		for i,k in pairs(loaded_materials) do
			if material_list[i] == nil then 
				material_list[i] = {}
			end
			for j,l in pairs(k) do 
				material_list[i][j] = l	--allows adding new materials without getting into conflict with the saved values
			end
		end 
	end
	return 
end