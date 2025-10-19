--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local HarukaColorLab = {}


HarukaColorLab.COLOR_SERIES = {}

HarukaColorLab.COLOR_SERIES.Genshin = {
    Background = Color3.fromRGB(28, 28, 37),
    Title = Color3.fromHex('D3BC8E'),
    Text = Color3.fromHex('ECE5D8'),
    Text2 = Color3.fromHex('F6F2EE'),
    Text3 = Color3.fromHex('FFFFFF'),
    KeyText = Color3.fromHex('FFCC33'),
    KeyText2 = Color3.fromHex('37FFFF'),
    WarnText = Color3.fromHex('FF5E41'),
    WaterElement = Color3.fromHex('80C0FF'),
    FireElement = Color3.fromHex('FF9999'),
    WindElement = Color3.fromHex('80FFD7'),
    ThunderElement = Color3.fromHex('FFACFF'),
    GrassElement = Color3.fromHex('99FF88'),
    IceElement = Color3.fromHex('99FFFF'),
    EarthElement = Color3.fromHex('FFE699')
}

HarukaColorLab.COLOR_SERIES.AzurLane = {
    Background = Color3.fromHex('#eeece9'),
    Text = Color3.fromHex('#6c6763'),
    Green = Color3.fromHex('#7bd99f'),
    Red = Color3.fromHex('#ff7675'),
    Blue = Color3.fromHex('#7ce4f8'),
}


--// legacy references
HarukaColorLab.BLACK_COLOR = HarukaColorLab.COLOR_SERIES.Genshin.Background
HarukaColorLab.WHITE_COLOR = HarukaColorLab.COLOR_SERIES.AzurLane.Background
HarukaColorLab.RED_COLOR = HarukaColorLab.COLOR_SERIES.AzurLane.Red
HarukaColorLab.GREEN_COLOR = HarukaColorLab.COLOR_SERIES.AzurLane.Green
HarukaColorLab.AZUR_BLUE_COLOR = HarukaColorLab.COLOR_SERIES.AzurLane.Blue


return HarukaColorLab