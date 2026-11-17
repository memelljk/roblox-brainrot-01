-- BrainrotData: the whole cast of Pinisi Brainrot Bay.
-- Twelve original characters in six rarities. Every one is invented here:
-- no character from Steal a Brainrot or any other published game is used.
-- Each entry carries its price, its money per second, and the colours and
-- accessory BrainrotFactory needs to build its 3D body from parts.

local BrainrotData = {}

-- Rarity ladder, cheapest first. weight is the spawner's roll weight.
BrainrotData.Rarities = {
	{ name = "Common", color = { 80, 200, 80 }, weight = 45, multiplier = 1 },
	{ name = "Rare", color = { 80, 130, 255 }, weight = 28, multiplier = 1 },
	{ name = "Epic", color = { 180, 80, 230 }, weight = 15, multiplier = 1 },
	{ name = "Legendary", color = { 255, 200, 50 }, weight = 8, multiplier = 1 },
	{ name = "Mythic", color = { 255, 80, 100 }, weight = 3, multiplier = 1 },
	{ name = "Secret", color = { 230, 60, 230 }, weight = 1, multiplier = 1 },
}

-- body/head are RGB triples. accessory picks the prop BrainrotFactory adds.
-- size scales the whole model: rarer brainrots stand taller.
BrainrotData.Characters = {
	{
		id = "ikanterbang",
		name = "Ikan Terbang Terbalik",
		rarity = "Common",
		price = 25,
		income = 1,
		desc = "Ikan yang berenang di langit dan terbang di laut. Bingung, tapi bahagia.",
		body = { 90, 160, 255 },
		head = { 140, 200, 255 },
		accessory = "fin",
		size = 1.0,
	},
	{
		id = "ayamroda",
		name = "Ayam Sepatu Roda",
		rarity = "Common",
		price = 60,
		income = 2,
		desc = "Ayam kampung yang menolak berjalan. Ia meluncur, dan ia bangga.",
		body = { 245, 245, 240 },
		head = { 255, 120, 90 },
		accessory = "skates",
		size = 1.0,
	},
	{
		id = "kapalkertas",
		name = "Kapal Kertas Raksasa",
		rarity = "Rare",
		price = 200,
		income = 5,
		desc = "Kapal kertas sebesar rumah. Tidak pernah tenggelam, cuma basah sedikit.",
		body = { 255, 250, 230 },
		head = { 255, 220, 120 },
		accessory = "paper",
		size = 1.15,
	},
	{
		id = "monyes",
		name = "Monyet Jual Es Kelapa",
		rarity = "Rare",
		price = 400,
		income = 8,
		desc = "Monyet penjual es kelapa. Esnya dingin, harganya naik tiap jam.",
		body = { 170, 120, 70 },
		head = { 200, 160, 110 },
		accessory = "ice",
		size = 1.15,
	},
	{
		id = "kudalaut",
		name = "Kuda Laut DJ Pantai",
		rarity = "Epic",
		price = 900,
		income = 15,
		desc = "DJ kuda laut. Lagunya cuma satu, tapi ombak ikut joget.",
		body = { 255, 150, 200 },
		head = { 255, 200, 220 },
		accessory = "headphones",
		size = 1.3,
	},
	{
		id = "nasigoreng",
		name = "Nasi Goreng Terbang",
		rarity = "Epic",
		price = 1400,
		income = 22,
		desc = "Sepiring nasi goreng yang belajar terbang demi pelanggan yang lapar.",
		body = { 230, 170, 80 },
		head = { 255, 210, 130 },
		accessory = "wok",
		size = 1.3,
	},
	{
		id = "pinisimalam",
		name = "Pinisi Terbang Malam",
		rarity = "Legendary",
		price = 4000,
		income = 50,
		desc = "Kapal Pinisi yang berlayar di langit malam, muatannya mimpi para pelaut.",
		body = { 150, 100, 50 },
		head = { 255, 240, 200 },
		accessory = "sail",
		size = 1.5,
	},
	{
		id = "hantukaraoke",
		name = "Hantu Laut Karaoke",
		rarity = "Legendary",
		price = 7500,
		income = 80,
		desc = "Hantu laut yang tidak menakut-nakuti, cuma minta giliran nyanyi.",
		body = { 200, 230, 255 },
		head = { 240, 250, 255 },
		accessory = "mic",
		size = 1.5,
	},
	{
		id = "rajaudang",
		name = "Raja Udang Emas",
		rarity = "Mythic",
		price = 20000,
		income = 150,
		desc = "Raja segala udang. Mahkotanya emas, kumisnya panjang, egonya lebih panjang.",
		body = { 255, 180, 60 },
		head = { 255, 215, 120 },
		accessory = "crown",
		size = 1.7,
	},
	{
		id = "nagabambu",
		name = "Naga Bambu Bernyanyi",
		rarity = "Mythic",
		price = 40000,
		income = 250,
		desc = "Naga dari bambu tua yang menyanyi tiap subuh. Suaranya bikin padi tumbuh.",
		body = { 90, 200, 110 },
		head = { 160, 230, 140 },
		accessory = "flute",
		size = 1.7,
	},
	{
		id = "sultansagu",
		name = "Sultan Sagu Raksasa",
		rarity = "Secret",
		price = 120000,
		income = 500,
		desc = "Sultan sagu setinggi rumah. Sekali melangkah, harga sagu naik seminggu.",
		body = { 250, 240, 210 },
		head = { 255, 215, 160 },
		accessory = "turban",
		size = 2.0,
	},
	{
		id = "dewaombak",
		name = "Dewa Ombak Pinisi",
		rarity = "Secret",
		price = 300000,
		income = 1000,
		desc = "Dewa ombak yang menunggangi Pinisi. Katanya ia yang mengajari laut bergelombang.",
		body = { 60, 140, 255 },
		head = { 150, 210, 255 },
		accessory = "wave",
		size = 2.0,
	},
}

-- Mutations: rolled when a brainrot is bought, and re-rollable in MutationService.
BrainrotData.Mutations = {
	{ name = "Normal", multiplier = 1, color = { 255, 255, 255 }, chance = 82 },
	{ name = "Golden", multiplier = 2, color = { 255, 215, 0 }, chance = 12 },
	{ name = "Diamond", multiplier = 4, color = { 160, 220, 255 }, chance = 4 },
	{ name = "Rainbow", multiplier = 8, color = { 255, 100, 220 }, chance = 2 },
}

function BrainrotData.getById(id)
	for _, char in ipairs(BrainrotData.Characters) do
		if char.id == id then
			return char
		end
	end
	return nil
end

function BrainrotData.getRarity(name)
	for _, rarity in ipairs(BrainrotData.Rarities) do
		if rarity.name == name then
			return rarity
		end
	end
	return nil
end

-- Pick a random character, weighted by its rarity (common shows up most).
function BrainrotData.rollCharacter()
	local totalWeight = 0
	for _, rarity in ipairs(BrainrotData.Rarities) do
		totalWeight = totalWeight + rarity.weight
	end
	local roll = math.random(1, totalWeight)
	local running = 0
	local pickedRarity = "Common"
	for _, rarity in ipairs(BrainrotData.Rarities) do
		running = running + rarity.weight
		if roll <= running then
			pickedRarity = rarity.name
			break
		end
	end
	local pool = {}
	for _, char in ipairs(BrainrotData.Characters) do
		if char.rarity == pickedRarity then
			table.insert(pool, char)
		end
	end
	return pool[math.random(1, #pool)]
end

-- Roll a mutation for a fresh brainrot: most are Normal, Rainbow is rare.
function BrainrotData.rollMutation()
	local roll = math.random(1, 100)
	local running = 0
	for _, mutation in ipairs(BrainrotData.Mutations) do
		running = running + mutation.chance
		if roll <= running then
			return mutation
		end
	end
	return BrainrotData.Mutations[1]
end

-- Format money the way the HUD shows it: $1,250 and $1.2M for big sums.
function BrainrotData.formatMoney(amount)
	amount = math.floor(amount + 0.5)
	if amount >= 1000000 then
		return "$" .. string.format("%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		local text = tostring(amount)
		local out = ""
		while #text > 3 do
			out = "," .. string.sub(text, -3) .. out
			text = string.sub(text, 1, #text - 3)
		end
		return "$" .. text .. out
	else
		return "$" .. tostring(amount)
	end
end

return BrainrotData
