-- Standard awesome library
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
vicious         = require("vicious")
local naughty   = require("naughty")
local minitray  = require("minitray")
xdg_menu        = require("kdemenu")
local lain      = require("lain")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/keiko/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
browser = "firefox"
kshutdown = "kshutdown"
fileman = "dolphin"
--
modkey = "Mod4"
-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    lain.layout.uselesstile,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max
    --awful.layout.suit.fair,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
 tags = {
   --names  = { "独", "孤", "九", "剣" },
   names  = { "ora", "pla", "nkt", "onx" },
   layout = { layouts[1], layouts[2], layouts[4], layouts[6]
 }}
 for s = 1, screen.count() do
     -- Each screen has its own tag table.
     tags[s] = awful.tag(tags.names, s, tags.layout)
 end
-- }}}
-- {{{ AUTOSTART
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

--run_once("xcmenu -d")
run_once("nitrogen --restore")
--run_once("sh ~/.fehbg")
run_once("compton")
-- }}}

--MUH MENU
mymainmenu = awful.menu({ items = {
  { "kde/apps",     xdgmenu },
  { "dolphin",      fileman },
  { "system",       "systemsettings" },
  { "shutdown",     kshutdown }
}
})
--
mylauncher = awful.widget.launcher({ menu = mymainmenu })

-- Wibox
markup = lain.util.markup
gray = "#a3a3a3"
--|SEPARATOR|
separator = wibox.widget.textbox()
separator:set_markup("<span color='#353535' font='meslo lg s for powerline 9' >  </span>")
separator2 = wibox.widget.textbox()
separator2:set_markup("<span color='#353535' font='meslo lg s for powerline 9' >  </span>")
space = wibox.widget.textbox()
space:set_markup(" ")
--|MPD|
music = wibox.widget.textbox()
music:set_markup("<span font=\"stlarch 8\"color=\"#E0948B\"></span> ")
--
mpdwidget = lain.widgets.mpd({
    settings = function()
        artist = mpd_now.artist .. " - "
        title = mpd_now.title .. ""

        if mpd_now.state == "pause" then
            artist = "mpd "
            title = "paused "
        elseif mpd_now.state == "stop" then
            artist = "NULL"
            title = ""
        end

        widget:set_markup(markup(gray, artist) .. title)
    end
})
--|CPU|
cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, '<span font="stlarch 8"color=\"#BE8BE0\"></span> <span color="#a3a3a3">$1%</span>', 2)
--|MEM|
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, '<span >/</span><span color="#a3a3a3">$2M</span>', 5)
--|WWW|
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net, '<span font="stlarch 8"color=\"#00a2aa\"></span> <span color="#a3a3a3">${enp1s0 down_kb}/</span><span color="#a3a3a3">${enp1s0 up_kb}</span> <span font="stlarch 8"color=\"#CA2E87\"></span>', 3)
--|CLOCK|
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, '<span font="stlarch 8"color=\"#8F8799\"></span> <span color=\"#a3a3a3\" >%m/%d,%a %R</span> ', 5)
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
txtlayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- Writes a string representation of the current layout in a textbox widget
function updatelayoutbox(layout, s)
    local screen = s or 1
    local txt_l = beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(screen))] or ""
    layout:set_text(txt_l)
end

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    txtlayoutbox[s] = wibox.widget.textbox(beautiful["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])
    awful.tag.attached_connect_signal(s, "property::selected", function ()
        updatelayoutbox(txtlayoutbox[s], s)
    end)
    awful.tag.attached_connect_signal(s, "property::layout", function ()
        updatelayoutbox(txtlayoutbox[s], s)
    end)
    txtlayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", height = "12", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    --left_layout:add(separator2)
    left_layout:add(txtlayoutbox[s])
    left_layout:add(separator2)
    left_layout:add(mypromptbox[s])
    
    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then 
    right_layout:add(separator)  
    right_layout:add(music)
    right_layout:add(mpdwidget)
    right_layout:add(separator)
    right_layout:add(cpuwidget)
    right_layout:add(memwidget)
    right_layout:add(separator)
    right_layout:add(netwidget)
    right_layout:add(separator)
    right_layout:add(datewidget)
    --right_layout:add(wibox.widget.systray())
    end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    --awful.button({ }, 5, awful.tag.viewnext),
    --awful.button({ }, 4, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,            }, ",",   awful.tag.viewprev ),
    awful.key({ modkey,            }, ".",   awful.tag.viewnext ),
    awful.key({ modkey,            }, "Escape", awful.tag.history.restore),
    awful.key({ modkey }, "Down",  function () awful.client.moveresize( 0,   1,    0,   0) end),
    awful.key({ modkey }, "Up",    function () awful.client.moveresize( 0,  -1,    0,   0) end),
    awful.key({ modkey }, "Left",  function () awful.client.moveresize(-1,   0,    0,   0) end),
    awful.key({ modkey }, "Right", function () awful.client.moveresize( 1,   0,    0,   0) end),
    awful.key({ modkey , "Control" }, "Down", function () awful.client.moveresize( 0,   0,   0,   20) end),
    awful.key({ modkey , "Control" }, "Up", function () awful.client.moveresize(   0,   0,   0,  -20) end),
    awful.key({ modkey , "Control" }, "Left", function () awful.client.moveresize( 0,   0,  -20,   0) end),
    awful.key({ modkey , "Control" }, "Right", function () awful.client.moveresize(0,   0,   20,   0) end),
    awful.key({ modkey }, "Next",  function () awful.client.moveresize( 1,   1,   -2,  -2) end),
    awful.key({ modkey }, "Prior", function () awful.client.moveresize(-1,  -1,    2,   2) end),
    --APPS
    awful.key({ modkey,            }, "d", function () awful.util.spawn("dolphin") end),
    awful.key({ modkey,            }, "f", function () awful.util.spawn("firefox") end),
    awful.key({ "Control", "Shift" }, "`", function () awful.util.spawn("ksysguard") end),
    awful.key({ modkey,            }, "z", function () awful.util.spawn("goldendict") end),
    awful.key({ modkey,            }, "s", function () awful.util.spawn("kcolorchooser") end),
    awful.key({ modkey,            }, "/", function () awful.util.spawn("keepassx") end),
    awful.key({ }, "Print", function () awful.util.spawn("scrot") end),
    --STATUS
    awful.key({ modkey,            }, "`", function() minitray.toggle({ x = 1700, height = 14 }) end),
    awful.key({ modkey             }, "b", function () 
      mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
 end),
    
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.01)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.01)    end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.client.incwfact( 0.01)  end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.client.incwfact(-0.01)  end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incnmaster(-1)      end),
    --awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end)
    --awful.key({ modkey }, "x",
              --function ()
                  --awful.prompt.run({ prompt = "Run Lua code: " },
                  --mypromptbox[mouse.screen].widget,
                  --awful.util.eval, nil,
                  --awful.util.getdir("cache") .. "/history_eval")
              --end),
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
		     callback = awful.client.setslave,
		     size_hints_honor = false,
                     buttons = clientbuttons } },
    { rule = { class = "mpv" },
      properties = { floating = true, size_hints_honor = true } },
    { rule = { class = "Gimp-2.8" },
      properties = { floating = true } },
    { rule = { class = "Steam" },
      properties = { floating = true, tag = tags[1][1] } },
    { rule = { class = "Wine" },
      properties = { floating = true } },
    { rule = { class = "Plugin-container" },
      properties = { floating = true } },
    { rule = { class = "Firefox", role = "Organizer" },
      properties = { floating = true } },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { class = "VirtualBox" },
      properties = { floating = true } },
    {
      rule_any =
      {
           class =
           {
                "Plugin-container",
		--"Wine",
                "Steam"
            }
        },
        properties = { border_width = 0 }
    },
    {
        rule_any =
        {
            class =
            {
                "mpv",
		"Wine",
            }
        },
        properties = { x = 1280, y = 0 }
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)


client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

local hook = function(c)
    if c.maximized_horizontal == true and c.maximized_vertical == true then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width
    end
end
client.connect_signal("property::maximized_horizontal", hook) client.connect_signal("property::maximized_vertical", hook)
-- }}}