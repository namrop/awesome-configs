local setmetatable = setmetatable
local table        = table
local button       = require( "awful.button"    )
local beautiful    = require( "beautiful"       )
local widget2      = require( "awful.widget"    )
local config       = require( "config"          )
local util         = require( "awful.util"      )
local tools        = require( "utils.tools"     )
local wibox        = require( "awful.wibox"     )
local tooltip      = require( "widgets.tooltip" )
local capi = { image  = image  ,
               screen = screen ,
               widget = widget }

module("widgets.dock")
local lauchBar,visible_tt = nil,il

local function hide_tooltip(tt)
    if tt then
        tt:showToolTip(false)
        visible_tt = nil
    end
end

local function create(screen, args)
    local height,separator = capi.screen[1].geometry.height -100,capi.widget({type="imagebox"})
    local vertical_extents,widgets,img = 0,{},capi.image.argb32(40, 7, nil)
    lauchBar = wibox({ position = "free", screen = s, width = 49 })
    lauchBar:geometry({ width = 40, height = height, x = 0, y = 50})
    lauchBar.ontop = true
    lauchBar.border_color = beautiful.fg_normal

    function displayInfo(anApps, name,tooltip1)
        anApps:add_signal("mouse::enter", function ()
            local tt,ext = tooltip1()
            tt:showToolTip(true,{x=40,y=lauchBar.y + ext-30})
            visible_tt = tt
        end)

        anApps:add_signal("mouse::leave", function ()
            local tt,ext = tooltip1()
            hide_tooltip(tt)
            hide_tooltip(visible_tt)
        end)
    end

    img:draw_rectangle(0 ,0, 40, 11 , true, beautiful.bg_normal)
    img:draw_rectangle(3 ,4, 33, 1  , true, beautiful.fg_normal)
    separator.image = img

    local function add_item(name,command,icon_path,category,description)
        local icon = capi.widget({ type = "imagebox", align = "left" })
        icon.image = tools.scale_image(icon_path,40,40,5)
        vertical_extents = vertical_extents + icon:extents().height
        local self_extents,tt = vertical_extents,nil
        local function getTooltip()
            if not tt then
                tt = tooltip(name,{left=true})
            end
            return tt,self_extents
        end
        displayInfo(icon,name,getTooltip)
        icon:buttons(util.table.join(
            button({ }, 1, function()
                util.spawn(command)
                lauchBar.visible = false
                hide_tooltip(visible_tt)
            end),
            button({ }, 3, function()
                lauchBar.visible = false
                hide_tooltip(visible_tt)
            end)
        ))
        table.insert(widgets,icon)
    end

    local function add_separator()
        vertical_extents = vertical_extents + 7
        table.insert(widgets,separator)
    end

    local iconPath = config.data().iconPath
    add_item("Calculator","kcalc",iconPath .. "calc.png","Tools",nil)
    add_item("Terminal","urxvt",iconPath .. "term.png","Tools",nil)
    add_separator()
    add_item("Konqueror","konqueror",iconPath .. "konquror.png","FileManager",nil)
    add_item("Konversation","konversation",iconPath .. "konversation.png","FileManager",nil)
    add_item("Transmission","transmission-qt",iconPath .. "transmission.png","FileManager",nil)
    add_separator()
    add_item("LibreOffice Writer","lowriter",iconPath .. "oowriter2.png","Office",nil)
    add_item("LibreOffice Calc","localc",iconPath .. "oocalc2.png","Office",nil)
    add_item("LibreOffice Impress","loimpress",iconPath .. "oopres2.png","Office",nil)
    add_item("LibreOffice Math","lomath",iconPath .. "ooformula2.png","Office",nil)
    add_item("LibreOffice Base","oobase",iconPath .. "oobase2.png","Office",nil)
    add_separator()
    add_item("Inkscape","inkscape",iconPath .. "inkscape.png","Multimedia",nil)
    add_item("Blender","blender",iconPath .. "blender.png","Multimedia",nil)
    add_item("Cinelerra","cinelerra",iconPath .. "cinelerra.png","Multimedia",nil)
    add_item("Gimp","gimp",iconPath .. "gimp.png","Multimedia",nil)
    add_item("Vlc","vlc",iconPath .. "vlc.png","Multimedia",nil)
    add_item("Amarok","amarok",iconPath .. "amarok.png","Multimedia",nil)
    add_item("Kolourpaint","kolourpaint",iconPath .. "kolourpaint.png","Multimedia",nil)
    add_item("Digikam","digikam",iconPath .. "digikam.png","Multimedia",nil)
    add_item("KDenlive","kdenlive",iconPath .. "kdenlive.png","Multimedia",nil)
    add_separator()
    add_item("KVM","virt-manager",iconPath .. "windows.png","Developpement",nil)
    add_item("Codeblocks","codeblocks",iconPath .. "code-blocks.png","Developpement",nil)
    add_item("Kdevelop","kdevelop",iconPath .. "kdevelop.png","Developpement",nil)

    --Resize the dock if necessary
    if vertical_extents < lauchBar.height then
        height = vertical_extents
        lauchBar.height = height
        lauchBar.y = (capi.screen[1].geometry.height - vertical_extents) / 2
    end

    local img,img2 = capi.image.argb32(40, height, nil),capi.image.argb32(40, height, nil)
    --Top corner (outer)
    img:draw_rectangle(25 ,0, 15, 15   , true, "#ffffff")
    img:draw_circle    (25, 15, 15, 15, true, "#000000")

    --Bottom corner (outer)
    img:draw_rectangle(25 ,height-15, 15, 15   , true, "#ffffff")
    img:draw_circle    (25, height-15, 15, 15, true, "#000000")

    --Top corner (border)
    img2:draw_rectangle(24 ,0, 16, 16   , true, "#ffffff")
    img2:draw_circle    (24, 16, 15, 15, true, "#000000")
    img2:draw_rectangle(0 ,0, 40, 1   , true, "#ffffff")

    --Bottom corner (border)
    img2:draw_rectangle(24 ,height-16, 16, 16   , true, "#ffffff")
    img2:draw_circle    (24, height-16, 15, 15, true, "#000000")
    img2:draw_rectangle(0 ,height-1, 40, 1   , true, "#ffffff")
    img2:draw_rectangle(39 ,5, 1, height   , true, "#ffffff")
    lauchBar.shape_clip      = img2
    lauchBar.shape_bounding  = img
    lauchBar.widgets         = widgets
    lauchBar.widgets.layout  = widget2.layout.vertical.topbottom

    lauchBar:add_signal("mouse::leave", function() lauchBar.visible = false; hide_tooltip(visible_tt) end)
    return lauchBar
end

function new()
  sensibleArea = wibox({ position = "free", screen = s, width = 1 })
  sensibleArea.ontop = true
  sensibleArea:geometry({ width = 1, height = capi.screen[1].geometry.height -100, x = 0, y = 50})
  sensibleArea:add_signal("mouse::enter", function() local l = lauchBar or create();l.visible = true end)
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
