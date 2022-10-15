local superscripts = {
	["0"] = "⁰",
	["1"] = "¹",
	["2"] = "²",
	["3"] = "³",
	["4"] = "⁴",
	["5"] = "⁵",
	["6"] = "⁶",
	["7"] = "⁷",
	["8"] = "⁸",
	["9"] = "⁹",
	["-"] = "⁻",
	["+"] = "⁺",
	["n"] = "ⁿ",
}

local subscripts = {
	["0"] = "₀",
	["1"] = "₁",
	["2"] = "₂",
	["3"] = "₃",
	["4"] = "₄",
	["5"] = "₅",
	["6"] = "₆",
	["7"] = "₇",
	["8"] = "₈",
	["9"] = "₉",
	["a"] = "ₐ",
	["e"] = "ₑ",
	["o"] = "ₒ",
	["x"] = "ₓ",
	["y"] = "ᵧ",
	["h"] = "ₕ",
	["k"] = "ₖ",
	["l"] = "ₗ",
	["m"] = "ₘ",
	["n"] = "ₙ",
	["p"] = "ₚ",
	["s"] = "ₛ",
	["t"] = "ₜ",
	["-"] = "₋",
	["+"] = "₊",
}

local greeks = {
	["a"] = "α",
	["ps"] = "ψ",
	["b"] = "β",
	["t"] = "θ",
	["l"] = "λ",
	["L"] = "Λ",
	["ph"] = "φ",
	["pi"] = "π",
	["o"] = "ω",
	["D"] = "Δ",
	["d"] = "δ",
	["ga"] = "γ",
	["e"] = "η",
	["gr"] = "∇",
	["S"] = "Σ",
	["s"] = "σ",
	["m"] = "μ",
}

local function table_to_mapping(prefix, table)
	for lhs, rhs in pairs(table) do
		vim.keymap.set({"i", "c", "t"}, prefix..lhs, rhs, { buffer = true })
	end
end

table_to_mapping("<C-S-S>", superscripts)
table_to_mapping("<C-S>", subscripts)
table_to_mapping("<C-U>", greeks)
