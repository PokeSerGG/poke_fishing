Config = {}

Config.Locale = 'es'

Config.Fishes = {
	['salmon'] = { 
		['name'] = 'salmon',
		['label'] = 'Salmón',
		['price'] = 15,
		['value'] = 60/1000,
		['weight'] = {18000, 42000},
	},
	['trout'] = { 
		['name'] = 'trout',
		['label'] = 'Trucha',
		['price'] = 12,
		['value'] = 75/1000,
		['weight'] = {1400, 2100},
	},
	['char'] = { 
		['name'] = 'char',
		['label'] = 'Pescado fresco',
		['price'] = 12,
		['value'] = 75/1000,
		['weight'] = {800,1200},
	},
	['pike'] = { 
		['name'] = 'pike',
		['label'] = 'Lucio',
		['price'] = 10,
		['value'] = 80/1000,
		['weight'] = {1500,5000},
	},
	['goldfish'] = {
		['name'] = 'goldfish',
		['label'] = 'Pez dorado',
		['price'] = 5,
		['value'] = 50/1000,
		['weight'] = {150, 400},
	},
	['whitefish'] = { 
		['name'] = 'whitefish',
		['label'] = 'Pez blanco',
		['price'] = 10,
		['value'] = 90/1000,
		['weight'] = {4000,5500},
	},
	['roach'] = { 
		['name'] = 'roach',
		['label'] = 'Cucaracha',
		['price'] = 5,
		['value'] = 99/1000,
		['weight'] = {200, 700},
	},
	['mackerel'] = { 
		['name'] = 'mackerel',
		['label'] = 'Caballa',
		['price'] = 5,
		['value'] = 99/1000,
		['weight'] = {750,1250},
	},
	['lobster'] = { 
		['name'] = 'lobster',
		['label'] = 'Langosta',
		['price'] = 15,
		['value'] = 60/1000,
		['weight'] = {500,1200},
	},
	['crawfish'] = { 
		['name'] = 'crawfish',
		['label'] = 'Cangrejo de río',
		['price'] = 10,
		['value'] = 70/1000,
		['weight'] = {150,450},
	},
}

Config.Locations = {
	{ ["x"] = 2127.04, ["y"] = -597.79, ["z"] = 42.61, ["h"] = 287.93, ['fishes'] = {'mackerel', 'roach', 'whitefish', 'goldfish', 'trout', 'pike'}},
	{ ["x"] = 741.66, ["y"] = -1505.04, ["z"] = 41.35, ["h"] = 170.69, ['fishes'] = {'mackerel', 'roach', 'whitefish', 'goldfish', 'trout', 'pike'}},
}

Config.LocationsToSell = {
	{ ["x"] = 2827.9, ["y"] = -1232.52, ["z"] = 47.5},
}
