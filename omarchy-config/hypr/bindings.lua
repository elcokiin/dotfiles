-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Replace defaults with personal shortcuts (unbind first, then bind).

-- Web apps
hl.unbind("SUPER + SHIFT + A") -- ChatGPT -> Gemini
o.bind("SUPER + SHIFT + A", "Gemini", { webapp = "https://gemini.google.com" })

hl.unbind("SUPER + SHIFT + ALT + A") -- Grok -> Claude
o.bind("SUPER + SHIFT + ALT + A", "Claude", { webapp = "https://claude.ai/new" })

hl.unbind("SUPER + SHIFT + C") -- Calendar (hey) -> Calendar (Google)
o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com/calendar/u/1/r?pli=1" })

hl.unbind("SUPER + SHIFT + E") -- Email -> Excalidraw
o.bind("SUPER + SHIFT + E", "Excalidraw", { webapp = "https://excalidraw.com/" })

hl.unbind("SUPER + SHIFT + ALT + E") -- New email -> Gmail
o.bind("SUPER + SHIFT + ALT + E", "Email", { webapp = "https://mail.google.com/mail/u/1/##inbox" })

hl.unbind("SUPER + ALT + SHIFT + F") -- File manager (cwd) -> FastFinger
o.bind("SUPER + SHIFT + ALT + F", "Fast Finger Test", { webapp = "https://10fastfingers.com/typing-test" })

hl.unbind("SUPER + SHIFT + G") -- Signal -> WhatsApp
o.bind("SUPER + SHIFT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

hl.unbind("SUPER + SHIFT + O") -- Obsidian -> Remnote (Obsidian moved to Super+Shift+Alt+O)
o.bind("SUPER + SHIFT + O", "Remnote", { webapp = "https://www.remnote.com/w/627812d7e202a30016685473/notes~" })

-- System
hl.unbind("SUPER + C") -- Universal copy -> copy history
o.bind("SUPER + C", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

hl.unbind("SUPER + SHIFT + S") -- Google Maps -> Screenshot
o.bind("SUPER + SHIFT + S", "Screenshot", "omarchy-capture-screenshot")

-- Extra personal shortcuts on free keys.
o.bind("SUPER + A", "Grok", { webapp = "https://grok.com/" })
o.bind("SUPER + SHIFT + ALT + C", "Chess", { webapp = "https://chess.com" })
o.bind("SUPER + ALT + C", "Calculator", "omacalc")
o.bind("SUPER + SHIFT + ALT + N", "Editor", { omarchy = "editor" })
o.bind("SUPER + SHIFT + ALT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
