-- Rex configuration: tmux muscle memory on a ctrl+b prefix.
-- Cmd shortcuts are left as Rex's defaults (cmd+k stays the session picker).

local P = "ctrl+b>"

-- Programs that use ctrl+b themselves still get it with ctrl+b ctrl+b
rex.bind(P .. "ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- Vim-style pane switching
rex.bind(P .. "h", "pane.focus", { direction = "left" })
rex.bind(P .. "j", "pane.focus", { direction = "down" })
rex.bind(P .. "k", "pane.focus", { direction = "up" })
rex.bind(P .. "l", "pane.focus", { direction = "right" })
rex.bind(P .. "o", "pane.focus_next")

-- Splits on | and -
rex.bind(P .. "shift+\\", "pane.split", { direction = "right" })
rex.bind(P .. "-", "pane.split", { direction = "down" })

-- Resizing. Rex has no repeat timer, so tmux's `bind -r H/J/K/L` becomes a
-- mode: ctrl+b shift+h/j/k/l enters resize mode, where h/j/k/l (shifted or
-- not) resize 5% per press until escape or enter.
rex.mode("resize", { exclusive = true })
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind(P .. "shift+" .. key, "client.mode.enter", { name = "resize" })
  rex.bind("resize/" .. key, "pane.resize", { direction = dir })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir })
end
rex.bind("resize/escape", "client.mode.exit")
rex.bind("resize/enter", "client.mode.exit")

-- Panes
rex.bind(P .. "z", "pane.zoom")
rex.bind(P .. "x", "pane.close")
rex.bind(P .. "shift+1", "pane.move_to_new_tab")
rex.bind(P .. "=", "pane.balance")

-- Tabs (tmux windows)
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "n", "client.tab.next")
rex.bind(P .. "p", "client.tab.previous")
rex.bind(P .. ",", "client.tab.rename")
for i = 1, 9 do
  rex.bind(P .. i, "client.tab.goto", { index = i })
end

-- Sessions
rex.bind(P .. "s", "session.switch")
rex.bind(P .. "shift+4", "session.rename")
rex.bind(P .. "shift+9", "session.previous")
rex.bind(P .. "shift+0", "session.next")

-- Misc
rex.bind(P .. "r", "client.config.reload")
rex.bind(P .. "[", "client.find.open")
