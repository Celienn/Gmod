
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

function tableLenght(tab)
    local count = 0
    for _ in pairs(tab) do
        count = count + 1
    end
    return count
end

local html = nil

local FShow = {}
local spawnPos = {x=25,y=25}

local Data = 
{
    Wallhack = 
    {
        Color = Color(0,183,255),
        HSV = false,
        Speed = 50,
        Player = true,
        Props = false,
        Entity = false,
        Material = 
        {
            
        }
    },
    Tracer = 
    {
        StartPos = "Middle",
        Color = Color(255,0,0),
        HSV = false,
        Speed = 50,
        Player = true,
        Props = false,
        Entity = false
    }
}

CreateMaterial( "wallhack", "VertexLitGeneric", {
    ["$basetexture"] = "color/white",
    ["$model"] = 1,
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1,
    ["$ignorez"] = 1
  } )


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
    //background:OpenURL("asset://garrysmod/html/background.html") 
    
    --PAGES
    local pages = {count = 0,buttonPos=0}
    local alt = {}
    local function AddPage(label,icon,func)  
        local page = vgui.Create( "DFrame", background )
        page:SetTitle(label)
        pages["count"] = pages["count"] + 1
        pages[pages["count"]] = {frame = page, icon = icon,show = false,pos = 0,Descendants={}} 
        alt[page] = pages["count"]
        func(page)
        local w,h = GuiFrame:GetSize()
        local Frame = vgui.Create("DFrame",GuiFrame)
        Frame:SetTitle("")
        Frame:ShowCloseButton(false)
        Frame:SetPos(pages["buttonPos"]-1,h-Y(40))
        Frame:SetSize( X(50), Y(40) )	
        Frame:SetDraggable(false)	
        Frame.Paint = function(self,w,h)
            draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 17, 44) ) 
            draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 120, 120, 120) ) 
        end
        pages["buttonPos"] = pages["buttonPos"] + 50
        page:Hide()
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
                draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 200, 200, 200) ) 
            end
        end
        local DermaImageButton = vgui.Create( "DImageButton", Frame )	
        DermaImageButton:SetSize( X(40), Y(40) )
        DermaImageButton:SetPos(X(5),0)
        DermaImageButton:SetImage( icon )	
        DermaImageButton.DoClick = function()
            local Index = nil
            table.foreach(pages,function(index,value)
                if index != "count" and index != "buttonPos" then
                    if value["frame"]:GetTitle() == page:GetTitle() then
                        Index = index
                    end
                end
            end)
            if pages[Index]["show"] then
                pages[Index]["show"] = false
                pages[Index]["frame"]:Hide()
                table.foreach(pages[Index]["Descendants"],function(index,var)
                    table.foreach(pages,function(Index,Var)
                        if Index != "count" and Index != "buttonPos" then
                            if var:GetTitle() == Var["frame"]:GetTitle() then
                                if pages[Index]["show"] then
                                    var:Hide()
                                end
                            end
                        end
                    end)
                end)
                Frame.Paint = function(self,w,h)
                    draw.RoundedBox( 0, 0, 0, w, h, Color( 8, 0, 83) ) 
                    draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 120, 120, 120) ) 
                end
            else
                pages[Index]["show"] = true
                pages[Index]["frame"]:Show()
                table.foreach(pages[Index]["Descendants"],function(index,var)
                    table.foreach(pages,function(Index,Var)
                        if Index != "count" and Index != "buttonPos" then
                            if var:GetTitle() == Var["frame"]:GetTitle() then
                                if pages[Index]["show"] then
                                    var:Show()
                                end
                            end
                        end
                    end)
                end)
                local frame = pages[Index]["frame"]
                if !FShow[frame:GetTitle()] then
                    FShow[frame:GetTitle()] = true
                    frame:SetPos(spawnPos["x"],spawnPos["y"])
                    local x , y = frame:GetSize()
                    spawnPos["x"] = spawnPos["x"] + x + 25
                    if (spawnPos["f"] == nil) then spawnPos["f"] = y end
                    if (spawnPos["f"] < y ) then
                        spawnPos["f"] = y
                    end
                    local w,h = GuiFrame:GetSize()
                    if (spawnPos["x"] > w) then
                        spawnPos["x"] = 0
                        spawnPos["y"] = spawnPos["f"] + 25
                    end
                end
                Frame.Paint = function(self,w,h)
                    draw.RoundedBox( 0, 0, 0, w, h, Color( 8, 0, 83) ) 
                    draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 200, 200, 200) ) 
                end
            end
        end
        local placeolder = vgui.Create("DLabel",setting)
        placeolder:SetText(page:GetTitle())
        placeolder:SizeToContents()
        local x , y = placeolder:GetSize()
        placeolder:Remove()
        page.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, X(x+15), Y(22), Color( 75, 75, 75, 10) ) 
            draw.RoundedBox( 2, 0, Y(22), w, h, Color( 75, 75, 75, 10 ) ) 
        end 
    end

    -- ADDOPTION
    local option = {}
    local function addOption(label,icon,frame,func)
        if option[frame] == nil then 
            option[frame] = {}
        end
        table.insert(option[frame],
        {
            label = label,
            icon = icon,
            func = func
        })
        function frame:DoRightClick()
            local menu = DermaMenu()
            table.foreach(option[self],function(index,value)
                local label = value["label"]
                local icon = value["icon"]
                local func = value["func"]
                local box = menu:AddOption(label)
                box:SetIcon(icon)
                function box:DoClick(self)
                   func(self)
                end
            end)
            local x,y = background:CursorPos()
            menu:SetPos(x,y)
            menu:AddSpacer()
            menu:SetParent(background)
            hook.Add("hideDarmaMenu","Hide",function()
                menu:Remove()
            end) 
        end
    end

    -- ADDBUTTON
    local function addButton(label,frame,initValue,on,off,param)
        local Index = nil
        table.foreach(pages,function(index,value)
            if index != "count" and index != "buttonPos" then
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
        DColorButton:SetColor( Color( 90, 90, 90) )
        local DLabel = vgui.Create( "DLabel", pages[Index]["frame"] )
        DLabel:SetPos( X(35),Y(35) + pos )
        DLabel:SetText( label )
        DLabel:SetFont("custom-font")
        DLabel:SetMouseInputEnabled( true )
        function DLabel:DoClick() 
            if DColorButton:GetColor() == Color(0, 147, 173) then
                DColorButton:SetColor( Color( 90, 90, 90) )
                off()
            else
                DColorButton:SetColor( Color( 0, 147, 173) )
                on()
            end
        end
        pages[Index]["pos"] = pages[Index]["pos"] + 20
        function DColorButton:DoClick() 
            if self:GetColor() == Color(0, 147, 173) then
                DColorButton:SetColor( Color( 90, 90, 90) )
                off()
            else
                DColorButton:SetColor( Color( 0, 147, 173) )
                on()
            end
        end
        if initValue then
            DColorButton:SetColor( Color( 0, 147, 173) )
            on()
        else
            DColorButton:SetColor( Color( 90, 90, 90) )
            off()
        end
        if param != nil then
            local setting = vgui.Create("DFrame", background)
            pages["count"] = pages["count"] + 1
            pages[pages["count"]] = {frame = setting,pos = 0,Descendants={}} 
            table.insert(pages[Index]["Descendants"],setting)
            setting:SetTitle(DLabel:GetText() .. "\'s settings")
            local placeolder = vgui.Create("DLabel",setting)
            placeolder:SetText(setting:GetTitle())
            placeolder:SizeToContents()
            local x , y = placeolder:GetSize()
            placeolder:Remove()
            setting.Paint = function( self, w, h )
                draw.RoundedBox( 0, 0, 0, X(x+15), Y(22), Color( 75, 75, 75, 10) ) 
                draw.RoundedBox( 2, 0, Y(22), w, h, Color( 75, 75, 75, 10 ) ) 
            end
            local x,y = frame:GetPos()
            setting:SetPos(x,y)
            setting:Hide()
            param(setting)
            local w,h = setting:GetSize()
            local DermaImageButton = vgui.Create( "DImageButton", setting )
            DermaImageButton:SetPos( w-X(20), 0 )			
            DermaImageButton:SetSize( Size(20), Size(20) )			
            DermaImageButton:SetImage( "icon16/cross2.png" )	
            DermaImageButton.DoClick = function()
                setting:Hide()
                table.foreach(pages,function(index,var)
                    if index != "count" and index != "buttonPos" then
                        if var["frame"]:GetTitle() == setting:GetTitle() then
                            pages[index]["show"] = false
                        end
                    end
                end)
            end
            addOption("Setting","icon16/cog.png",DLabel,function()
                local x,y = frame:GetPos()
                local w,h = frame:GetSize()
                setting:SetPos(x+w+10,y)
                setting:Show()
                table.foreach(pages,function(index,var)
                    if index != "count" and index != "buttonPos" then
                        if var["frame"]:GetTitle() == setting:GetTitle() then
                            pages[index]["show"] = true
                        end
                    end
                end)
            end)
            addOption("Bind","icon16/add.png",DLabel,function()
                
            end)
        end
    end

    --ADDCOMBOBOX
    local function addComboBox(label,frame,initValue,list)
        local Index = nil
        table.foreach(pages,function(index,value)
            if index != "count" and index != "buttonPos" then
                if value["frame"]:GetTitle() == frame:GetTitle() then
                    Index = index
                end
            end
        end)
        local pos = pages[Index]["pos"]
        local w,h = frame:GetSize()
        local DComboBox = vgui.Create("DComboBox", frame)
        DComboBox:SetPos(X(35) ,Y(55) + pos)    
        DComboBox:SetSize( Size(w*0.6), Size(20) )
        DComboBox:Paint( 100, 30 )
        if initValue != nil then DComboBox:SetValue(initValue) end
        table.foreach(list,function(index,var)
            if var != nil then
                DComboBox:AddChoice(var["name"])
            end
        end)
        DComboBox.OnSelect = function( self, index, value )
            table.foreach(list,function(Index,var)
                if value == var["name"] then
                    var["func"](frame)
                end
            end)
        end
        local DLabel = vgui.Create( "DLabel", pages[Index]["frame"] )
        DLabel:SetPos( X(35),Y(35) + pos )
        DLabel:SetText( label )
        DLabel:SetFont("custom-font")
        pages[Index]["pos"] = pages[Index]["pos"] + 40
    end

    --ADDCOLORMIXER
    local function addColorMixer(label,frame,initValue,func)
        local Index = nil
        table.foreach(pages,function(index,value)
            if index != "count" and index != "buttonPos" then
                if value["frame"]:GetTitle() == frame:GetTitle() then
                    Index = index
                end
            end
        end)
        local pos = pages[Index]["pos"]
        local w,h = frame:GetSize()
        local DColorMixer = vgui.Create("DColorMixer", frame)
        DColorMixer:SetPos(X(35) ,Y(55) + pos)    
        DColorMixer:SetSize( Size(w*0.75), Size(150) )
        DColorMixer:SetPalette( false )
        DColorMixer:SetAlphaBar( true ) 
        DColorMixer:SetWangs( true )
        func(DColorMixer)
        if initValue != nil then DColorMixer:SetColor(initValue) end
        local DLabel = vgui.Create( "DLabel", pages[Index]["frame"] )
        DLabel:SetPos( X(35),Y(35) + pos )
        DLabel:SetText( label )
        DLabel:SetFont("custom-font")
        pages[Index]["pos"] = pages[Index]["pos"] + 175
    end

    --ADDLABEL
    local function addLabel(label,frame)
        local Index = nil
        table.foreach(pages,function(index,value)
            if index != "count" and index != "buttonPos" then
                if value["frame"]:GetTitle() == frame:GetTitle() then
                    Index = index
                end
            end
        end)
        local pos = pages[Index]["pos"]
        local w,h = frame:GetSize()
        local DLabel = vgui.Create( "DLabel", pages[Index]["frame"] )
        DLabel:SetText( label )
        DLabel:SetFont("custom-font")
        local x,y = DLabel:GetSize()
        DLabel:SetPos( X(w*0.5-x/2),Y(35) + pos )
        pages[Index]["pos"] = pages[Index]["pos"] + 20
    end

    --ADDSLIDER
    local function addSlider(label,frame,min,max,init,func)
        local Index = nil
        table.foreach(pages,function(index,value)
            if index != "count" and index != "buttonPos" then
                if value["frame"]:GetTitle() == frame:GetTitle() then
                    Index = index
                end
            end
        end)
        local pos = pages[Index]["pos"]
        local DLabel = vgui.Create( "DLabel", pages[Index]["frame"] )
        DLabel:SetPos( X(35),Y(35) + pos )
        DLabel:SetText( label )
        DLabel:SetFont("custom-font")
        local DermaNumSlider = vgui.Create( "DNumSlider", frame )
        DermaNumSlider:SetPos( X(-70), Y(55) + pos)			
        DermaNumSlider:SetSize( Size(300), 15 )
        DermaNumSlider:SetMin( min )			
        DermaNumSlider:SetMax( max )	
        DermaNumSlider:SetValue( init )	
        DermaNumSlider:SetDark( true )	
        DermaNumSlider:SetDecimals( 0 )		
        DermaNumSlider:GetTextArea():Hide()
        local x,y = DermaNumSlider:GetSize()
        function DermaNumSlider.Slider.Knob:Paint(w,h)
            draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 174, 255) ) 
        end	
        local ratio = ((DermaNumSlider:GetValue()-DermaNumSlider:GetMin()) / (DermaNumSlider:GetMax()-DermaNumSlider:GetMin()))
        local scale = (ratio * x) / 1.87654321
        function DermaNumSlider.Slider.Knob:Paint(w,h)
            draw.RoundedBox( 0, -(scale), h/2-y/2+y*0.25/1.5,(scale+w*ratio), y*0.75 , Color( 0, 174, 255) ) 
        end 
        function DermaNumSlider.Slider:Paint(w,h)
            surface.SetDrawColor( 60, 60, 60 )
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor( 73, 73, 73 )
            surface.DrawOutlinedRect(0,0,w,h,2)
        end
        DermaNumSlider.OnValueChanged = function( self, value ) 
            local ratio = ((DermaNumSlider:GetValue()-DermaNumSlider:GetMin()) / (DermaNumSlider:GetMax()-DermaNumSlider:GetMin()))
            local scale = (ratio * x) / 1.87654321
            function DermaNumSlider.Slider.Knob:Paint(w,h)
                draw.RoundedBox( 0, -(scale), h/2-y/2+y*0.25/1.5,(scale+w*ratio), y*0.75 , Color( 0, 174, 255) ) 
            end 
            func(value)
        end
        pages[Index]["pos"] = pages[Index]["pos"] + 40
    end

    -- CREATION DES PAGES
    AddPage("ESP","icon16/eye2.png",function(frame) 
        frame:SetSize(X(300),Y(400))
        frame:Center()
        frame:ShowCloseButton(false)
        addButton("WallHack",frame,false,
        function()
            local mat = Material("!wallhack")
            local sub = Material("pp/colour")
            table.foreach(Data["Wallhack"]["Material"],function(index,var)
                if string.sub(index,1,1) == "$" then
                    if type(var) == "string" then
                        sub:SetString(index,var)
                        print(index)
                        print(var)
                    else 
                        sub:SetFloat(index,var)
                    end
                end
            end)
            PrintTable(sub:GetKeyValues())
            sub:Recompute()
            hook.Add( "HUDPaint", "wallhack", function()
                for id, ply in ipairs( player.GetAll() ) do
                    cam.Start3D()
                    local color = Data["Wallhack"]["Color"]:GetColor()
                    render.SetColorModulation(color["r"]/255,color["g"]/255,color["b"]/255)
                    render.SuppressEngineLighting(true)
                    render.MaterialOverride(mat)
                    --ply:DrawModel()
                    render.MaterialOverride(sub)
                    ply:DrawModel()
                    render.SuppressEngineLighting(false)
                    cam.End3D()
                end
            end)
        end,
        function()
            hook.Add( "HUDPaint", "wallhack", function() end )
            for id, ply in ipairs( player.GetAll() ) do
                ply:SetColor(Color(255,255,255))
                ply:SetMaterial("")
            end
        end,
        function(frame)
            frame:SetSize(X(300),Y(425))
            frame:ShowCloseButton(false)
            addLabel("Visual",frame)
            addColorMixer("SetColor :",frame,Data["Wallhack"]["Color"],
            function(value)
                Data["Wallhack"]["Color"] = value
            end)
            addButton("HSV",frame,Data["Wallhack"]["HSV"],
            function()
                Data["Wallhack"]["HSV"] = true
            end,
            function()
                Data["Wallhack"]["HSV"] = false
            end)
            addSlider("Speed :",frame,10,100,50,
            function(var)
                Data["Wallhack"]["Speed"] = var
            end)
            addLabel("Target",frame)
            addButton("Player",frame,true,
            function()
                Data["Wallhack"]["Player"] = true
            end,
            function()
                Data["Wallhack"]["Player"] = false
            end)
            addButton("Props",frame,false,
            function()
                Data["Wallhack"]["Props"] = true
            end,
            function()
                Data["Wallhack"]["Props"] = false
            end)
            addButton("Entity",frame,false,
            function()
                Data["Wallhack"]["Entity"] = true
            end,
            function()
                Data["Wallhack"]["Entity"] = false
            end)
        end)
        addButton("Tracer",frame,false,
        function()
            hook.Add( "HUDPaint", "tracer", 
            function()
                local center = nil
                if Data["Tracer"]["StartPos"] == "Up" then
                    center = Vector(ScrW() / 2, 0,0)
                elseif Data["Tracer"]["StartPos"] == "Middle" then
                    center = Vector(ScrW() / 2, ScrH() / 2,0)
                elseif Data["Tracer"]["StartPos"] == "Down" then
                    center = Vector(ScrW() / 2, ScrH(),0)
                end
                if (Data["Tracer"]["Player"]) then
                    for id, ply in ipairs( player.GetAll() ) do
                        if ply:GetName() == LocalPlayer():GetName() then continue end
                        local pos = ply:GetAttachment(ply:LookupAttachment("anim_attachment_head")).Pos   
                        local x = ply:GetPos():ToScreen().x
                        local y = ply:GetPos():ToScreen().y
                        cam.Start2D()
                        surface.SetDrawColor( Data["Tracer"]["Color"]:GetColor() )
                        surface.DrawLine(center.x,center.y,pos:ToScreen().x,pos:ToScreen().y)
                        cam.End2D()
                    end
                end
                if (Data["Tracer"]["Props"]) then
                    table.foreach(ents.GetAll(),function(index,entity)
                        if entity:GetClass() == "prop_physics" then 
                            local pos = nil
                            if IsValid(entity:GetPhysicsObject()) then
                                pos = entity:GetPhysicsObject():GetMassCenter()
                            else
                                pos = entity:GetPos()
                            end
                            local x = pos:ToScreen().x
                            local y = pos:ToScreen().y
                            cam.Start2D()
                            surface.SetDrawColor( Data["Tracer"]["Color"]:GetColor() )
                            surface.DrawLine(center.x,center.y,pos:ToScreen().x,pos:ToScreen().y)
                            cam.End2D()
                        end
                    end)
                end
                if (Data["Tracer"]["Entity"]) then
                    table.foreach(ents.GetAll(),function(index,entity)
                        if entity:GetClass() != "prop_physics" and type(entity) == "Entity" then 
                            local pos = nil
                            if IsValid(entity:GetPhysicsObject()) then
                                pos = entity:GetPhysicsObject():GetMassCenter()
                            else
                                pos = entity:GetPos()
                            end
                            local x = pos:ToScreen().x
                            local y = pos:ToScreen().y
                            cam.Start2D()
                            surface.SetDrawColor( Data["Tracer"]["Color"]:GetColor() )
                            surface.DrawLine(center.x,center.y,pos:ToScreen().x,pos:ToScreen().y)
                            cam.End2D()
                        end
                    end)
                end
            end)
        end,
        function()
            hook.Add( "HUDPaint", "tracer", function() end)
        end,
        function(frame)
            frame:SetSize(X(300),Y(425))
            frame:ShowCloseButton(false)
            addLabel("Visual",frame)
            addComboBox("StartPos",frame,Data["Tracer"]["StartPos"],
            {
                {
                    name = "Up",
                    func = function(frame)
                        Data["Tracer"]["StartPos"] = "Up"
                    end
                },{
                    name = "Middle",
                    func = function(frame)
                        Data["Tracer"]["StartPos"] = "Middle"
                    end
                },{
                    name = "Down",
                    func = function(frame)
                        Data["Tracer"]["StartPos"] = "Down"
                    end
                }
            })
            addColorMixer("SetColor :",frame,Data["Tracer"]["Color"],
            function(value)
                Data["Tracer"]["Color"] = value
            end)
            addButton("HSV",frame,Data["Tracer"]["HSV"],
            function()
                Data["Tracer"]["HSV"] = true
            end,
            function()
                Data["Tracer"]["HSV"] = false
            end)
            addSlider("Speed :",frame,10,100,50,
            function(var)
                Data["Tracer"]["Speed"] = var
            end)
            addLabel("Target",frame)
            addButton("Player",frame,true,
            function()
                Data["Tracer"]["Player"] = true
            end,
            function()
                Data["Tracer"]["Player"] = false
            end)
            addButton("Props",frame,false,
            function()
                Data["Tracer"]["Props"] = true
            end,
            function()
                Data["Tracer"]["Props"] = false
            end)
            addButton("Entity",frame,false,
            function()
                Data["Tracer"]["Entity"] = true
            end,
            function()
                Data["Tracer"]["Entity"] = false
            end)
        end)
    end)
    AddPage("Aimbot","icon16/target2.png",function(frame) 
        frame:SetSize(X(300),Y(400))
        frame:ShowCloseButton(false)
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

local GuiFrame = OpenGui()

concommand.Add( "toolmenu", function( ply, cmd, args, str )
    if ( Menu == 0 ) then
        GuiFrame:Show()
        Menu = 1
    else
        GuiFrame:Hide()
        hook.Call("hideDarmaMenu")
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
    if Data["Tracer"]["HSV"] then
        local color = HSVToColor( Data["Tracer"]["Speed"] * CurTime() % 360, 1, 1 )
        Data["Tracer"]["Color"]:SetColor(color)
    end
    if Data["Wallhack"]["HSV"] then
        local color = HSVToColor( Data["Wallhack"]["Speed"] * CurTime() % 360, 1, 1 )
        Data["Wallhack"]["Color"]:SetColor(color)
    end
end)
