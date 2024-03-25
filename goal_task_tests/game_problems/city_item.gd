extends Resource

@export
var city_item_data = [
	{
		"Type": "City",
		"MeshName": "CITY_MESH_road_straight_01",
		"AdjacentMeshes": [
			"CITY_MESH_road_turn_right_01",
			"CITY_MESH_road_turn_left_01",
			"CITY_MESH_road_intersection_T_01",
			"CITY_MESH_streetlamp_standard_01"
		],
		"Footprint": "2x1x0.1",
		"FlavorText": "A simple straight road",
		"Tags": ["Road", "Transport"],
		"Requirements": ["Straight", "Cross"],
		"Contents": []
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_road_turn_right_01",
		"AdjacentMeshes": [
			"CITY_MESH_road_straight_01",
			"CITY_MESH_road_intersection_T_01",
			"CITY_MESH_streetlamp_standard_01"
		],
		"Footprint": "2x2x0.1",
		"FlavorText": "A right-angled corner road",
		"Tags": ["Road", "Transport"],
		"Requirements": ["Turn Right"],
		"Contents": []
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_road_turn_left_01",
		"AdjacentMeshes": [
			"CITY_MESH_road_straight_01",
			"CITY_MESH_road_intersection_T_01",
			"CITY_MESH_streetlamp_standard_01"
		],
		"Footprint": "2x2x0.1",
		"FlavorText": "A left-angled corner road",
		"Tags": ["Road", "Transport"],
		"Requirements": ["Turn Left"],
		"Contents": []
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_road_intersection_T_01",
		"AdjacentMeshes": [
			"CITY_MESH_road_straight_01",
			"CITY_MESH_road_turn_right_01",
			"CITY_MESH_road_turn_left_01",
			"CITY_MESH_square_central_01"
		],
		"Footprint": "3x3x0.1",
		"FlavorText": "T-junction road",
		"Tags": ["Road", "Transport"],
		"Requirements": ["3-way junction"],
		"Contents": []
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_square_central_01",
		"AdjacentMeshes": [
			"CITY_MESH_road_intersection_T_01",
			"CITY_MESH_park_common_01",
			"CITY_MESH_kiosk_newspapers_01",
			"CITY_MESH_kiosk_snacks_01",
			"CITY_MESH_kiosk_flowers_01"
		],
		"Footprint": "5x5x0.2",
		"FlavorText": "A bustling city square",
		"Tags": ["Social", "Area"],
		"Requirements": ["Adjacent to roads"],
		"Contents": ["Benches", "Statues"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_park_common_01",
		"AdjacentMeshes": [
			"CITY_MESH_square_central_01",
			"CITY_MESH_tree_park_01",
			"BUILDING_MESH_garden_common_01"
		],
		"Footprint": "1x1x1.5",
		"FlavorText": "Newsstand selling papers",
		"Tags": ["Commerce"],
		"Requirements": ["Near pedestrian area"],
		"Contents": ["Newspapers", "Magazines"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_kiosk_newspapers_01",
		"AdjacentMeshes": [
			"CITY_MESH_square_central_01",
			"CITY_MESH_kiosk_snacks_01",
			"CITY_MESH_kiosk_flowers_01"
		],
		"Footprint": "1x1x1.5",
		"FlavorText": "Quick snacks on the go",
		"Tags": ["Commerce", "Food"],
		"Requirements": ["Near pedestrian area"],
		"Contents": ["Snack foods", "Beverages"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_kiosk_snacks_01",
		"AdjacentMeshes": [
			"CITY_MESH_square_central_01",
			"CITY_MESH_kiosk_newspapers_01",
			"CITY_MESH_kiosk_flowers_01"
		],
		"Footprint": "1x1x1.5",
		"FlavorText": "Fresh flowers for sale",
		"Tags": ["Commerce"],
		"Requirements": ["Near pedestrian area"],
		"Contents": ["Flower bouquets", "Potted plants"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_kiosk_flowers_01",
		"AdjacentMeshes": [
			"CITY_MESH_square_central_01",
			"CITY_MESH_kiosk_newspapers_01",
			"CITY_MESH_kiosk_snacks_01"
		],
		"Footprint": "10x6x3",
		"FlavorText": "Student housing facility",
		"Tags": ["Housing"],
		"Requirements": ["Near educational building"],
		"Contents": ["Beds", "Desks", "Personal items"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_building_dormitory_01",
		"AdjacentMeshes": [
			"CITY_MESH_building_lab_student_01",
			"CITY_MESH_building_library_01",
			"BUILDING_MESH_hub_dormitory_01",
			"BUILDING_MESH_classroom_standard_01",
			"CITY_MESH_road_intersection_T_01",
			"CITY_MESH_building_lab_student_01",
		],
		"Footprint": "8x8x3",
		"FlavorText": "Study and lecture halls",
		"Tags": ["Education"],
		"Requirements": ["On campus"],
		"Contents": ["Chairs", "Projectors", "Lecterns"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_building_lab_student_01",
		"AdjacentMeshes": [
			"CITY_MESH_building_dormitory_01",
			"CITY_MESH_building_library_01",
			"BUILDING_MESH_classroom_standard_01",
		],
		"Footprint": "6x7x3",
		"FlavorText": "Repository of knowledge",
		"Tags": ["Education"],
		"Requirements": ["Quiet area"],
		"Contents": ["Books", "Reading tables", "Computers"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_building_library_01",
		"AdjacentMeshes": [
			"CITY_MESH_building_dormitory_01",
			"CITY_MESH_building_lab_student_01",
			"BUILDING_MESH_lab_computer_01"
		],
		"Footprint": "15x6x5",
		"FlavorText": "Transit hub for city travel",
		"Tags": ["Transport"],
		"Requirements": ["Near roads"],
		"Contents": ["Ticket counters", "Waiting areas"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_station_train_01",
		"AdjacentMeshes": [
			"CITY_MESH_road_straight_01",
			"CITY_MESH_road_intersection_T_01",
			"CITY_MESH_building_library_01"
		],
		"Footprint": "0.2x0.2x3",
		"FlavorText": "Provides light at night",
		"Tags": ["Infrastructure"],
		"Requirements": ["Alongside roads"],
		"Contents": ["Light"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_streetlamp_standard_01",
		"AdjacentMeshes": [
			"CITY_MESH_road_straight_01",
			"CITY_MESH_road_turn_right_01",
			"CITY_MESH_road_turn_left_01",
			"CITY_MESH_road_intersection_T_01",			
			"CITY_MESH_station_train_01"
		],
		"Footprint": "1x1x2",
		"FlavorText": "Oxygen provider",
		"Tags": ["Nature"],
		"Requirements": ["Soil patch"],
		"Contents": ["Leaves", "Branches"]
	},
	{
		"Type": "City",
		"MeshName": "CITY_MESH_tree_park_01",
		"AdjacentMeshes": [
			"CITY_MESH_park_common_01",			
			"CITY_MESH_streetlamp_standard_01"
		],
		"Footprint": "10x10x3",
		"FlavorText": "Grand vestibule welcoming students and visitors alike",
		"Tags": ["Entry", "Spacious"],
		"Requirements": ["Main entryway"],
		"Contents": ["Reception desk", "Notice boards", "Seating"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_hall_entrance_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01",
			"BUILDING_MESH_auditorium_main_01",
			"BUILDING_MESH_theatre_main_01",		
			"BUILDING_MESH_room_gigachad_01",
			"CITY_MESH_building_dormitory_01",
		],
		"Dimensions": "10x6x3",
		"Description": "The primary entrance hall of the building, welcoming students and staff.",
		"Tags": ["Entryway", "Main Hall"],
		"Requirements": [],
		"Features": ["Reception Area", "Seating"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_corridor_school_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_hall_entrance_01",
			"BUILDING_MESH_classroom_standard_01",
			"BUILDING_MESH_lab_science_01",
			"BUILDING_MESH_office_teacher_01",
			"BUILDING_MESH_staircase_main_01",
			"BUILDING_MESH_theatre_main_01",
			"BUILDING_MESH_kitchen_main_01",
			"BUILDING_MESH_lab_alchemy_01",
		],
		"Dimensions": "20x15x5",
		"Description": "Large space for assemblies and performances",
		"Tags": ["Performance", "Assembly"],
		"Requirements": ["Events"],
		"Features": ["Stage", "Lighting", "Sound system"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_auditorium_main_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_hall_entrance_01"
		],
		"Dimensions": "20x15x5",
		"Description": "A large space for school assemblies, presentations, and performances.",
		"Tags": ["Auditorium", "Assembly Hall"],
		"Requirements": [],
		"Features": ["Stage", "Seating", "Audio-Visual Equipment"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_classroom_standard_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01"
		],
		"Dimensions": "12x8x3",
		"Description": "Where students dine together",
		"Tags": ["Dining", "Social"],
		"Requirements": ["Meal times"],
		"Features": ["Dining tables", "Buffet stations", "Waste bins"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_hall_mess_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_kitchen_main_01"
		],
		"Dimensions": "6x4x2.5",
		"Description": "The culinary heart of the school",
		"Tags": ["Food prep", "Staff only"],
		"Requirements": ["Certified staff"],
		"Features": ["Stoves", "Sinks", "Prep tables", "Storage"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_kitchen_main_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_hall_mess_01"
		],
		"Dimensions": "10x10x2.5",
		"Description": "Common area for dorm residents",
		"Tags": ["Housing", "Community"],
		"Requirements": ["Residential access"],
		"Features": ["Lounge furniture", "Entertainment units"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_hub_dormitory_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_room_dorm_01",
		],
		"Dimensions": "6x4x3",
		"Description": "Shared living quarters for students",
		"Tags": ["Housing", "Shared"],
		"Requirements": ["Residents"],
		"Features": ["Beds", "Desks", "Wardrobes", "Study lamps"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_room_dorm_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_hub_dormitory_01"
		],
		"Dimensions": "4x4x3",
		"Description": "Private sleeping space for one",
		"Tags": ["Housing", "Private"],
		"Requirements": ["Single occupancy"],
		"Features": ["Single bed", "Desk", "Closet", "Nightstand"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_bedroom_individual_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_hub_dormitory_01",
			"BUILDING_MESH_room_dorm_01",
			"BUILDING_MESH_office_teacher_01",
		],
		"Dimensions": "Variable",
		"Description": "Outdoor area for recreation and relaxation",
		"Tags": ["Nature", "Leisure"],
		"Requirements": ["Surrounding buildings"],
		"Features": ["Planters", "Sculptures", "Trees"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_courtyard_main_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_classroom_standard_01",
			"BUILDING_MESH_area_communal_01",
			"BUILDING_MESH_corridor_school_01",
			"BUILDING_MESH_garden_common_01",
		],
		"Dimensions": "5x5x1",
		"Description": "A touch of nature within the school grounds",
		"Tags": ["Nature", "Calm"],
		"Requirements": ["Grounds maintenance"],
		"Features": ["Vegetation", "Decorative stones", "Water features"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_garden_common_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_courtyard_main_01",
			"CITY_MESH_park_common_01"
		],
		"Dimensions": "8x6x3",
		"Description": "Equipped for experiments and scientific discovery",
		"Tags": ["Education", "Science"],
		"Requirements": ["Supervised access"],
		"Features": ["Microscopes", "Bunsen burners", "Chemicals"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_lab_science_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01"
		],
		"Dimensions": "7x7x3",
		"Description": "Mystical room dedicated to the study of alchemy",
		"Tags": ["Specialty", "Magic"],
		"Requirements": ["Trained alchemist"],
		"Features": ["Cauldrons", "Spell books", "Ingredient shelves"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_office_principal_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_wing_administrative_01"
		],
		"Dimensions": "Variable",
		"Description": "The principal's personal decision-making space",
		"Tags": ["Administrative"],
		"Requirements": ["Principal"],
		"Features": ["Desk", "Files", "Communication devices"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_railing_standard_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_balcony_01",
			"BUILDING_MESH_staircase_main_01"
		],
		"Dimensions": "2m x 1m x 3m",
		"Description": "Provides safety and division between open spaces",
		"Tags": ["Safety", "Infrastructure"],
		"Requirements": ["Along edges"],
		"Features": ["Railings"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_lab_alchemy_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01",
			"BUILDING_MESH_classroom_specialized_01",
			"BUILDING_MESH_corridor_school_01",
		],
		"Dimensions": "8x6x3",
		"Description": "Mystical room dedicated to the study of alchemy",
		"Tags": ["Specialty", "Magic"],
		"Requirements": ["Trained alchemist"],
		"Features": ["Cauldrons", "Spell books", "Ingredient shelves"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_lab_computer_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01",			
			"CITY_MESH_building_library_01",
		],
		"Dimensions": "6x6x3",
		"Description": "High-tech room with computers for research and coding",
		"Tags": ["Technology", "Education"],
		"Requirements": ["Technical classes"],
		"Features": ["Workstations", "Servers", "Software"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_room_home_economics_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01"
		],
		"Dimensions": "7x7x2.5",
		"Description": "Space for learning life skills and domestic crafts",
		"Tags": ["Practical", "Skill building"],
		"Requirements": ["Supervised classes"],
		"Features": ["Appliances", "Textile tools", "Produce"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_room_music_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01"
		],
		"Dimensions": "15x10x5",
		"Description": "Soundproof room for practicing and learning music",
		"Tags": ["Artistic", "Soundproof"],
		"Requirements": ["Musical activities"],
		"Features": ["Sheet music", "Amplifiers", "Recording equipment"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_theatre_main_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01",
			"BUILDING_MESH_auditorium_main_01",
		],
		"Dimensions": "20x15x7",
		"Description": "A stage for drama practices and performances",
		"Tags": ["Drama", "Performance"],
		"Requirements": ["Rehearsals and shows"],
		"Features": ["Props", "Backdrops", "Costume racks"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_gymnasium_main_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_room_changing_01",
			"CITY_MESH_building_dormitory_01",
		],
		"Dimensions": "8x8x4",
		"Description": "Indoor sports facility",
		"Tags": ["Sports", "Large"],
		"Requirements": ["Physical education"],
		"Features": ["Equipment", "Scoreboards", "Bleachers"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_room_gigachad_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_gymnasium_main_01"
		],
		"Dimensions": "3x3x2",
		"Description": "Exclusive gym for top-tier athletes",
		"Tags": ["Elite", "Fitness"],
		"Requirements": ["Athletic excellence"],
		"Features": ["Premium equipment", "Tracking systems"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_room_janitor_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01"
		],
		"Dimensions": "4x4x2.5",
		"Description": "Storage and workspace for cleaning staff",
		"Tags": ["Storage", "Staff"],
		"Requirements": ["Staff"],
		"Features": ["Mops", "Buckets", "Maintenance tools"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_office_teacher_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01",
			"BUILDING_MESH_bedroom_individual_01",
			"BUILDING_MESH_dorms_teacher_01",
		],
		"Dimensions": "4x4x2.5",
		"Description": "Workspace for faculty staff",
		"Tags": ["Work", "Faculty"],
		"Requirements": ["Faculty staff"],
		"Features": ["Bookshelf", "Printer", "Stationery"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_room_break_teacher_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_office_teacher_01",
			"BUILDING_MESH_office_faculty_01",
		],
		"Dimensions": "Variable",
		"Description": "Relaxation area for staff during breaks",
		"Tags": ["Rest", "Staff only"],
		"Requirements": ["Staff"],
		"Features": ["Microwave", "Water dispenser", "Lounge chairs"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_staircase_main_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_corridor_school_01",
			"BUILDING_MESH_floor_all_01"
		],
		"Dimensions": "6x6x3",
		"Description": "Connects different floors in the school",
		"Tags": ["Vertical", "Accessible"],
		"Requirements": ["Multiple Floors"],
		"Features": ["Escalators (if applicable)", "Signage"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_dorms_teacher_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_facility_school_01"
		],
		"Dimensions": "5x5x2.5",
		"Description": "On-site living accommodations for teachers",
		"Tags": ["Housing", "Faculty"],
		"Requirements": ["Faculty staff"],
		"Features": ["Bed", "Desk", "Small dining area", "Bathroom"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_office_headmaster_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_wing_administrative_01"
		],
		"Dimensions": "5x5x2.5",
		"Description": "Administrative nexus and leader's workspace",
		"Tags": ["Leadership", "Private"],
		"Requirements": ["Headmaster"],
		"Features": ["Executive chair", "Safe", "Credentials"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_office_principal_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_wing_administrative_01"
		],
		"Dimensions": "Variable",
		"Description": "The principal's personal decision-making space",
		"Tags": ["Administrative"],
		"Requirements": ["Principal"],
		"Features": ["Desk", "Files", "Communication devices"]
	},
	{
		"Type": "Building",
		"MeshName": "BUILDING_MESH_railing_standard_01",
		"AdjacentMeshes": [
			"BUILDING_MESH_balcony_01",
			"BUILDING_MESH_staircase_main_01"
		],
		"Dimensions": "2m x 1m x 3m",
		"Description": "Provides safety and division between open spaces",
		"Tags": ["Safety", "Infrastructure"],
		"Requirements": ["Along edges"],
		"Features": ["Railings"]
	},
]

@export
var room_item_data = [
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_door_standard_01",
		"AdjacentMeshes": ["ROOM_MESH_room_to_room_01", "ROOM_MESH_corridor_01"],
		"Dimensions": "1.5m x 0.2m x 2m",
		"Description": "Standard door providing room access and privacy",
		"Tags": ["Access", "Privacy"],
		"Requirements": ["Doorway"],
		"Features": ["Handle", "Lock"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_window_standard_01",
		"AdjacentMeshes": ["ROOM_MESH_view_outside_01"],
		"Dimensions": "1.2m x 0.8m x 0.07m",
		"Description": "Large double-paneled window letting in light",
		"Tags": ["Transparent", "Lite"],
		"Requirements": ["Exterior Wall"],
		"Features": ["Glass Panes", "Openable"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_desk_office_01",
		"AdjacentMeshes": ["ROOM_MESH_chair_near_01"],
		"Dimensions": "1.2m x 0.6m x 0.75m",
		"Description": "Solid oak desk with multiple drawers",
		"Tags": ["Furniture", "Study"],
		"Requirements": ["Floor Space"],
		"Features": ["Drawers", "Surface Space"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_chair_office_01",
		"AdjacentMeshes": ["ROOM_MESH_area_office_01"],
		"Dimensions": "0.6m x 0.6m x 1.2m",
		"Description": "Comfortable rolling office chair",
		"Tags": ["Seating", "Mobile"],
		"Requirements": ["Underneath Desk"],
		"Features": ["Wheels", "Adjustable Height"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_blackboard_standard_01",
		"AdjacentMeshes": ["ROOM_MESH_desk_in_front_of_01"],
		"Dimensions": "2m x 0.05m x 1.2m",
		"Description": "Classic green blackboard with chalk traces",
		"Tags": ["Educational", "Writable"],
		"Requirements": ["Classroom Wall"],
		"Features": ["Chalk", "Eraser"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_board_bulletin_01",
		"AdjacentMeshes": ["ROOM_MESH_space_public_01"],
		"Dimensions": "1m x 0.02m x 1.5m",
		"Description": "Cork bulletin board for announcements and notices",
		"Tags": ["Informative", "Pinnable"],
		"Requirements": ["Accessible Wall Area"],
		"Features": ["Flyers", "Notices"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_portrait_hall_01",
		"AdjacentMeshes": ["ROOM_MESH_hall_01"],
		"Dimensions": "0.5m x 0.01m x 1.8m",
		"Description": "Framed portrait of a historical figure",
		"Tags": ["Art", "Decorative"],
		"Requirements": ["Wall space"],
		"Features": ["Frame", "Portrait"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_mirror_dressing_01",
		"AdjacentMeshes": ["ROOM_MESH_area_dressing_01"],
		"Dimensions": "0.5m x 0.01m x 1.8m",
		"Description": "Full-length wall mirror for reflection.",
		"Tags": ["Reflective", "Glass"],
		"Requirements": ["Vertical Wall Space"],
		"Features": ["Mirror", "Frame"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_light_ceiling_01",
		"AdjacentMeshes": ["ROOM_MESH_room_any_01"],
		"Dimensions": "0.3m x 0.3m x 0.2m",
		"Description": "Bright LED ceiling light fixture.",
		"Tags": ["Illumination", "Energy-Efficient"],
		"Requirements": ["Ceiling Access"],
		"Features": ["LED Bulbs", "Mounting Hardware"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_chandelier_grand_01",
		"AdjacentMeshes": ["ROOM_MESH_room_grand_01"],
		"Dimensions": "1m x 1m x 1.5m",
		"Description": "Ornate crystal chandelier with dimming capability.",
		"Tags": ["Luxurious", "Light-Source"],
		"Requirements": ["High Ceiling"],
		"Features": ["Crystals", "Dimmer Switch"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_lamp_table_01",
		"AdjacentMeshes": ["ROOM_MESH_desk_01", "ROOM_MESH_table_01"],
		"Dimensions": "0.3m x 0.3m x 0.5m",
		"Description": "Modern table lamp with an adjustable neck.",
		"Tags": ["Portable", "Light"],
		"Requirements": ["Power Source"],
		"Features": ["Adjustable Neck", "Switch"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_bookcase_standard_01",
		"AdjacentMeshes": ["ROOM_MESH_study_01"],
		"Dimensions": "1m x 0.3m x 2m",
		"Description": "Tall mahogany bookcase full of volumes.",
		"Tags": ["Storage", "Wooden"],
		"Requirements": ["Stable Wall Support"],
		"Features": ["Shelves", "Books"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_wardrobe_bedroom_01",
		"AdjacentMeshes": ["ROOM_MESH_bed_near_01"],
		"Dimensions": "2m x 0.6m x 2.2m",
		"Description": "Spacious wardrobe with sliding doors.",
		"Tags": ["Clothing", "Storage"],
		"Requirements": ["Bedroom Corner"],
		"Features": ["Clothes", "Hangers"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_stove_kitchen_01",
		"AdjacentMeshes": ["ROOM_MESH_countertop_near_01"],
		"Dimensions": "0.8m x 0.6m x 0.9m",
		"Description": "Four-burner gas stove with an oven.",
		"Tags": ["Cooking", "Appliance"],
		"Requirements": ["Kitchen Placement"],
		"Features": ["Burners", "Oven"]
	},
	{
		"Type": "Room",
		"MeshName": "ROOM_MESH_pot_flower_01",
		"AdjacentMeshes": ["ROOM_MESH_windowsill_01", "ROOM_MESH_table_01"],
		"Dimensions": "0.3m x 0.3m x 0.4m",
		"Description": "Terracotta flower pot with a blooming plant.",
		"Tags": ["Decorative", "Natural"],
		"Requirements": ["Sunlight Exposure"],
		"Features": ["Soil", "Plant"]
	}
]
