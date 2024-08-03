local addonName, globalTable = ...
SGTCore.L = LibStub("AceLocale-3.0"):GetLocale("SGTCore");

-- Set up DataBroker for minimap button
local SGTCoreLDB = LibStub("LibDataBroker-1.1"):NewDataObject("StroeckxGoldmakingToolkit", {
    type = "data source",
    text = "StroeckxGoldmakingToolkit",
    label = "StroeckxGoldmakingToolkit",
    icon = "Interface\\AddOns\\SGT_Core\\SGT_logo",
    OnClick = function()
      if SGTCore.mainFrame and SGTCore.mainFrame:IsShown() then
        SGTCore.mainFrame:Hide()
      else
        SGTCore:HandleChatCommand("")
      end
    end
});

local SGTIcon = LibStub("LibDBIcon-1.0");
SGTCore.mainFrame = nil;

function SGTCore:OnInitialize()
    SGTCore.db = LibStub("AceDB-3.0"):New("SGTCoreDB", {
		profile = 
		{
			minimap = 
			{
				hide = false,
			},
			frame = 
			{
				point = "CENTER",
				relativeFrame = nil,
				relativePoint = "CENTER",
				ofsx = 0,
				ofsy = 0,
				w = 655,
				h = 655,
			},
        }
    });
    SGTIcon:Register("StroeckxGoldmakingToolkit", SGTCoreLDB, SGTCore.db.profile.minimap);
	SGTCore:RegisterChatCommand("sgt", "HandleChatCommand");
	SGTCore:RegisterChatCommand("sgtToggleMinimapIcon", "sgtToggleMinimapIcon");
end

--Variables start
SGTCore.majorVersion = 1;
SGTCore.subVersion = 0;
SGTCore.minorVersion = 9;
SGTCore.fontStringPools = {};
SGTCore.backgroundLinePools = {};
local tabFramesToCreate = {};
local tabFrames = {};
local tabList = nil;
local tabWidth = 150;
local tabHeight = 24;
local contentWidthOffset = 5;
local contentHeightOffset = -25;

--Variables end

function SGTCore:HandleChatCommand(input)
	local f = SGTCore:GetMainFrame(UIParent)
	if(f:IsShown()) then
		f:Hide()
	else
		f:Show()
	end
end

function SGTCore:sgtToggleMinimapIcon()
	SGTCore.db.profile.minimap.hide = not SGTCore.db.profile.minimap.hide;

	if(SGTCore.db.profile.minimap.hide) then
		SGTIcon:Hide("StroeckxGoldmakingToolkit");
	else
		SGTIcon:Show("StroeckxGoldmakingToolkit");
	end
end

function SGTCore:GetMainFrame(parent)
	if not SGTCore.mainFrame then
		--main frame start
		local mainFrameWidth = tonumber(SGTCore.db.profile.frame.w)
		local mainFrameHeight = tonumber(SGTCore.db.profile.frame.h)
		if(mainFrameWidth == nil) then
			mainFrameWidth = 655
		end
		if(mainFrameHeight == nil) then
			mainFrameHeight = 655
		end
		local Backdrop = {
			bgFile = "Interface\\AddOns\\SGT_Core\\Assets\\Plain.tga",
			tile = false, tileSize = 0, edgeSize = 1,
			insets = {left = 1, right = 1, top = 1, bottom = 1},
		}
		local frameConfig = SGTCore.db.profile.frame
		local f = CreateFrame("Frame","SGTMainFrame",parent, BackdropTemplateMixin and "BackdropTemplate")
		SGTCore.mainFrame = f
		f:SetBackdrop(Backdrop)
		f:SetBackdropColor(0.03,0.03,0.03,0.9)
		f:SetSize(mainFrameWidth, mainFrameHeight )
		f:SetFrameStrata("HIGH")
		f:SetToplevel(true)
		f:SetClampedToScreen(true)
		f:SetPoint(
			frameConfig.point,
			frameConfig.relativeFrame,
			frameConfig.relativePoint,
			frameConfig.ofsx,
			frameConfig.ofsy
		)
		tinsert(UISpecialFrames, f:GetName())
		SGTCore:SetFrameMovable(f)
		--main frame end

		--tab frame start
		tabList = CreateFrame("Frame","SGTTabList",f)
		tabList:SetPoint("TOPLEFT", SGTCore.mainFrame, "TOPLEFT",0,-5)
		tabList:SetPoint("BOTTOMRIGHT", SGTCore.mainFrame, "BOTTOMLEFT",tabWidth,0)

		contentFrame = CreateFrame("Frame","SGTContentFrame",f, BackdropTemplateMixin and "BackdropTemplate")
		contentFrame:SetPoint("TOPLEFT", SGTCore.mainFrame, "TOPLEFT",tabWidth,0)
		contentFrame:SetPoint("BOTTOMRIGHT", SGTCore.mainFrame, "BOTTOMRIGHT")
		--tab frame end

		--divider lines start
		local line = tabList:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPRIGHT",0,4)
		line:SetEndPoint("BOTTOMRIGHT",0,1)

		line= contentFrame:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPLEFT",0,-20)
		line:SetEndPoint("TOPRIGHT",-2,-20)
		--divider lines end

		--version text
		local versionText = f:CreateFontString(nil,"ARTWORK", "GameFontHighlight"); 
		versionText:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 5, 5);
		versionText:SetText(SGTCore:GetVersionString());

		--Resizing start
		f:SetResizable(true)
		f:SetResizeBounds(400, 350)
		local rb = CreateFrame("Button", "SGTResizeButton", f)
		rb:SetPoint("BOTTOMRIGHT", -6, 7)
		rb:SetSize(16, 16)
		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

		rb:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				f:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- more noticeable
			end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
			f:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			contentFrame:SetSize(f:GetWidth() - tabWidth, f:GetHeight())
			-- save size between sessions
			frameConfig.w = f:GetWidth()
			frameConfig.h = f:GetHeight()
		end)
		--Resizing end
		
		--Close Button start
		local closeButton = CreateFrame("Button", "SGTMainFrameCloseButton", f)
		closeButton:SetSize(20,20)
		closeButton:SetText("X")
		closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT")
		closeButton:SetNormalFontObject("GameFontHighlight")
		closeButton:SetHighlightFontObject("GameFontHighlight")
		closeButton:SetDisabledFontObject("GameFontDisable")
		closeButton:SetScript("OnClick", function()
			SGTCore.mainFrame:Hide()
		end)
		SGTCore.mainFrame:SetScript("OnUpdate", function()
			SGTCore:OnNewFrame();
		end)
		SGTCore.mainFrame:Hide();
		--Close Button end

		--add core frame
		SGTCore:AddTabWithFrame("SGTCore", SGTCore.L["Core"], SGTCore.L["Core"], SGTCore:GetVersionString(), SGTCore.OnCoreFrameCreated);

		--create frames
		local idx = 1;
		for key, tabInfo in pairs(tabFramesToCreate) do
			local frame = SGTCore:CreateCoreFrameTab(tabInfo["name"], contentFrame, BackdropTemplateMixin and "BackdropTemplate");
			frame.title:SetText(tabInfo["title"] .. " - " .. tabInfo["version"]);
			SGTCore:AddTab(tabList, tabWidth, tabHeight, idx, frame, tabInfo["tabName"]);
			idx = idx + 1;
			tabFrames[tabInfo["name"]] = frame;
			tabInfo["onFrameCreated"]();
		end
	end
	return SGTCore.mainFrame
end

function SGTCore:PrepareTablePools(frame, pool)
	if(SGTCore.fontStringPools[pool] == nil) then
		SGTCore.fontStringPools[pool] = CreateFontStringPool(frame, "OVERLAY", nil, "GameFontNormal", FontStringPool_Hide)
	else
		SGTCore.fontStringPools[pool]:ReleaseAll()
	end
	if(SGTCore.backgroundLinePools[pool] == nil) then
		SGTCore.backgroundLinePools[pool] = CreateFramePool("Frame", nil, BackdropTemplateMixin and "BackdropTemplate")
	else
		SGTCore.backgroundLinePools[pool]:ReleaseAll()
	end
end

function SGTCore:OnCoreFrameCreated()
	local coreFrame = SGTCore:GetTabFrame("SGTCore");
	local coreDescription = SGTCore:AddAnchoredFontString("SGTCoreDescriptionsText", coreFrame.scrollframe.scrollchild, coreFrame, 5, -5, SGTCore.L["SGTCoreDescription"], coreFrame);
end

function SGTCore:AddTabWithFrame(name, title, tabName, version, onFrameCreated)
	table.insert(tabFramesToCreate, {["name"] = name, ["title"] = title, ["tabName"] = tabName, ["version"] = version, ["onFrameCreated"] = onFrameCreated});
end

function SGTCore:GetTabFrame(name)
	return tabFrames[name];
end

function SGTCore:SetFrameMovable(f)
	local frameConfig = SGTCore.db.profile.frame
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
		self:StartMoving()
		end
	end)
	f:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing()
	-- save position between sessions
	point, relativeFrame, relativeTo, ofsx, ofsy = self:GetPoint()
	frameConfig.point = point
	frameConfig.relativeFrame = relativeFrame
	frameConfig.relativePoint = relativeTo
	frameConfig.ofsx = ofsx
	frameConfig.ofsy = ofsy
	end)
end

function SGTCore:OnNewFrame()
	--placeholder
end

function SGTCore:CreateCoreFrameTab(name, parent, backdrop)
	local f = CreateFrame("Frame", name .. "Frame",parent, BackdropTemplateMixin and "BackdropTemplate")
	f:SetPoint("TOPLEFT", parent, "TOPLEFT", contentWidthOffset, contentHeightOffset)
	f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -contentWidthOffset, -contentHeightOffset)
	f.title = f:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	f.title:SetPoint("BottomLeft",f, "TOPLEFT", 0, 8)

	f.scrollframe = f.scrollframe or CreateFrame("ScrollFrame", name .. "ScrollFrame", f, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
	f.scrollframe:SetPoint("LEFT")
	f.scrollframe:SetPoint("RIGHT", -22, 0)
	f.scrollframe:SetPoint("TOP")
	f.scrollframe:SetPoint("BOTTOM")

	frameScrollChild = f.scrollframe.scrollchild or CreateFrame("Frame", name .. "ScrollChild", f.scrollframe);
	frameScrollChild:SetSize(f.scrollframe:GetSize())
	f.scrollframe:SetScrollChild(frameScrollChild)
	f.scrollframe.scrollchild = frameScrollChild;

	return f;
end

function SGTCore:AddTab(parent, width, height, index, content, text)
	local b = CreateFrame("Button", "Tab" .. index, parent)
	b:SetSize(width,24)
	b:SetText(text)
	b:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * height)
	b.HighlightTexture = b:CreateTexture()
	b.HighlightTexture:SetColorTexture(1,1,1,.3)
	b.HighlightTexture:SetPoint("TOPLEFT")
	b.HighlightTexture:SetPoint("BOTTOMRIGHT")
	b:SetHighlightTexture(b.HighlightTexture)
	b.PushedTexture = b:CreateTexture()
	b.PushedTexture:SetColorTexture(.9,.8,.1,.3)
	b.PushedTexture:SetPoint("TOPLEFT")
	b.PushedTexture:SetPoint("BOTTOMRIGHT")
	b:SetPushedTexture(b.PushedTexture)
	b:SetNormalFontObject("GameFontHighlight")
	b:SetHighlightFontObject("GameFontHighlight")
	b:SetDisabledFontObject("GameFontDisable")
	b:SetScript("OnClick", function(self)
		SGTCore:TabOnClick(self)
	end)
	b.content = content
	b.content:Hide()
	return b
end

function SGTCore:TabOnClick(self)
	if(activeTab ~= nil) then
		activeTab.content:Hide()
	end
	activeTab = self
	self.content:Show()
end

function SGTCore:AddAnchoredFontString(name, parent, parent2, horizontalOffset, verticalOffset, textValue, topAnchor, font)
	if(font == nil) then
		font = "GameFontHighlight";
	end
	local text = parent:CreateFontString(name,"ARTWORK", font);
	text:SetPoint("TOPLEFT", topAnchor, "TOPLEFT", horizontalOffset, verticalOffset)
	text:SetPoint("RIGHT", parent2, "RIGHT", -horizontalOffset)
	text:SetText(textValue);
	text:SetJustifyH("LEFT");
	return text;
end

function SGTCore:GetVersionString()
    return tostring(SGTCore.majorVersion) .. "." .. tostring(SGTCore.subVersion) .. "." .. tostring(SGTCore.minorVersion);
end

function SGTCore:DoVersionCheck(major, sub, minor, addon)
    if(addon.majorVersion == nil or addon.majorVersion < major) then
        return false;
    end
	if(addon.majorVersion > major) then
		return true;
	end
    if(addon.subVersion == nil or addon.subVersion < sub) then
        return false;
    end
	if(addon.subVersion > sub) then
		return true;
	end
    if(addon.minorVersion == nil or addon.minorVersion < minor) then
        return false;
    end
    return true;
end

function SGTCore:DebugPrintTable(table1, table2, table3, table4)
    print("-------------------------------------------")
    if(table1 ~= nil) then
        print("table1:");
        for k, v in pairs(table1) do
            print(tostring(k) .. " : " .. tostring(v));
        end
    end
    if(table2 ~= nil) then
        print("table2:");
        for k, v in pairs(table1) do
            print(tostring(k) .. " : " .. tostring(v));
        end
    end
    if(table3 ~= nil) then
        print("table3:");
        for k, v in pairs(table1) do
            print(tostring(k) .. " : " .. tostring(v));
        end
    end
    if(table4 ~= nil) then
        print("table4:");
        for k, v in pairs(table1) do
            print(tostring(k) .. " : " .. tostring(v));
        end
    end
end

function SGTCore:GetTextColor(color)
	if 		color == "yellow" 	then return 1, 0.9, 0, 1
	elseif  color == "white" 	then return 1, 1, 1, 1
	elseif  color == "legendary" 	then return 1, 0.5, 0, 1
	end
end