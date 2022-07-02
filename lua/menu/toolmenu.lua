
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
    key = KEY_B,
    ThemeColor = Color(0,162,255)
}

Menu = false

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

local Drag = 
{
    MousePos = nil,
    Size = 1
}


local Data = 
{
    Wallhack = 
    {
        Color = Color(0,183,255),
        HSV = false,
        Speed = 50,
        Player = true,
        Props = true,
        Entity = false,
        Material = 
        {
            
        },
        LightStyle = 1,
        LightPattern = "m",
        Key = KEY_NONE
    },
    Tracer = 
    {
        StartPos = "Middle",
        Color = Color(255,0,0),
        HSV = false,
        Speed = 50,
        Player = true,
        Props = false,
        Entity = false,
        Key = KEY_NONE
    },
    Freecam = 
    {
        Keys = {
            Close = KEY_R,
            Tp = KEY_F,
            Forward = input.GetKeyCode(input.LookupBinding( "forward" )),
            Back = input.GetKeyCode(input.LookupBinding( "back" )),
            Left = input.GetKeyCode(input.LookupBinding( "moveleft" )),
            Right = input.GetKeyCode(input.LookupBinding( "moveright" )),
            Speed = input.GetKeyCode(input.LookupBinding( "speed" )),
            Jump = input.GetKeyCode(input.LookupBinding( "jump" )),
            Duck = input.GetKeyCode(input.LookupBinding( "duck" )),
        },
        Angles = Angle(0,0,0),
        Pos = Vector(0,0,0),
        Speed = 25,
        SprintSpeed = 50,
        DuckSpeed = 10,
        InUse = false
    },
    Crash = 
    {
        Target = NULL,
    },
    ESP = 
    {
        Name = true,
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

surface.CreateFont( "page-font", {
	font = "Arial", 
	extended = false,
	size = 30,
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

function setFontSize(size)
    surface.CreateFont( "custom-font", {
        font = "Cambria", 
        extended = false,
        size = Size(17)*size,
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
end

function resizeFrame(frame,size)
    local function changeSize(Frame,Size,DFrame)
        local x,y = Frame:GetPos()
        local sx,sy = Frame:GetSize()
        if Drag[Frame] == nil then
            Drag[Frame] = {
                LastSize = 
                {
                    x = sx,
                    y = sy
                },
                Size = 
                {
                    x = sx,
                    y = sy
                },
                Pos = 
                {
                    x = x,
                    y = y
                }
            }
        end

        local lsx = Drag[Frame]["LastSize"]["x"]
        local lsy = Drag[Frame]["LastSize"]["y"]
        local sx = Drag[Frame]["Size"]["x"]
        local sy = Drag[Frame]["Size"]["y"]
        if DFrame then
            local x,y = Frame:GetPos()
            local x = (x*(lsx/sx))
            local y = (y*(lsy/sy))
            print(x,x*(lsx/sx),y,y*(lsy/sy))
            --Frame:SetPos(x*(lsx/sx),y*(lsy/sy))
        else
            local x = Drag[Frame]["Pos"]["x"]
            local y = Drag[Frame]["Pos"]["y"]
            Frame:SetPos(x*Size,y*Size)
        end
        setFontSize(Size)
        if Frame:GetName() != "nosize" then 
            Frame:SetSize(sx*Size,sy*Size)
        end
        local x,y = Frame:GetSize()
        Drag[Frame]["LastSize"]["x"] = x
        Drag[Frame]["LastSize"]["y"] = y
    end
    changeSize(frame,size,true)
    for _, child in ipairs( frame:GetChildren() ) do
        changeSize(child,size)
    end
end

function lookAt(pos)
    local eye = EyePos()
    local sub = eye - pos
    sub:Normalize()
    sub = sub:Angle()
    local ang = Angle(-sub.p,sub.y+180,sub.r)
    LocalPlayer():SetEyeAngles(ang)
end

function haveWeapon(class)
    local weapons = LocalPlayer():GetWeapons()
    for _,weapon in pairs(weapons) do
        if weapon:GetClass() == class then
            return weapon
        end
    end
    return false
end

function equipWeapon(class)
    local weapon = haveWeapon(class)
    if weapon then
        input.SelectWeapon(weapon)
        return weapon
    end
    return false
end

if AdvDupe2 != nil then
    function spawnDupe(name)
        local weapon = equipWeapon("gmod_tool")
        if !weapon then
            GAMEMODE:AddNotify("AdvDupe2 Exploit : LocalPlayer doesn't have a toolgun",NOTIFY_ERROR,3)
            return false
        else
            AdvDupe2.UploadFile(name,0)
            if weapon:GetMode() != "advdupe2" then
                GAMEMODE:AddNotify("AdvDupe2 Exploit : pls select advdupe2 tool",NOTIFY_ERROR,3)
                return false
            else
                timer.Create("AdvDupe2", 0.25, 0, function()
                    RunConsoleCommand("advdupe2_original_origin","1")
                    RunConsoleCommand("+attack")
                    timer.Create("AdvDupe2", 0, 0, function()
                        RunConsoleCommand("-attack")
                        timer.Remove("AdvDupe2")
                    end)
                end)
                return true
            end
        end
    end
    function spawnProp(model,pos,angle,frozen)
        local function generateDupe(model,pos,angle,frozen)
            local tab =
            {
                Constraints =
                {

                },
                Entities = 
                {
                    [0] = 
                    {
                        Class = "prop_physics",
                        CollisionGroup = 0,
                        Model = model,
                        PhysicsObjects = 
                        {
                            [0] = 
                            {
                                Angle = angle,
                                Frozen = frozen,
                                Pos = Vector(0,0,0)
                            }
                        }
                    }
                },
                HeadEnt = 
                {
                    ["Index"] = 0,
                    ["Pos"] = pos,
                    ["Z"] = 16.892868041992,
                }
            }
            return tab
        end
        local read = file.Read("advdupe2/test.txt")
        local success, dupe, info, moreinfo = AdvDupe2.Decode(read)
        local dupe = generateDupe(model,pos,angle,frozen)
        AdvDupe2.Encode(dupe,info,function(data)
            local file = file.Open("advdupe2/exploit.txt","wb","DATA")
            file:Write(data)
            file:Close()
        end)
        spawnDupe("exploit")
    end
end

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
    background:SetMouseInputEnabled(true)
    background:OpenURL("asset://garrysmod/html/background.html") 
    
    --ADDPAGES
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
        page:Hide()
        -- CLOSE BUTTON
        local w,h = page:GetSize()
        local DermaImageButton = vgui.Create( "DImageButton", page )
        DermaImageButton:SetPos( w-X(20), 0 )			
        DermaImageButton:SetSize( X(20), Y(20) )			
        DermaImageButton:SetImage( "icon16/cross2.png" )	
        DermaImageButton:SetName("nosize")
        DermaImageButton.DoClick = function()
            pages[pages["count"]]["show"] = false
            pages[pages["count"]]["frame"]:Hide()
            Frame.Paint = function(self,w,h)
                draw.RoundedBox( 0, 0, 0, w, h, Color( 8, 0, 83) ) 
                draw.RoundedBox( 0, X(2), Y(2), w-X(4), h-Y(4), Color( 200, 200, 200) ) 
            end
        end
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetText(label)
        DLabel:SetFont("page-font")
        DLabel:SizeToContents()
        local x,y = Frame:GetSize()
        local x = DLabel:GetSize()
        Frame:SetSize(x+X(20),y)
        DLabel:Center()
        DLabel:SetMouseInputEnabled(true)
        DLabel:SetTextColor(Color(0,0,0))
        DLabel.DoClick = function()
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
                if !FShow[frame] then
                    FShow[frame] = true
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
        pages["buttonPos"] = pages["buttonPos"] + Frame:GetSize()
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
        DLabel:SetTextColor(Color(255,255,255))
        local x , y = DLabel:GetSize()
        local x = frame:GetSize()
        DLabel:SetSize(x,y)
        function DLabel:DoClick() 
            if DColorButton:GetColor() == Config["ThemeColor"] then
                DColorButton:SetColor( Color( 90, 90, 90) )
                off(DColorButton)
            else
                DColorButton:SetColor( Config["ThemeColor"] )
                on(DColorButton)
            end
        end
        pages[Index]["pos"] = pages[Index]["pos"] + 20
        function DColorButton:DoClick() 
            if self:GetColor() == Config["ThemeColor"] then
                DColorButton:SetColor( Color( 90, 90, 90) )
                off()
            else
                DColorButton:SetColor( Config["ThemeColor"] )
                on()
            end
        end
        if initValue then
            DColorButton:SetColor( Config["ThemeColor"] )
            on(DColorButton)
        else
            DColorButton:SetColor( Color( 90, 90, 90) )
            off(DColorButton)
        end
        if param != nil then
            local setting = vgui.Create("DFrame", background)
            pages["count"] = pages["count"] + 1
            pages[pages["count"]] = {frame = setting,pos = 0,Descendants={},Key="None"} 
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
            FShow[setting] = false
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
                FShow[setting] = true
                setting:Show()
                table.foreach(pages,function(index,var)
                    if index != "count" and index != "buttonPos" then
                        if var["frame"]:GetTitle() == setting:GetTitle() then
                            pages[index]["show"] = true
                        end
                    end
                end)
            end)
        end
        if !Data[label] then Data[label] = {} end
        if !Data[label]["Key"] then Data[label]["Key"] = KEY_NONE end
        local DFrame = vgui.Create("DFrame")
        DFrame:SetTitle("")
        DFrame:SetSize(X(300),Y(150))
        DFrame:Center()
        DFrame:MakePopup()
        DFrame:SetBackgroundBlur( true )
        DFrame:ParentToHUD()
        DFrame:ShowCloseButton( false )
        local DBinder = vgui.Create("DBinder",DFrame)
        local x , y = DFrame:GetSize()
        DBinder:SetSize(x*0.75,y*0.75-Y(25))
        DBinder:Center()
        local x , y = DBinder:GetPos()
        DBinder:SetPos(x,y+Y(25/2))
        function DBinder:OnChange(key)
            Data[label]["Key"] = key
            if ( key ) then
                hook.Add( "PlayerButtonDown", label, function( ply, button )
                    if key == button then 
                        DFrame:Hide()
                        if DColorButton:GetColor() == Config["ThemeColor"] then
                            DColorButton:SetColor( Color( 90, 90, 90) )
                            off()
                        else
                            DColorButton:SetColor( Config["ThemeColor"] )
                            on()
                        end
                    end
                end)
            end
            RunConsoleCommand("toolmenu")
            DFrame:Hide()
        end
        DFrame:Hide()
        addOption("Bind","icon16/add.png",DLabel,function()
            if Data[label]["Key"] != nil then
                local text = input.GetKeyName(Data[label]["Key"])
                if text == nil then
                    DBinder:SetText("NONE")
                else
                    DBinder:SetText(text)
                end
            end
            RunConsoleCommand("toolmenu")
            DFrame:Show()
        end)
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
        if label != nil then
            local DLabel = vgui.Create( "DLabel", pages[Index]["frame"] )
            DLabel:SetPos( X(35),Y(35) + pos )
            DLabel:SetText( label )
            DLabel:SetFont("custom-font")
            pages[Index]["pos"] = pages[Index]["pos"] + 20
        end
        local pos = pages[Index]["pos"]
        local w,h = frame:GetSize()
        local DComboBox = vgui.Create("DComboBox", frame)
        DComboBox:SetPos(X(35) ,Y(35) + pos)    
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
        pages[Index]["pos"] = pages[Index]["pos"] + 20
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
        DLabel:SetTextColor(Color(255,255,255))
        DLabel:SizeToContents()
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
            draw.RoundedBox( 0, 0, 0, w, h, Config["ThemeColor"] ) 
        end	
        local ratio = ((DermaNumSlider:GetValue()-DermaNumSlider:GetMin()) / (DermaNumSlider:GetMax()-DermaNumSlider:GetMin()))
        local scale = (ratio * x) / 1.87654321
        function DermaNumSlider.Slider.Knob:Paint(w,h)
            draw.RoundedBox( 0, -(scale), h/2-y/2+y*0.25/1.5,(scale+w*ratio), y*0.75 , Config["ThemeColor"] ) 
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
                draw.RoundedBox( 0, -(scale), h/2-y/2+y*0.25/1.5,(scale+w*ratio), y*0.75 , Config["ThemeColor"] ) 
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
        addButton("Wallhack",frame,false,
        function()
            local mat = Material("!wallhack")
            local sub = Material("pp/colour")
            table.foreach(Data["Wallhack"]["Material"],function(index,var)
                if string.sub(index,1,1) == "$" then
                    if type(var) == "string" then
                        sub:SetString(index,var)
                    else 
                        sub:SetFloat(index,var)
                    end
                end 
            end)
            sub:Recompute()
            hook.Add( "PreDrawHUD", "wallhack", function()
                cam.Start3D()
                local color = Data["Wallhack"]["Color"]:GetColor()
                render.SetColorModulation(color["r"]/255,color["g"]/255,color["b"]/255)
                render.SetLightingMode(math.Round(Data["Wallhack"]["LightStyle"]))
                render.EnableClipping(true)
                render.SetBlend(Data["Wallhack"]["Color"]:GetColor()["a"]/255)
                if Data["Wallhack"]["Player"] then
                    for id, ply in ipairs( player.GetAll() ) do
                        render.MaterialOverride(mat)
                        ply:DrawModel()
                        render.MaterialOverride(sub)
                        ply:DrawModel()
                    end
                end
                if Data["Wallhack"]["Props"] then
                    table.foreach(ents.GetAll(),function(index,entity)
                        if entity:GetClass() == "prop_physics" then 
                            render.MaterialOverride(mat)
                            entity:DrawModel()
                            render.MaterialOverride(sub)
                            entity:DrawModel()
                            
                        end
                    end)
                end
                if Data["Wallhack"]["Entity"] then
                    table.foreach(ents.GetAll(),function(index,entity)
                        if entity:GetClass() != "prop_physics" and type(entity) == "Entity" then 
                            render.MaterialOverride(mat)
                            entity:DrawModel()
                            render.MaterialOverride(sub)
                            entity:DrawModel()
                        end
                    end)
                end
                render.SetLightingMode(0)
                cam.End3D()
            end)
        end,
        function()
            hook.Add( "PreDrawHUD", "wallhack", function() end )
        end,
        function(frame)
            frame:SetSize(X(300),Y(445))
            frame:ShowCloseButton(false)

            addLabel("Visual",frame)

            addColorMixer("SetColor :",frame,Data["Wallhack"]["Color"],
            function(value)     Data["Wallhack"]["Color"] = value end)

            addButton("HSV",frame,Data["Wallhack"]["HSV"],
            function()    Data["Wallhack"]["HSV"] = true end,
            function()    Data["Wallhack"]["HSV"] = false end)
            
            addSlider("Speed :",frame,10,100,Data["Wallhack"]["Speed"],function(var) Data["Wallhack"]["Speed"] = var end)
            
            addLabel("Light",frame)
            
            addSlider("Style :",frame,0,2,1,function(var) Data["Wallhack"]["LightStyle"] = var end)

            addLabel("Target",frame)
            
            addButton("Player",frame,Data["Wallhack"]["Player"],
            function()    Data["Wallhack"]["Player"] = true end,
            function()    Data["Wallhack"]["Player"] = false end)
            
            addButton("Props",frame,Data["Wallhack"]["Props"],
            function()    Data["Wallhack"]["Props"] = true end,
            function()    Data["Wallhack"]["Props"] = false end)
            
            addButton("Entity",frame,Data["Wallhack"]["Entity"],
            function()    Data["Wallhack"]["Entity"] = true end,
            function()    Data["Wallhack"]["Entity"] = false end)
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
                cam.Start2D()
                if (Data["Tracer"]["Player"]) then
                    for id, ply in ipairs( player.GetAll() ) do
                        if ply:GetName() == LocalPlayer():GetName() then continue end
                        local pos = ply:GetAttachment(ply:LookupAttachment("anim_attachment_head")).Pos   
                        local x = ply:GetPos():ToScreen().x
                        local y = ply:GetPos():ToScreen().y
                        surface.SetDrawColor( Data["Tracer"]["Color"]:GetColor() )
                        surface.DrawLine(center.x,center.y,pos:ToScreen().x,pos:ToScreen().y)
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
                            surface.SetDrawColor( Data["Tracer"]["Color"]:GetColor() )
                            surface.DrawLine(center.x,center.y,pos:ToScreen().x,pos:ToScreen().y)
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
                            surface.SetDrawColor( Data["Tracer"]["Color"]:GetColor() )
                            surface.DrawLine(center.x,center.y,pos:ToScreen().x,pos:ToScreen().y)
                        end
                    end)
                end
                cam.End2D()
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
        local function off()
            Data["Freecam"]["InUse"] = false
            hook.Remove("Think","freecam_input")
            hook.Remove("CreateMove","Freecam")
            LocalPlayer():DrawViewModel(true)
            hook.Remove("ShouldDrawLocalPlayer","freecam")
        end
        addButton("Freecam",frame,false,
        function(button)
            Data["Freecam"]["InUse"] = true
            local frame = vgui.Create( "DFrame" )
            frame:SetSize( ScrW(), ScrH() )
            frame:Center()
            frame:MakePopup()
            frame:SetTitle("")
            frame:ShowCloseButton(false)
            frame:SetDraggable(false)
            local paint = {}
            local count = 0
            local function addKeyDisplay(label,keylabel)
                local x , y = frame:GetSize()
                local DLabel = vgui.Create("DLabel",frame)
                DLabel:SetFont("freecam-font")
                DLabel:SetText(label)
                DLabel:SizeToContents()
                local sx , sy = DLabel:GetSize()
                DLabel:SetPos(X(100),y-sy-Y(100)-(Y(60)*count))
                DLabel:SetTextColor(Color(255,255,255))
                table.insert(paint,function(w,h)
                    local x , y = DLabel:GetPos()
                    local sx , sy = DLabel:GetSize()
                    local x = x-Size(50)-X(20)
                    local y = y-(sy/2)
                    local size = Size(50)
                    surface.SetDrawColor(Color(255,255,255))
                    surface.DrawOutlinedRect(x,y,size,size,2)
                    surface.SetTextColor(Color(255,255,255))
                    surface.SetTextPos(x+size/6,y)
                    surface.SetFont("freecam-maj-font")
                    surface.DrawText(keylabel)
                end)
                count = count + 1
            end
            addKeyDisplay("Close & Create tp","F")
            addKeyDisplay("Close","R")
            Data["Freecam"]["Pos"] = LocalPlayer():EyePos()
            Data["Freecam"]["Angles"] = LocalPlayer():EyeAngles()
            input.SetCursorPos(ScrW()/2,ScrH()/2)
            hook.Add("ShouldDrawLocalPlayer","freecam",function()
                return true
            end)
            hook.Add("CreateMove", "Freecam", function()
                if frame:IsHovered() then
                    frame:SetCursor("blank")
                    local x , y = frame:LocalCursorPos()
                    local sx , sy = frame:GetSize()
                    Data["Freecam"]["Angles"].y = Data["Freecam"]["Angles"].y - (x - sx/2) /2
                    Data["Freecam"]["Angles"].x = Data["Freecam"]["Angles"].x + (y - sy/2) /2
                    if Data["Freecam"]["Angles"].x > 90 then
                        Data["Freecam"]["Angles"].x = 90
                    end
                    if Data["Freecam"]["Angles"].x < -90 then
                        Data["Freecam"]["Angles"].x = -90
                    end
                    input.SetCursorPos(ScrW()/2,ScrH()/2)
                    function frame:Paint( w, h )
        
                        local x, y = self:GetPos()
                
                        local old = DisableClipping( true ) 
                        render.RenderView( {
                            origin = Data["Freecam"]["Pos"],
                            angles = Data["Freecam"]["Angles"],
                            x = x, y = y,
                            w = w, h = h,
                            drawhud = true
                        } )
                        DisableClipping( old )
                        for _,func in pairs(paint) do
                            func(w,h)
                        end
                    end
                    LocalPlayer():DrawViewModel(false)
                end
            end)
            hook.Add("Think", "freecam_input", function() 
                local speed = Data["Freecam"]["Speed"]
                for index, key in pairs(Data["Freecam"]["Keys"]) do
                    if input.IsKeyDown( Data["Freecam"]["Keys"]["Speed"] ) then
                        speed = Data["Freecam"]["SprintSpeed"]
                    elseif input.IsKeyDown( Data["Freecam"]["Keys"]["Duck"] ) then
                        speed = Data["Freecam"]["DuckSpeed"]
                    end
                    local angles = Data["Freecam"]["Angles"]
                    if input.IsKeyDown( key ) then 
                        local function close()
                            frame:Remove()  
                            off()
                            button:SetColor(Color(90,90,90))
                            GuiFrame:Hide()
                            hook.Call("hideDarmaMenu")
                            Menu = true
                        end
                        if index == "Close" then
                            close()
                        elseif index == "Tp" then 
                            close()
                            function generateDupe(startpos,endpos)
                                local tab = 
                                {
                                    ["Constraints"] = {
                                        [1] = {
                                            ["BuildDupeInfo"] = {
                                                ["Ent1Ang"] = Angle(9.0949919464593e-24, 8.8891499672172e-07, -2.1011048829678e-06),
                                                ["Ent1Pos"] = startpos,
                                                ["Ent2Ang"] = Angle(-1.0045795846656e-13, 90.000007629395, 360),
                                                ["EntityPos"] = Vector(0,0,0),
                                            },
                                            ["Entity"] = {
                                                [1] = {
                                                    ["Bone"] = 0,
                                                    ["Index"] = 118,
                                                    ["LPos"] = Vector(0,0,0),
                                                },
                                                [4] = {
                                                    ["Bone"] = 0,
                                                    ["Index"] = 119,
                                                    ["LPos"] = Vector(0,0,0),
                                                },
                                            },
                                            ["LPos1"] = endpos,
                                            ["LPos4"] = endpos,
                                            ["Type"] = "Pulley",
                                            ["WPos2"] = Vector(0,0,0),
                                            ["WPos3"] = Vector(0,0,0),
                                            ["color"] = {
                                                ["a"] = 255,
                                                ["b"] = 255,
                                                ["g"] = 255,
                                                ["r"] = 255,
                                            },
                                            ["forcelimit"] = 0,
                                            ["material"] = "cable/cable2",
                                            ["rigid"] = false,
                                            ["width"] = 3,
                                        },
                                    },
                                    ["Entities"] = {
                                        [118] = {
                                            ["Class"] = "prop_physics",
                                            ["Model"] = "models/hunter/plates/plate025x025.mdl",
                                            ["PhysicsObjects"] = {
                                                [0] = {
                                                    ["Angle"] = Angle(9.0949919464593e-24, 8.8891499672172e-07, -2.1011048829678e-06),
                                                    ["Pos"] = endpos-startpos,
                                                },
                                            },
                                            ["CollisionGroup"] =  10
                                        },
                                        [119] = {
                                            ["Class"] = "prop_physics",
                                            ["Model"] = "models/hunter/plates/plate025x025.mdl",
                                            ["PhysicsObjects"] = {
                                                [0] = {
                                                    ["Angle"] = Angle(-1.0045795846656e-13, 90.000007629395, 360),
                                                    ["Pos"] = Vector(0,0,0),
                                                },
                                            },
                                            ["CollisionGroup"] =  10
                                        },
                                        [120] = {
                                            ["Class"] = "prop_physics",
                                            ["Model"] = "models/hunter/plates/plate025x025.mdl",
                                            ["BuildDupeInfo"] = {
                                                ["DupeParentID"] = 119.0
                                            },
                                            ["PhysicsObjects"] = {
                                                [0] = {
                                                    ["Angle"] = Angle(-1.0045795846656e-13, 90.000007629395, 360),
                                                    ["Pos"] = Vector(0,0,0),
                                                },
                                            },
                                            ["CollisionGroup"] =  0
                                        }
                                    },
                                    ["HeadEnt"] = {
                                        ["Index"] = 119,
                                        ["Pos"] = startpos+Vector(0,0,10),
                                        ["Z"] = 43.394760131836,
                                    },
                                }         
                                return tab
                            end  
                            local tab = generateDupe(LocalPlayer():GetPos(),Data["Freecam"]["Pos"])
                            AdvDupe2.Encode(tab,{},function(data)
                                local File = file.Open("advdupe2/tp.txt","wb","DATA")
                                File:Write(data)
                                File:Close()
                            end)
                            local spawned = spawnDupe("tp")
                            if spawned then
                                timer.Create("Tp", 0.3, 1, function()
                                    equipWeapon("weapon_physgun")
                                    timer.Create("Tp",0.3,2,function()
                                        timer.Create("Tp",0.2,2,function()
                                            --RunConsoleCommand("+reload")
                                            timer.Create("Tp1",0.05,1,function()
                                                --RunConsoleCommand("-reload")
                                            end)
                                        end)
                                    end)
                                end)
                                timer.Create("Look", 0.9, 1, function()
                                    lookAt(LocalPlayer():GetPos())
                                end)
                            end
                        elseif index == "Forward" then
                            Data["Freecam"]["Pos"] = Data["Freecam"]["Pos"] + angles:Forward() * speed
                        elseif index == "Back" then
                            Data["Freecam"]["Pos"] = Data["Freecam"]["Pos"] - angles:Forward() * speed
                        elseif index == "Left" then
                            Data["Freecam"]["Pos"] = Data["Freecam"]["Pos"] - angles:Right() * speed
                        elseif index == "Right" then
                            Data["Freecam"]["Pos"] = Data["Freecam"]["Pos"] + angles:Right() * speed
                        elseif index == "Jump" then
                            Data["Freecam"]["Pos"] = Data["Freecam"]["Pos"] + Vector(0,0,1) * speed
                        end
                    end
                end
            end)
        end,
        off,
        function(frame)
            frame:SetSize(X(300),Y(425))
            frame:ShowCloseButton(false)
            
        end)
        addButton("ESP",frame,false,
        function()
            hook.Add("PreDrawHUD","ESP",function()
                cam.Start2D()
                for id, ply in ipairs( player.GetAll() ) do
                    local data2D = ply:GetPos():ToScreen()
                    if ( not data2D.visible ) then continue end
                    if Data["ESP"]["Name"] then
                        draw.SimpleText( ply:GetName(), "Default", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                end
                cam.End2D()
            end)
        end,
        function()
            hook.Remove("PreDrawHUD","ESP")
        end,
        function(frame)
            frame:SetSize(X(100),Y(50))
            frame:ShowCloseButton(false)
            addButton("Name",frame,Data["ESP"]["Name"],
            function()
                Data["ESP"]["Name"] = true
            end,
            function()
                Data["ESP"]["Name"] = false
            end)
        end)
    end)
    AddPage("Misc","icon16/target2.png",function(frame) 
        frame:SetSize(X(300),Y(400))
        frame:ShowCloseButton(false)
        addButton( "BHop",frame,false,
        function()
            function Bunnyhop()
                if  input.IsKeyDown(KEY_SPACE) then
                    print( LocalPlayer():IsOnGround())
                    if LocalPlayer():IsOnGround() then
                        RunConsoleCommand("+jump")
                        timer.Create("Bhop", 0.1, 0, function()
                            RunConsoleCommand("-jump")
                        end)
                    end
                end
            end
            
            hook.Add("Think", "Bunnyhop", Bunnyhop )
        end,
        function()
            hook.Remove("Think","Bunnyhop")
        end)
    end)
    AddPage("Exploits","icon16/target2.png",function(frame) 
        frame:SetSize(X(300),Y(400))
        frame:ShowCloseButton(false)
        addLabel("AdvDupe2",frame)
        addButton( "Tp",frame,false,
        function() 
            function generateDupe(startpos,endpos)
                local tab = 
                {
                    ["Constraints"] = {
                        [1] = {
                            ["BuildDupeInfo"] = {
                                ["Ent1Ang"] = Angle(9.0949919464593e-24, 8.8891499672172e-07, -2.1011048829678e-06),
                                ["Ent1Pos"] = startpos,
                                ["Ent2Ang"] = Angle(-1.0045795846656e-13, 90.000007629395, 360),
                                ["EntityPos"] = Vector(0,0,0),
                            },
                            ["Entity"] = {
                                [1] = {
                                    ["Bone"] = 0,
                                    ["Index"] = 118,
                                    ["LPos"] = Vector(0,0,0),
                                },
                                [4] = {
                                    ["Bone"] = 0,
                                    ["Index"] = 119,
                                    ["LPos"] = Vector(0,0,0),
                                },
                            },
                            ["LPos1"] = endpos,
                            ["LPos4"] = endpos,
                            ["Type"] = "Pulley",
                            ["WPos2"] = Vector(0,0,0),
                            ["WPos3"] = Vector(0,0,0),
                            ["color"] = {
                                ["a"] = 255,
                                ["b"] = 255,
                                ["g"] = 255,
                                ["r"] = 255,
                            },
                            ["forcelimit"] = 0,
                            ["material"] = "cable/cable2",
                            ["rigid"] = false,
                            ["width"] = 0,
                        },
                    },
                    ["Entities"] = {
                        [118] = {
                            ["Class"] = "prop_physics",
                            ["Model"] = "models/hunter/plates/plate025x025.mdl",
                            ["PhysicsObjects"] = {
                                [0] = {
                                    ["Angle"] = Angle(9.0949919464593e-24, 8.8891499672172e-07, -2.1011048829678e-06),
                                    ["Pos"] = endpos-startpos,
                                },
                            },
                            ["CollisionGroup"] =  10
                        },
                        [119] = {
                            ["Class"] = "prop_physics",
                            ["Model"] = "models/hunter/plates/plate025x025.mdl",
                            ["PhysicsObjects"] = {
                                [0] = {
                                    ["Angle"] = Angle(-1.0045795846656e-13, 90.000007629395, 360),
                                    ["Pos"] = Vector(0,0,0),
                                },
                            },
                            ["CollisionGroup"] =  10
                        },
                        [120] = {
                            ["Class"] = "prop_physics",
                            ["Model"] = "models/hunter/plates/plate025x025.mdl",
                            ["BuildDupeInfo"] = {
                                ["DupeParentID"] = 119.0
                            },
                            ["PhysicsObjects"] = {
                                [0] = {
                                    ["Angle"] = Angle(-1.0045795846656e-13, 90.000007629395, 360),
                                    ["Pos"] = Vector(0,0,0),
                                },
                            },
                            ["CollisionGroup"] =  0
                        }
                    },
                    ["HeadEnt"] = {
                        ["Index"] = 119,
                        ["Pos"] = startpos+Vector(0,0,10),
                        ["Z"] = 43.394760131836,
                    },
                }         
                return tab
            end  
            local tab = generateDupe(LocalPlayer():GetPos(),Vector(1350,650,65))
            AdvDupe2.Encode(tab,{},function(data)
                local File = file.Open("advdupe2/tp.txt","wb","DATA")
                File:Write(data)
                File:Close()
            end)
            local spawned = spawnDupe("tp")
            if spawned then
                timer.Create("Tp", 0.3, 0, function()
                    lookAt(LocalPlayer():GetPos())
                    equipWeapon("weapon_physgun")
                    timer.Remove("Tp")
                end)
            end
        end,
        function()
        end)
        addButton("test",frame,false,
        function()
            local data = file.Read("advdupe2/pqrent.json","DATA")
            --local File = file.Open("advdupe2/PQRENT.json","wb","DATA")
            --data = util.TableToJSON(util.JSONToTable(data),true)
            --File:Write(data)
            --File:Close()
            data = util.JSONToTable(data)
            PrintTable(data)
            AdvDupe2.Encode(data,{},function(data)
                local File = file.Open("advdupe2/test.txt","wb","DATA")
                File:Write(data)
                File:Close()
            end)
        end,
        function()
        
        end)
        addLabel("ULX",frame)
        addButton( "Crash Player",frame,false,
        function()
            if Data["Crash"]["Target"] != NULL then
                hook.Add("Think","CrashPlayer",function()
                    for z=0,1 do
                        concommand.Run(LocalPlayer(),"ulx",{
                            "psay",
                            Data["Crash"]["Target"]:GetName(),
                            "test"
                        })
                    end
                end)
            end
        end,
        function()
            hook.Add("Think","CrashPlayer",function()end)
        end)
        local tab = {}
        table.foreach(player.GetAll(),function(index,var)
            if var != LocalPlayer() then
                table.insert(tab,index,
                {
                    name = var:GetName(),
                    func = function()
                        Data["Crash"]["Target"] = var
                    end
                })
            end
        end)
        addComboBox(nil,frame,"Choose a player",tab)
    end)
    function GuiFrame:Paint(w, h)    
        draw.RoundedBox(3, 0, Y(22) , w, h, Color(50,50,50))   
    end
    return GuiFrame
end

surface.CreateFont( "custom-font", {
	font = "Cambria", 
	extended = false,
	size = Size(17),
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

surface.CreateFont( "freecam-font", {
	font = "Cambria", 
	extended = false,
	size = Size(25),
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

surface.CreateFont( "freecam-maj-font", {
	font = "Arial", 
	extended = false,
	size = Size(50),
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
    if ( Menu ) then
        GuiFrame:Show()
        Menu = false
    else
        GuiFrame:Hide()
        hook.Call("hideDarmaMenu")
        Menu = true
    end
end )

local toggleDrag = true

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
    if input.IsMouseDown(MOUSE_LEFT) then
        if background:IsHovered() and toggleDrag then
            table.foreach(FShow,function(index,var)
                if var and Drag["MousePos"] != nil then
                    local frame = index
                    local oldx = Drag["MousePos"]["x"]
                    local oldy = Drag["MousePos"]["y"]
                    local x,y = background:LocalCursorPos()
                    local dif = 
                    {
                        x = x-oldx,
                        y = y-oldy
                    }
                    frame:SetPos(frame:GetX()+dif["x"],frame:GetY()+dif["y"])
                end
            end)
            local x,y = background:LocalCursorPos()
            Drag["MousePos"] = 
            {
                x = x,
                y = y
            }
        elseif !background:IsHovered() then
            toggleDrag = false
        end
    else
        toggleDrag = true
        if Drag["MousePos"] then
            Drag["MousePos"] = nil     
        end
    end
end)

hook.Add("CreateMove", "MouseInput", function()
    if background:IsHovered() then
        if input.WasMousePressed(MOUSE_WHEEL_UP) then
            Drag["Size"] = Drag["Size"] + 0.01
            for _, child in ipairs( background:GetChildren() ) do
                resizeFrame(child,Drag["Size"])
            end
        elseif input.WasMousePressed(MOUSE_WHEEL_DOWN) then
            Drag["Size"] = Drag["Size"] - 0.01
            for _, child in ipairs( background:GetChildren() ) do
                resizeFrame(child,Drag["Size"])
            end
        end
    end
end)

