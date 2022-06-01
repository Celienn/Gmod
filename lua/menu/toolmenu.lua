
function X(cox)
    return (cox/1920)*ScrW()
end

function Y(coy)
    return (coy/1080*ScrH())
end

function Size(size)
    return size*((ScrW()+ScrH())/3000)
end

Config = {
    x = X(1200),
    y = Y(800),
    size = Size(1),
    key = KEY_B
}

Menu = 1

function addFrame(x,y)
    
end

local html = nil


function OpenGui()

    --MAIN FRAME
    local GuiFrame = vgui.Create("DFrame")
    GuiFrame:SetSize(Config["x"],Config["y"])
    GuiFrame:SetTitle("")
    GuiFrame:Center()
    GuiFrame:MakePopup()
    GuiFrame:ShowCloseButton(false)
    GuiFrame:ParentToHUD()
    --BACKGROUND
    local w,h = GuiFrame:GetSize()
    background = vgui.Create("DHTML", GuiFrame)
    background:SetPos(0,20)
    background:SetSize(w,h-Y(60))
    background:OpenURL("asset://garrysmod/html/background.html") 
    --PAGES
    local pages = {count = 0}
    local alt = {}
    local function AddPage(label,icon,func)  
        local page = vgui.Create( "DFrame", background )
        page:SetTitle(label)
        pages["count"] = pages["count"] + 1
        pages[pages["count"]] = {frame = page, icon = icon,show = true,pos = 0} 
        alt[page] = pages["count"]
        func(page)
        local w,h = GuiFrame:GetSize()
        local Frame = vgui.Create("DFrame",GuiFrame)
        Frame:SetTitle("")
        Frame:ShowCloseButton(false)
        Frame:SetPos(X(40)*(pages["count"]-1),h-Y(40))
        Frame:SetSize( X(50), Y(40) )	
        Frame:SetDraggable(false)	
        Frame.Paint = function(self,w,h)
            draw.RoundedBox( 0, 0, 0, w, h, Color( 8, 0, 83) ) 
            draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 200, 200, 200) ) 
        end
        -- CLOSE BUTTON
        local w,h = page:GetSize()
        local DermaImageButton = vgui.Create( "DImageButton", page )
        DermaImageButton:SetPos( w-X(20), 0 )			
        DermaImageButton:SetSize( X(20), Y(20) )			
        DermaImageButton:SetImage( "icon16/cross2.png" )	
        DermaImageButton.DoClick = function()
            pages[pages["count"]]["show"] = false
            pages[pages["count"]]["frame"]:Hide()
            Frame.Paint = function(self,w,h)
                draw.RoundedBox( 0, 0, 0, w, h, Color( 8, 0, 83) ) 
                draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 77, 77, 77) ) 
            end
        end
        local DermaImageButton = vgui.Create( "DImageButton", Frame )	
        DermaImageButton:SetSize( X(40), Y(40) )
        DermaImageButton:SetPos(X(5),0)
        DermaImageButton:SetImage( icon )	
        DermaImageButton.DoClick = function()
            if pages[pages["count"]]["show"] then
                pages[pages["count"]]["show"] = false
                pages[pages["count"]]["frame"]:Hide()
                Frame.Paint = function(self,w,h)
                    draw.RoundedBox( 0, 0, 0, w, h, Color( 8, 0, 83) ) 
                    draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 77, 77, 77) ) 
                end
            else
                pages[pages["count"]]["show"] = true
                pages[pages["count"]]["frame"]:Show()
                Frame.Paint = function(self,w,h)
                    draw.RoundedBox( 0, 0, 0, w, h, Color( 8, 0, 83) ) 
                    draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 200, 200, 200) ) 
                end
            end
        end
        page.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, X((string.len(page:GetTitle())*10)+2), Y(22), Color( 75, 75, 75, 10) ) 
            draw.RoundedBox( 2, 0, Y(22), w, h, Color( 75, 75, 75, 10 ) ) 
        end 
    end
    local function addButton(label,frame,on,off)
        local Index = nil
        table.foreach(pages,function(index,value)
            if index != "count" then
                if value["frame"]:GetTitle() == frame:GetTitle() then
                    Index = index
                end
            end
        end)
        local pos = pages[Index]["pos"]
        local DColorButton = vgui.Create( "DColorButton", frame )
        DColorButton:SetPos(X(15) ,Y(40) + pos)
        DColorButton:SetSize( Size(10), Size(10) )
        DColorButton:Paint( 100, 30 )
        DColorButton:SetColor( Color( 0, 147, 173) )
        local DLabel = vgui.Create( "DLabel", pages[Index]["frame"] )
        DLabel:SetPos( X(35),Y(35) + pos )
        DLabel:SetText( label )
        DLabel:SetFont("custom-font")
        function DColorButton:DoClick() -- Callback inherited from DLabel, which is DColorButton's base
            print( "I am clicked! My color is ", self:GetColor() )
            if self:GetColor() == Color(0, 147, 173) then
                DColorButton:SetColor( Color( 90, 90, 90) )
                off()
            else
                DColorButton:SetColor( Color( 0, 147, 173) )
                on()
            end
        end

    end
    AddPage("ESP","icon16/eye2.png",function(frame) 
        frame:SetSize(X(300),Y(400))
        frame:Center()
        frame:ShowCloseButton(false)
        addButton("WallHack",frame,function()
            hook.Add( "HUDPaint", "wallhack", function()
                cam.Start3D()
                    for id, ply in ipairs( player.GetAll() ) do
                        ply:DrawModel()
                    end
                cam.End3D()
            end)
        end,
        function()
            hook.Add( "HUDPaint", "wallhack", function() end )
        end)
    end)
    function GuiFrame:Paint(w, h)    
        draw.RoundedBox(3, 0, Y(22) , w, h, Color(50,50,50))   
    end
    return GuiFrame
end


surface.CreateFont( "custom-font", {
	font = "Cambria", 
	extended = false,
	size = 17,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

concommand.Add( "toolmenu", function( ply, cmd, args, str )
    if ( Menu == 0 ) then
        GuiFrame:Show()
        Menu = 1
    else
        GuiFrame:Hide()
        Menu = 0
    end
end )

hook.Add("Think", "toolmenu", function() 
    if  input.IsKeyDown(Config["key"]) and Config["KEY"] != 1 and !(LocalPlayer():IsTyping())  then
        RunConsoleCommand("toolmenu")
        Config["KEY"] = 1
    elseif !input.IsKeyDown(Config["key"]) then
        Config["KEY"] = 0
    end
end)

GuiFrame = OpenGui()
