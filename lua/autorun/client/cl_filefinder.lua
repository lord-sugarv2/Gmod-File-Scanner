local col1, col2 = Color(30, 30, 30), Color(40, 40, 40)
local function OpenChecker()
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 500)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("File Checker")
    frame.Paint = function(s, w, h)
        surface.SetDrawColor(col1)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(col2)
        surface.DrawRect(0, 0, w, 25)
    end

    local panel = frame:Add("Panel")
    panel:Dock(TOP)
    panel:SetTall(25)

    panel.findword = panel:Add("DButton")
    panel.findword:Dock(RIGHT)
    panel.findword:SetWide(100)
    panel.findword:SetText("CHECK FILE")
    panel.findword.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(62, 171, 62) or Color(0, 255, 0))
        surface.DrawRect(0, 0, w, 25)
    end
    panel.findword.DoClick = function()
        net.Start("LFileChecker:Request")
        net.WriteString(panel.textbox:GetValue())
        net.SendToServer()
    end

    panel.textbox = panel:Add("DTextEntry")
    panel.textbox:Dock(FILL)
    panel.textbox:DockMargin(0, 0, 5, 0)

    local scroll = frame:Add("DScrollPanel")
    scroll:Dock(FILL)

    net.Receive("FileChecker:ReceiveFiles", function()
        if not IsValid(frame) then return end
        local int = net.ReadUInt(32)
        local data = net.ReadData(int)
        local word = net.ReadString()
        data = util.Decompress(data)
        data = util.JSONToTable(data)
        table.insert(data, 1, "Results for word '"..word.."' "..#data.." results!")
        scroll:Clear()
        for k, v in ipairs(data) do
            local panel = scroll:Add("DLabel")
            panel:Dock(TOP)
            panel:SetText(v)
            panel:SizeToContents()
        end
    end)
end

concommand.Add("filechecker", function()
    OpenChecker()
end)