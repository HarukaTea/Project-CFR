
--// https://github.com/metatablesnow/HarukaRichTextFormatter

local HarukaRichTextFormatter = {}

function HarukaRichTextFormatter.Stroke(
	text: string,
	color: string,
	thickness: number?,
	joinMode: string?,
	transparency: number?
): string
	return '<stroke color="'
		.. "#"..color
		.. '" joins="'
		.. string.lower(joinMode or "Miter")
		.. '" thickness="'
		.. tostring(thickness or 1)
		.. '" transparency="'
		.. tostring(transparency or 0)
		.. '">'
		.. text
		.. "</stroke>"
end

function HarukaRichTextFormatter.Highlight(text: string, color: string, transparency: number): string
	local transparencyAttribute = ' transparency="' .. (transparency or 0) .. '"'

	local fontStart, fontEnd = string.find(text, "^<font.->")
	local fontCloseStart = string.find(text, "</font>")

	if fontStart and fontCloseStart then
		local fontOpen = string.sub(text, fontStart, fontEnd)
		local innerText = string.sub(text, fontEnd + 1, fontCloseStart - 1)
		local fontClose = "</font>"

		local marked = '<mark color="'
			.. "#"..color
			.. '"'
			.. transparencyAttribute
			.. ">"
			.. innerText
			.. "</mark>"
		return fontOpen .. marked .. fontClose
	else
		return '<mark color="' .. "#"..color .. '"' .. transparencyAttribute .. ">" .. text .. "</mark>"
	end
end

return HarukaRichTextFormatter
