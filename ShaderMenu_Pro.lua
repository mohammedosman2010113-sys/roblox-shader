--[[
	🎨 ShaderMenu Pro
	- 20 شادر في 4 أقسام (واقعي / فني / طبيعة / خيالي)
	- تبويب "ضبط": سطوع، تباين، تشبع، توهج، ضباب، وقت اليوم
	- قفل الشادر: يمنع اللعبة من تغيير الإضاءة ويطفي مؤثراتها القديمة
	- زر إرجاع الأصلي يرجّع كل شي مثل ما كان

	التركيب:
	  Studio  -> LocalScript داخل StarterPlayer > StarterPlayerScripts
	  Executor -> الصق السكربت كامل وشغّله
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local C3 = Color3.fromRGB

-- لو شغلت السكربت مرتين ينظف النسخة القديمة
if _G.__ShaderMenuCleanup then pcall(_G.__ShaderMenuCleanup) end

---------------------------------------------------------------------
-- القيم الافتراضية + بناء الأنماط
---------------------------------------------------------------------
local DEF = {
	L = {Brightness = 2.5, ClockTime = 14, ExposureCompensation = 0, Ambient = C3(70, 70, 70), OutdoorAmbient = C3(110, 110, 110), ColorShift_Top = C3(0, 0, 0)},
	A = {Density = 0.3, Offset = 0.2, Color = C3(199, 170, 140), Decay = C3(104, 112, 124), Glare = 0.2, Haze = 1.5},
	B = {Intensity = 0.5, Size = 40, Threshold = 1.8},
	C = {Brightness = 0, Contrast = 0.2, Saturation = 0.2, TintColor = C3(255, 255, 255)},
	R = {Intensity = 0.1, Spread = 0.8},
	D = {FarIntensity = 0.1, FocusDistance = 50, InFocusRadius = 40, NearIntensity = 0},
}

local function copy(t)
	local c = {}
	for k, v in pairs(t) do c[k] = v end
	return c
end

local function preset(cat, name, icon, accent, sky, o)
	local p = {cat = cat, name = name, icon = icon, accent = accent, sky = sky}
	for key, d in pairs(DEF) do
		local t = copy(d)
		if o[key] then
			for prop, v in pairs(o[key]) do t[prop] = v end
		end
		p[key] = t
	end
	return p
end

local PRESETS = {
	---------------- واقعي ----------------
	preset("real", "واقعي نهار", "☀️", C3(120, 185, 255), {C3(110, 165, 235), C3(215, 228, 242)}, {
		L = {Brightness = 3, ClockTime = 13, ExposureCompensation = 0.05, Ambient = C3(90, 90, 95), OutdoorAmbient = C3(120, 125, 135)},
		A = {Density = 0.25, Offset = 0.3, Color = C3(190, 205, 225), Decay = C3(130, 150, 180), Glare = 0.1, Haze = 1.2},
		B = {Intensity = 0.4, Size = 36, Threshold = 1.9},
		C = {Brightness = 0.01, Contrast = 0.15, Saturation = 0.15, TintColor = C3(255, 250, 240)},
		R = {Intensity = 0.12, Spread = 0.8},
		D = {FarIntensity = 0.05, FocusDistance = 60, InFocusRadius = 50},
	}),
	preset("real", "سينمائي", "🎬", C3(240, 190, 120), {C3(90, 110, 140), C3(220, 190, 150)}, {
		L = {Brightness = 3, ClockTime = 15.5, ExposureCompensation = 0.1, Ambient = C3(70, 70, 75), OutdoorAmbient = C3(110, 110, 120)},
		A = {Density = 0.3, Offset = 0.25, Color = C3(199, 170, 140), Decay = C3(104, 112, 124), Glare = 0.3, Haze = 1.5},
		B = {Intensity = 0.5, Size = 40, Threshold = 1.8},
		C = {Brightness = 0.02, Contrast = 0.28, Saturation = 0.2, TintColor = C3(255, 240, 225)},
		R = {Intensity = 0.15, Spread = 0.8},
		D = {FarIntensity = 0.12, FocusDistance = 50, InFocusRadius = 40},
	}),
	preset("real", "غروب ذهبي", "🌅", C3(255, 150, 60), {C3(90, 80, 130), C3(255, 170, 90)}, {
		L = {Brightness = 2.5, ClockTime = 18, ExposureCompensation = 0.2, Ambient = C3(120, 80, 60), OutdoorAmbient = C3(170, 110, 80)},
		A = {Density = 0.38, Offset = 0.1, Color = C3(255, 170, 110), Decay = C3(200, 90, 60), Glare = 0.8, Haze = 2.2},
		B = {Intensity = 0.9, Size = 56, Threshold = 1.4},
		C = {Brightness = 0.03, Contrast = 0.2, Saturation = 0.35, TintColor = C3(255, 220, 180)},
		R = {Intensity = 0.3, Spread = 1},
		D = {FarIntensity = 0.15, FocusDistance = 60, InFocusRadius = 45},
	}),
	preset("real", "صباح ضبابي", "🌫️", C3(200, 205, 215), {C3(170, 180, 195), C3(230, 228, 222)}, {
		L = {Brightness = 2, ClockTime = 6.5, ExposureCompensation = 0.1, Ambient = C3(100, 100, 110), OutdoorAmbient = C3(135, 135, 145)},
		A = {Density = 0.5, Offset = 0.15, Color = C3(220, 215, 210), Decay = C3(180, 175, 170), Glare = 0.2, Haze = 3},
		B = {Intensity = 0.5, Size = 44, Threshold = 1.6},
		C = {Brightness = 0.02, Contrast = 0.1, Saturation = -0.05, TintColor = C3(255, 248, 240)},
		R = {Intensity = 0.2, Spread = 1},
		D = {FarIntensity = 0.2, FocusDistance = 40, InFocusRadius = 30},
	}),
	preset("real", "ليل واقعي", "🌃", C3(100, 130, 255), {C3(10, 15, 40), C3(40, 55, 100)}, {
		L = {Brightness = 1.2, ClockTime = 0, ExposureCompensation = 0.3, Ambient = C3(30, 35, 70), OutdoorAmbient = C3(45, 55, 100)},
		A = {Density = 0.28, Offset = 0, Color = C3(50, 60, 110), Decay = C3(20, 25, 60), Glare = 0, Haze = 1},
		B = {Intensity = 0.8, Size = 50, Threshold = 1.2},
		C = {Brightness = 0, Contrast = 0.15, Saturation = 0.1, TintColor = C3(200, 215, 255)},
		R = {Intensity = 0, Spread = 0.5},
		D = {FarIntensity = 0.08, FocusDistance = 55, InFocusRadius = 40},
	}),

	---------------- فني ----------------
	preset("art", "سايبر بانك", "🌆", C3(255, 50, 200), {C3(60, 20, 110), C3(30, 190, 255)}, {
		L = {Brightness = 1.8, ClockTime = 22, ExposureCompensation = 0.2, Ambient = C3(80, 20, 110), OutdoorAmbient = C3(40, 120, 160)},
		A = {Density = 0.42, Offset = 0, Color = C3(190, 60, 220), Decay = C3(30, 200, 255), Glare = 0.4, Haze = 2.5},
		B = {Intensity = 1.4, Size = 60, Threshold = 0.9},
		C = {Brightness = 0, Contrast = 0.35, Saturation = 0.6, TintColor = C3(255, 200, 255)},
		R = {Intensity = 0.05, Spread = 0.6},
		D = {FarIntensity = 0.2, FocusDistance = 45, InFocusRadius = 30},
	}),
	preset("art", "أنمي حالم", "🌸", C3(255, 150, 190), {C3(150, 190, 255), C3(255, 215, 235)}, {
		L = {Brightness = 3.2, ClockTime = 13, ExposureCompensation = 0.4, Ambient = C3(170, 150, 170), OutdoorAmbient = C3(190, 170, 200)},
		A = {Density = 0.2, Offset = 0.4, Color = C3(255, 210, 230), Decay = C3(180, 200, 255), Glare = 0.2, Haze = 0.8},
		B = {Intensity = 1.1, Size = 70, Threshold = 1},
		C = {Brightness = 0.06, Contrast = 0.05, Saturation = 0.55, TintColor = C3(255, 235, 245)},
		R = {Intensity = 0.2, Spread = 1},
		D = {FarIntensity = 0.25, FocusDistance = 40, InFocusRadius = 25, NearIntensity = 0.1},
	}),
	preset("art", "أبيض وأسود", "🎞️", C3(200, 200, 200), {C3(70, 70, 70), C3(210, 210, 210)}, {
		L = {Brightness = 2.8, ClockTime = 16, Ambient = C3(80, 80, 80), OutdoorAmbient = C3(110, 110, 110)},
		A = {Density = 0.3, Offset = 0.2, Color = C3(190, 190, 190), Decay = C3(110, 110, 110), Glare = 0.2, Haze = 1.5},
		B = {Intensity = 0.4, Size = 36, Threshold = 1.8},
		C = {Brightness = 0, Contrast = 0.5, Saturation = -1, TintColor = C3(255, 255, 255)},
		R = {Intensity = 0.12, Spread = 0.8},
		D = {FarIntensity = 0.15, FocusDistance = 50, InFocusRadius = 35},
	}),
	preset("art", "ريترو دافئ", "📼", C3(230, 170, 110), {C3(150, 130, 120), C3(240, 205, 160)}, {
		L = {Brightness = 2.4, ClockTime = 16.5, ExposureCompensation = 0.15, Ambient = C3(110, 90, 80), OutdoorAmbient = C3(150, 125, 105)},
		A = {Density = 0.35, Offset = 0.2, Color = C3(235, 200, 160), Decay = C3(170, 130, 100), Glare = 0.3, Haze = 2},
		B = {Intensity = 0.8, Size = 55, Threshold = 1.3},
		C = {Brightness = 0.05, Contrast = -0.05, Saturation = -0.15, TintColor = C3(255, 225, 190)},
		R = {Intensity = 0.1, Spread = 0.8},
		D = {FarIntensity = 0.15, FocusDistance = 45, InFocusRadius = 35},
	}),
	preset("art", "نيون فاپور", "🟣", C3(190, 100, 255), {C3(255, 120, 210), C3(70, 200, 255)}, {
		L = {Brightness = 2, ClockTime = 20, ExposureCompensation = 0.2, Ambient = C3(110, 60, 150), OutdoorAmbient = C3(80, 150, 200)},
		A = {Density = 0.4, Offset = 0.1, Color = C3(255, 120, 220), Decay = C3(80, 200, 255), Glare = 0.5, Haze = 2.2},
		B = {Intensity = 1.3, Size = 64, Threshold = 1},
		C = {Brightness = 0.02, Contrast = 0.3, Saturation = 0.7, TintColor = C3(255, 185, 255)},
		R = {Intensity = 0.1, Spread = 0.8},
		D = {FarIntensity = 0.18, FocusDistance = 50, InFocusRadius = 35},
	}),

	---------------- طبيعة ----------------
	preset("nature", "غابة سحرية", "🌲", C3(90, 220, 140), {C3(60, 130, 110), C3(170, 235, 190)}, {
		L = {Brightness = 2.2, ClockTime = 9, ExposureCompensation = 0.15, Ambient = C3(40, 90, 70), OutdoorAmbient = C3(70, 140, 110)},
		A = {Density = 0.4, Offset = 0.15, Color = C3(150, 230, 190), Decay = C3(60, 140, 120), Glare = 0.3, Haze = 2.4},
		B = {Intensity = 1, Size = 55, Threshold = 1.2},
		C = {Brightness = 0.02, Contrast = 0.2, Saturation = 0.45, TintColor = C3(215, 255, 235)},
		R = {Intensity = 0.28, Spread = 0.9},
		D = {FarIntensity = 0.2, FocusDistance = 45, InFocusRadius = 30},
	}),
	preset("nature", "صحراء دافية", "🏜️", C3(235, 170, 80), {C3(110, 170, 230), C3(245, 215, 160)}, {
		L = {Brightness = 4, ClockTime = 14, ExposureCompensation = 0.1, Ambient = C3(130, 100, 70), OutdoorAmbient = C3(190, 150, 100)},
		A = {Density = 0.32, Offset = 0.3, Color = C3(240, 200, 140), Decay = C3(220, 150, 80), Glare = 0.5, Haze = 2},
		B = {Intensity = 0.7, Size = 48, Threshold = 1.5},
		C = {Brightness = 0.02, Contrast = 0.2, Saturation = 0.3, TintColor = C3(255, 230, 190)},
		R = {Intensity = 0.25, Spread = 1},
		D = {FarIntensity = 0.1, FocusDistance = 60, InFocusRadius = 50},
	}),
	preset("nature", "شتاء ثلجي", "❄️", C3(170, 215, 255), {C3(160, 190, 225), C3(235, 242, 252)}, {
		L = {Brightness = 3, ClockTime = 12, ExposureCompensation = 0.3, Ambient = C3(140, 160, 185), OutdoorAmbient = C3(170, 190, 215)},
		A = {Density = 0.45, Offset = 0.2, Color = C3(215, 230, 250), Decay = C3(150, 180, 220), Glare = 0.1, Haze = 2.8},
		B = {Intensity = 0.7, Size = 45, Threshold = 1.3},
		C = {Brightness = 0.04, Contrast = 0.1, Saturation = -0.1, TintColor = C3(225, 240, 255)},
		R = {Intensity = 0.1, Spread = 0.9},
		D = {FarIntensity = 0.12, FocusDistance = 50, InFocusRadius = 35},
	}),
	preset("nature", "استوائي", "🏝️", C3(60, 215, 210), {C3(60, 170, 240), C3(190, 245, 245)}, {
		L = {Brightness = 3.5, ClockTime = 12, ExposureCompensation = 0.1, Ambient = C3(100, 130, 140), OutdoorAmbient = C3(140, 180, 190)},
		A = {Density = 0.25, Offset = 0.3, Color = C3(150, 230, 240), Decay = C3(60, 180, 200), Glare = 0.3, Haze = 1},
		B = {Intensity = 0.7, Size = 48, Threshold = 1.5},
		C = {Brightness = 0.02, Contrast = 0.2, Saturation = 0.5, TintColor = C3(230, 255, 255)},
		R = {Intensity = 0.2, Spread = 1},
		D = {FarIntensity = 0.1, FocusDistance = 60, InFocusRadius = 50},
	}),
	preset("nature", "مطر وعاصفة", "🌧️", C3(130, 150, 175), {C3(70, 80, 95), C3(140, 150, 165)}, {
		L = {Brightness = 1, ClockTime = 15, ExposureCompensation = -0.05, Ambient = C3(60, 68, 80), OutdoorAmbient = C3(85, 95, 110)},
		A = {Density = 0.55, Offset = 0, Color = C3(110, 120, 135), Decay = C3(70, 80, 95), Glare = 0, Haze = 3.5},
		B = {Intensity = 0.4, Size = 36, Threshold = 1.7},
		C = {Brightness = -0.02, Contrast = 0.25, Saturation = -0.25, TintColor = C3(210, 220, 235)},
		R = {Intensity = 0, Spread = 0.5},
		D = {FarIntensity = 0.25, FocusDistance = 35, InFocusRadius = 25},
	}),
	preset("nature", "تحت الماء", "🌊", C3(50, 170, 220), {C3(20, 90, 140), C3(90, 200, 220)}, {
		L = {Brightness = 2.5, ClockTime = 12, ExposureCompensation = 0.1, Ambient = C3(30, 80, 110), OutdoorAmbient = C3(60, 130, 160)},
		A = {Density = 0.6, Offset = 0, Color = C3(60, 170, 200), Decay = C3(20, 90, 140), Glare = 0, Haze = 3},
		B = {Intensity = 0.9, Size = 52, Threshold = 1.3},
		C = {Brightness = 0.01, Contrast = 0.2, Saturation = 0.3, TintColor = C3(190, 240, 255)},
		R = {Intensity = 0.25, Spread = 1},
		D = {FarIntensity = 0.25, FocusDistance = 30, InFocusRadius = 20},
	}),

	---------------- خيالي ----------------
	preset("fantasy", "رعب مظلم", "👻", C3(120, 150, 120), {C3(15, 25, 20), C3(70, 90, 80)}, {
		L = {Brightness = 0.8, ClockTime = 3, ExposureCompensation = -0.1, Ambient = C3(25, 35, 30), OutdoorAmbient = C3(40, 55, 50)},
		A = {Density = 0.65, Offset = 0, Color = C3(90, 110, 100), Decay = C3(40, 55, 50), Glare = 0, Haze = 4},
		B = {Intensity = 0.4, Size = 30, Threshold = 1.6},
		C = {Brightness = -0.03, Contrast = 0.3, Saturation = -0.3, TintColor = C3(200, 230, 210)},
		R = {Intensity = 0, Spread = 0.5},
		D = {FarIntensity = 0.3, FocusDistance = 30, InFocusRadius = 20},
	}),
	preset("fantasy", "فضاء كوني", "🌌", C3(150, 100, 255), {C3(15, 10, 50), C3(110, 70, 200)}, {
		L = {Brightness = 1, ClockTime = 0, ExposureCompensation = 0.2, Ambient = C3(60, 40, 110), OutdoorAmbient = C3(90, 60, 160)},
		A = {Density = 0.15, Offset = 0, Color = C3(120, 80, 220), Decay = C3(40, 20, 100), Glare = 0, Haze = 1.5},
		B = {Intensity = 1.5, Size = 70, Threshold = 0.8},
		C = {Brightness = 0, Contrast = 0.3, Saturation = 0.5, TintColor = C3(230, 210, 255)},
		R = {Intensity = 0, Spread = 0.5},
		D = {FarIntensity = 0.15, FocusDistance = 60, InFocusRadius = 40},
	}),
	preset("fantasy", "جحيم ناري", "🔥", C3(255, 90, 30), {C3(60, 10, 5), C3(255, 110, 30)}, {
		L = {Brightness = 2, ClockTime = 18, ExposureCompensation = 0.1, Ambient = C3(120, 30, 10), OutdoorAmbient = C3(180, 60, 20)},
		A = {Density = 0.5, Offset = 0, Color = C3(255, 90, 30), Decay = C3(120, 20, 10), Glare = 0.6, Haze = 3.5},
		B = {Intensity = 1.3, Size = 60, Threshold = 1},
		C = {Brightness = 0, Contrast = 0.4, Saturation = 0.5, TintColor = C3(255, 190, 150)},
		R = {Intensity = 0.25, Spread = 1},
		D = {FarIntensity = 0.2, FocusDistance = 45, InFocusRadius = 30},
	}),
	preset("fantasy", "حلم بنفسجي", "💜", C3(200, 140, 255), {C3(110, 80, 190), C3(240, 190, 255)}, {
		L = {Brightness = 2.2, ClockTime = 19, ExposureCompensation = 0.25, Ambient = C3(110, 80, 150), OutdoorAmbient = C3(150, 110, 200)},
		A = {Density = 0.35, Offset = 0.1, Color = C3(230, 180, 255), Decay = C3(150, 100, 230), Glare = 0.4, Haze = 2},
		B = {Intensity = 1.1, Size = 65, Threshold = 1},
		C = {Brightness = 0.03, Contrast = 0.15, Saturation = 0.4, TintColor = C3(245, 225, 255)},
		R = {Intensity = 0.15, Spread = 0.9},
		D = {FarIntensity = 0.2, FocusDistance = 45, InFocusRadius = 30},
	}),
}

---------------------------------------------------------------------
-- الحالة
---------------------------------------------------------------------
local state = {
	preset = nil,
	lock = true,
	tweak = {bright = 0, contrast = 0, sat = 0, bloom = 1, fog = 1, clock = nil},
}

local original = {}
for k in pairs(DEF.L) do original[k] = Lighting[k] end
local origTech = Lighting.Technology

local CLASS = {
	A = {"Atmosphere", "SH_Atmosphere"},
	B = {"BloomEffect", "SH_Bloom"},
	C = {"ColorCorrectionEffect", "SH_Color"},
	R = {"SunRaysEffect", "SH_Rays"},
	D = {"DepthOfFieldEffect", "SH_DOF"},
}

local stash = {} -- مؤثرات اللعبة اللي طفيناها عشان نرجعها بعدين

local function isOurs(i) return string.sub(i.Name, 1, 3) == "SH_" end

local function silence(i)
	if isOurs(i) then return end
	if i:IsA("PostEffect") then
		if not stash[i] then stash[i] = {parent = i.Parent, enabled = i.Enabled} end
		if i.Enabled then pcall(function() i.Enabled = false end) end
	elseif i:IsA("Atmosphere") then
		if not stash[i] then stash[i] = {parent = i.Parent} end
		pcall(function() i.Parent = nil end)
	end
end

local function restoreStash()
	for i, d in pairs(stash) do
		pcall(function()
			if i:IsA("PostEffect") then i.Enabled = d.enabled else i.Parent = d.parent end
		end)
	end
	stash = {}
end

local function ensure()
	local map = {L = Lighting}
	for key, info in pairs(CLASS) do
		local e = Lighting:FindFirstChild(info[2])
		if not e or not e:IsA(info[1]) then
			if e then pcall(function() e:Destroy() end) end
			e = Instance.new(info[1])
			e.Name = info[2]
			if key == "A" then e.Density = 0
			elseif key == "B" or key == "R" then e.Intensity = 0
			elseif key == "D" then e.FarIntensity = 0 e.NearIntensity = 0 end
			e.Parent = Lighting
		end
		if e:IsA("PostEffect") and not e.Enabled then e.Enabled = true end
		map[key] = e
	end
	return map
end

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

local function target()
	local p = state.preset
	if not p then return nil end
	local t = state.tweak
	local out = {L = copy(p.L), A = copy(p.A), B = copy(p.B), C = copy(p.C), R = copy(p.R), D = copy(p.D)}
	if t.clock then out.L.ClockTime = t.clock end
	out.A.Density = clamp(out.A.Density * t.fog, 0, 1)
	out.A.Haze = clamp(out.A.Haze * t.fog, 0, 10)
	out.B.Intensity = clamp(out.B.Intensity * t.bloom, 0, 3)
	out.C.Brightness = clamp(out.C.Brightness + t.bright, -1, 1)
	out.C.Contrast = clamp(out.C.Contrast + t.contrast, -1, 1)
	out.C.Saturation = clamp(out.C.Saturation + t.sat, -1, 1)
	return out
end

local tweenUntil = 0

local function applyTween(dur)
	local tg = target()
	if not tg then return end
	for _, i in ipairs(Lighting:GetChildren()) do silence(i) end
	local map = ensure()
	tweenUntil = os.clock() + dur
	for key, props in pairs(tg) do
		local obj = map[key]
		if dur > 0 then
			pcall(function()
				TweenService:Create(obj, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), props):Play()
			end)
		else
			for prop, v in pairs(props) do pcall(function() obj[prop] = v end) end
		end
	end
end

local function resetAll()
	state.preset = nil
	tweenUntil = os.clock() + 1.3
	pcall(function() TweenService:Create(Lighting, TweenInfo.new(1.2), original):Play() end)
	task.delay(1.3, function()
		if state.preset then return end
		for _, info in pairs(CLASS) do
			local e = Lighting:FindFirstChild(info[2])
			if e then pcall(function() e:Destroy() end) end
		end
		restoreStash()
	end)
end

local function differs(a, b)
	if typeof(a) == "Color3" then
		return math.abs(a.R - b.R) + math.abs(a.G - b.G) + math.abs(a.B - b.B) > 0.01
	end
	return math.abs(a - b) > 0.01
end

local function setFuture(on)
	local tech = on and Enum.Technology.Future or origTech
	local ok = pcall(function() Lighting.Technology = tech end)
	if not ok and typeof(sethiddenproperty) == "function" then
		ok = pcall(function() sethiddenproperty(Lighting, "Technology", tech) end)
	end
	return ok
end

---------------------------------------------------------------------
-- الواجهة
---------------------------------------------------------------------
local conns = {}
local function connect(sig, fn)
	local c = sig:Connect(fn)
	table.insert(conns, c)
	return c
end

local gui = Instance.new("ScreenGui")
gui.Name = "ShaderMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okHui, hui = pcall(function() return gethui() end)
gui.Parent = (okHui and hui) or player:WaitForChild("PlayerGui")

local BG, CARD = C3(20, 20, 28), C3(32, 32, 44)
local ACCENT = C3(90, 120, 255)
local W, H = 300, 340

local function corner(i, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = i
end

local function label(parent, text, size, bold, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = size
	l.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
	l.TextColor3 = color or C3(235, 235, 245)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(W, H)
main.Position = UDim2.new(0, 12, 0.5, -H / 2)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
corner(main, 14)
local stroke = Instance.new("UIStroke")
stroke.Color = C3(70, 70, 95)
stroke.Thickness = 1.3
stroke.Parent = main

-- الهيدر
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = CARD
header.BorderSizePixel = 0
header.Parent = main

local TITLE = "🎨 الشادرات"
local title = label(header, TITLE, 16, true)
title.Size = UDim2.new(1, -56, 1, 0)
title.Position = UDim2.fromOffset(12, 0)

local function toast(msg)
	title.Text = msg
	task.delay(2.2, function()
		if title and title.Parent then title.Text = TITLE end
	end)
end

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(32, 26)
minBtn.Position = UDim2.new(1, -40, 0.5, -13)
minBtn.BackgroundColor3 = C3(50, 50, 68)
minBtn.Text = "–"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = C3(255, 255, 255)
minBtn.Parent = header
corner(minBtn, 8)

-- التبويبات
local TABS = {
	{"real", "📷 واقعي"}, {"art", "🎨 فني"}, {"nature", "🌿 طبيعة"}, {"fantasy", "✨ خيالي"}, {"set", "⚙ ضبط"},
}
local tabsRow = Instance.new("Frame")
tabsRow.Size = UDim2.new(1, -12, 0, 30)
tabsRow.Position = UDim2.fromOffset(6, 42)
tabsRow.BackgroundTransparency = 1
tabsRow.Parent = main
local tl = Instance.new("UIListLayout")
tl.FillDirection = Enum.FillDirection.Horizontal
tl.SortOrder = Enum.SortOrder.LayoutOrder
tl.Padding = UDim.new(0, 4)
tl.Parent = tabsRow

local pages, tabBtns = {}, {}
local PAGE_H = H - 78 - 44

local function newPage()
	local s = Instance.new("ScrollingFrame")
	s.Size = UDim2.new(1, -12, 0, PAGE_H)
	s.Position = UDim2.fromOffset(6, 78)
	s.BackgroundTransparency = 1
	s.BorderSizePixel = 0
	s.ScrollBarThickness = 3
	s.CanvasSize = UDim2.new()
	s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.Visible = false
	s.Parent = main
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 6)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = s
	return s
end

local function showTab(key)
	for k, pg in pairs(pages) do pg.Visible = (k == key) end
	for k, tb in pairs(tabBtns) do
		tb.BackgroundColor3 = (k == key) and ACCENT or CARD
	end
end

for i, tb in ipairs(TABS) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, (W - 12 - 16) / 5, 1, 0)
	b.LayoutOrder = i
	b.BackgroundColor3 = CARD
	b.Text = tb[2]
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = C3(255, 255, 255)
	b.TextScaled = true
	b.AutoButtonColor = false
	b.Parent = tabsRow
	corner(b, 8)
	local cons = Instance.new("UITextSizeConstraint")
	cons.MaxTextSize = 12
	cons.MinTextSize = 7
	cons.Parent = b
	tabBtns[tb[1]] = b
	pages[tb[1]] = newPage()
	connect(b.Activated, function() showTab(tb[1]) end)
end

-- أزرار الأنماط
local selected
local clockSet -- يتعرّف بعدين

for idx, p in ipairs(PRESETS) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 44)
	b.LayoutOrder = idx
	b.BackgroundColor3 = CARD
	b.AutoButtonColor = false
	b.Text = ""
	b.Parent = pages[p.cat]
	corner(b, 10)

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 4, 0.6, 0)
	bar.Position = UDim2.new(0, 8, 0.2, 0)
	bar.BackgroundColor3 = p.accent
	bar.BorderSizePixel = 0
	bar.Parent = b
	corner(bar, 4)

	local lb = label(b, p.icon .. "  " .. p.name, 14, false)
	lb.Size = UDim2.new(1, -90, 1, 0)
	lb.Position = UDim2.fromOffset(22, 0)

	-- معاينة ألوان النمط
	local sw = Instance.new("Frame")
	sw.Size = UDim2.fromOffset(48, 28)
	sw.Position = UDim2.new(1, -58, 0.5, -14)
	sw.BackgroundColor3 = C3(255, 255, 255)
	sw.BorderSizePixel = 0
	sw.Parent = b
	corner(sw, 7)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new(p.sky[1], p.sky[2])
	g.Parent = sw

	connect(b.MouseEnter, function()
		if selected ~= b then TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = C3(44, 44, 60)}):Play() end
	end)
	connect(b.MouseLeave, function()
		if selected ~= b then TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = CARD}):Play() end
	end)
	connect(b.Activated, function()
		if selected then TweenService:Create(selected, TweenInfo.new(0.2), {BackgroundColor3 = CARD}):Play() end
		selected = b
		TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = p.accent:Lerp(CARD, 0.7)}):Play()
		stroke.Color = p.accent
		state.preset = p
		state.tweak.clock = nil
		if clockSet then clockSet(p.L.ClockTime, false) end
		applyTween(1.4)
		toast(p.icon .. " " .. p.name)
	end)
end

-- عناصر صفحة الضبط
local setPage = pages["set"]
local order = 0
local function nextOrder() order += 1 return order end

local function slider(label_, min, max, def, fmt, onChange)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -4, 0, 48)
	f.LayoutOrder = nextOrder()
	f.BackgroundColor3 = CARD
	f.Parent = setPage
	corner(f, 10)

	local lb = label(f, label_, 13, false)
	lb.Size = UDim2.new(1, -70, 0, 20)
	lb.Position = UDim2.fromOffset(10, 4)
	local vl = label(f, "", 12, true, C3(170, 180, 255))
	vl.Size = UDim2.fromOffset(52, 20)
	vl.Position = UDim2.new(1, -60, 0, 4)
	vl.TextXAlignment = Enum.TextXAlignment.Right

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -28, 0, 6)
	track.Position = UDim2.new(0, 14, 0, 33)
	track.BackgroundColor3 = C3(60, 60, 80)
	track.BorderSizePixel = 0
	track.Parent = f
	corner(track, 3)
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = ACCENT
	fill.BorderSizePixel = 0
	fill.Parent = track
	corner(fill, 3)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = C3(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = track
	corner(knob, 8)

	local function set(v, fire)
		v = clamp(v, min, max)
		local a = (v - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		vl.Text = string.format(fmt, v)
		if fire and onChange then onChange(v) end
	end
	set(def, false)

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.new(1, 0, 0, 28)
	hit.Position = UDim2.new(0, 0, 1, -30)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.Parent = f

	local dragging = false
	local function fromInput(input)
		local a = clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		set(min + (max - min) * a, true)
	end
	connect(hit.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setPage.ScrollingEnabled = false
			fromInput(input)
		end
	end)
	connect(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromInput(input)
		end
	end)
	connect(UIS.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			setPage.ScrollingEnabled = true
		end
	end)
	return set
end

local function toggle(text, def, onChange)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -4, 0, 40)
	b.LayoutOrder = nextOrder()
	b.BackgroundColor3 = CARD
	b.AutoButtonColor = false
	b.Text = ""
	b.Parent = setPage
	corner(b, 10)
	local lb = label(b, text, 12, false)
	lb.Size = UDim2.new(1, -70, 1, 0)
	lb.Position = UDim2.fromOffset(10, 0)
	lb.TextWrapped = true
	local pill = Instance.new("Frame")
	pill.Size = UDim2.fromOffset(42, 22)
	pill.Position = UDim2.new(1, -52, 0.5, -11)
	pill.BorderSizePixel = 0
	pill.Parent = b
	corner(pill, 11)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(16, 16)
	dot.BackgroundColor3 = C3(255, 255, 255)
	dot.BorderSizePixel = 0
	dot.Parent = pill
	corner(dot, 8)
	local on = def
	local function render()
		pill.BackgroundColor3 = on and C3(60, 190, 110) or C3(80, 80, 100)
		dot.Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	end
	render()
	connect(b.Activated, function()
		on = not on
		render()
		onChange(on, function(v) on = v render() end)
	end)
end

local tw = state.tweak
local function retune() applyTween(0.12) end
local setBright = slider("☀️ السطوع", -0.2, 0.2, 0, "%+.2f", function(v) tw.bright = v retune() end)
local setContrast = slider("◐ التباين", -0.3, 0.3, 0, "%+.2f", function(v) tw.contrast = v retune() end)
local setSat = slider("🎨 التشبع", -0.5, 0.5, 0, "%+.2f", function(v) tw.sat = v retune() end)
local setBloom = slider("✨ التوهج", 0, 2, 1, "x%.2f", function(v) tw.bloom = v retune() end)
local setFog = slider("🌫️ الضباب", 0, 2, 1, "x%.2f", function(v) tw.fog = v retune() end)
clockSet = slider("🕒 وقت اليوم", 0, 24, 14, "%.1f", function(v) tw.clock = v retune() end)

toggle("🔒 قفل الشادر (يمنع اللعبة من تغييره)", true, function(on) state.lock = on end)
toggle("💡 إضاءة Future (تشتغل في بعض الأجهزة فقط)", false, function(on, setBack)
	if not setFuture(on) then
		toast("❌ ما انسمح بتغييرها")
		setBack(false)
	end
end)

local zero = Instance.new("TextButton")
zero.Size = UDim2.new(1, -4, 0, 34)
zero.LayoutOrder = nextOrder()
zero.BackgroundColor3 = C3(55, 55, 75)
zero.Text = "↺ تصفير الضبط اليدوي"
zero.Font = Enum.Font.GothamBold
zero.TextSize = 13
zero.TextColor3 = C3(255, 255, 255)
zero.Parent = setPage
corner(zero, 10)
connect(zero.Activated, function()
	tw.bright, tw.contrast, tw.sat, tw.bloom, tw.fog, tw.clock = 0, 0, 0, 1, 1, nil
	setBright(0, false) setContrast(0, false) setSat(0, false) setBloom(1, false) setFog(1, false)
	if state.preset then clockSet(state.preset.L.ClockTime, false) end
	applyTween(0.4)
end)

-- زر الإرجاع
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -12, 0, 32)
resetBtn.Position = UDim2.new(0, 6, 1, -38)
resetBtn.BackgroundColor3 = C3(150, 50, 60)
resetBtn.Text = "⟲  إرجاع الأصلي"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 14
resetBtn.TextColor3 = C3(255, 255, 255)
resetBtn.Parent = main
corner(resetBtn, 10)
connect(resetBtn.Activated, function()
	if selected then TweenService:Create(selected, TweenInfo.new(0.2), {BackgroundColor3 = CARD}):Play() end
	selected = nil
	stroke.Color = C3(70, 70, 95)
	resetAll()
	toast("↺ رجعت الإضاءة الأصلية")
end)

-- تصغير
local minimized = false
connect(minBtn.Activated, function()
	minimized = not minimized
	tabsRow.Visible = not minimized
	resetBtn.Visible = not minimized
	for _, pg in pairs(pages) do pg.Visible = false end
	if not minimized then
		for k, tb in pairs(tabBtns) do
			if tb.BackgroundColor3 == ACCENT then pages[k].Visible = true end
		end
	end
	minBtn.Text = minimized and "+" or "–"
	TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		Size = minimized and UDim2.fromOffset(W, 38) or UDim2.fromOffset(W, H)
	}):Play()
end)

-- سحب القائمة (ماوس + جوال)
local dragging, dragStart, startPos
connect(header.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging, dragStart, startPos = true, input.Position, main.Position
	end
end)
connect(UIS.InputChanged, function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local d = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
connect(UIS.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

showTab("real")

---------------------------------------------------------------------
-- القفل: يعيد تطبيق الشادر لو اللعبة غيّرت شي
---------------------------------------------------------------------
local acc = 0
connect(RunService.Heartbeat, function(dt)
	if not state.lock or not state.preset or os.clock() < tweenUntil + 0.2 then return end
	acc += dt
	if acc < 0.4 then return end
	acc = 0
	for _, i in ipairs(Lighting:GetChildren()) do silence(i) end
	local tg = target()
	local map = ensure()
	for key, props in pairs(tg) do
		local obj = map[key]
		for prop, v in pairs(props) do
			local ok, cur = pcall(function() return obj[prop] end)
			if ok and differs(cur, v) then pcall(function() obj[prop] = v end) end
		end
	end
end)

---------------------------------------------------------------------
-- تنظيف عند إعادة التشغيل
---------------------------------------------------------------------
_G.__ShaderMenuCleanup = function()
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	state.preset = nil
	for k, v in pairs(original) do pcall(function() Lighting[k] = v end) end
	for _, info in pairs(CLASS) do
		local e = Lighting:FindFirstChild(info[2])
		if e then pcall(function() e:Destroy() end) end
	end
	restoreStash()
	pcall(function() gui:Destroy() end)
end
