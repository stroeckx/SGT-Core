local addonName, globalTable = ...

function SGTCore:AddDropdownMenu(name, parent, anchor, heightOffset, width, text, options, valueChangedCallback, currentValueGetter)
	local dropDown = CreateFrame("FRAME", name, parent, BackdropTemplateMixin and "UIDropDownMenuTemplate")
	dropDown:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -20, heightOffset);
	UIDropDownMenu_SetWidth(dropDown, width)
	UIDropDownMenu_SetText(dropDown, text)
	UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
			if (level or 1) == 1 then
				for _, title in ipairs(options) do
				info.text = title;
				info.menuList = title;
				info.arg1 = title;
				info.func = self.SetValue;
				if(title == currentValueGetter()) then
					info.checked = true;
				else
					info.checked = false;
				end
				UIDropDownMenu_AddButton(info)
				end
			end
	end)

	function dropDown:SetValue(value)
		valueChangedCallback("dummy", value, dropDown);
	end
	return heightOffset - 20;
end

function SGTCore:AddOptionCheckbox(name, parent, anchor, checked, description, onChecked)
	local cb = CreateFrame("CheckButton", name, parent, "OptionsBaseCheckButtonTemplate")
	cb:SetSize(20,20);
	cb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5);
	cb:SetChecked(checked);
	cb:SetScript("OnClick", function(cb)
        onChecked(self, cb:GetChecked());
    end);
	local text = cb:CreateFontString(nil,"ARTWORK", "GameFontHighlight") ;
	text:SetPoint("LEFT", cb, "RIGHT", 0, 2);
	text:SetText(description);
	return cb;
end

function SGTCore:AddOptionSlider(name, parent, anchor, min, max, stepSize, value, description, onValueChanged)
	local sliderWrapper = CreateFrame("Frame", name .. "Wrapper", parent);
	sliderWrapper:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5);
	sliderWrapper:SetSize(100,30);
	local slider = CreateFrame("Slider", name, sliderWrapper, "OptionsSliderTemplate");
	slider:SetSize(100,20);
	slider:SetPoint("TOPLEFT", sliderWrapper, "TOPLEFT");
	slider.textLow = _G[name.."Low"];
	slider.textHigh = _G[name.."High"];
	slider.text = _G[name.."Text"];
	slider:SetMinMaxValues(min, max);
	slider.minValue, slider.maxValue = slider:GetMinMaxValues() ;
	slider.textLow:SetText(slider.minValue);
	slider.textHigh:SetText(slider.maxValue);
	slider.text:SetText(value);
	slider.text:SetPoint("TOP", slider, "BOTTOM", 0, -27);
	slider:SetValue(value);
	slider:SetValueStep(stepSize);
	slider:SetObeyStepOnDrag(true);

	slider:SetScript("OnValueChanged", function(self,value) 
		slider.text:SetText(value)
		onValueChanged(self, value);
	end)

	local text = slider:CreateFontString(nil,"ARTWORK", "GameFontHighlight") ;
	text:SetPoint("LEFT", slider, "RIGHT", 3, -1);
	text:SetText(description);
	sliderWrapper.slider = slider;
	return sliderWrapper;
end

function SGTCore:AddButton(name, parent, anchor, width, height, label, onClick)
	local button = CreateFrame("Button", name, parent, BackdropTemplateMixin and "BackdropTemplate");
	Backdrop = {
		bgFile = "Interface\\AddOns\\SGT_Core\\Assets\\Plain.tga",
		edgeFile = "Interface/Buttons/WHITE8X8",
		tile = true, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	}
	button:SetBackdrop(Backdrop)
	button:SetBackdropColor(0.25,0.25,0.25,0.9)
	button:SetBackdropBorderColor(0,0,0,1)
	button:SetSize(width, height)
	button.HighlightTexture = button:CreateTexture()
	button.HighlightTexture:SetColorTexture(1,1,1,.3)
	button.HighlightTexture:SetPoint("TOPLEFT")
	button.HighlightTexture:SetPoint("BOTTOMRIGHT")
	button:SetHighlightTexture(button.HighlightTexture)
	button.PushedTexture = button:CreateTexture()
	button.PushedTexture:SetColorTexture(.9,.8,.1,.3)
	button.PushedTexture:SetPoint("TOPLEFT")
	button.PushedTexture:SetPoint("BOTTOMRIGHT")
	button:SetPushedTexture(button.PushedTexture)
	button:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2);

	local text = button:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("TOPLEFT")
	text:SetPoint("BOTTOMRIGHT")
	text:SetText(label)
	button:SetScript("OnClick", function(self) 
		onClick();
	end)
	return button
end

function SGTCore:AddEmptyFrame(name, parent, anchor)
	local blankFrame = CreateFrame("Frame", name .. "Wrapper", parent);
	blankFrame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5);
	blankFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -5, 5);
	--blankFrame:SetSize(200,200);
	return blankFrame
end

function SGTCore:CreateFrameSheet(frame, pool, table, numColumns)
	SGTCore:PrepareTablePools(frame, pool)
	local sheet  = {}
	local maxWidth = {}
	local xStartValue = 0
	local xPosition = xStartValue
	local yPosition = 0
	local YDIFF = 15
	local XDIFF = 15
	local Backdrop = {
		bgFile = "Interface\\AddOns\\SGT_Core\\Assets\\Plain.tga",
		tile = false, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 1},
	}
	maxWidth = {}
	for i=1, numColumns do
		maxWidth[i] = 0
	end

	for i=1, #table do 
		for j=1, #table[i] do
			SGTCore:CompareTableValue(frame, maxWidth, j, table[i][j][2])
		end
	end
	for i=1, #table do
		local backgroundLine = SGTCore.backgroundLinePools[pool]:Acquire();
		backgroundLine:SetParent(frame);
		backgroundLine:Show();
		backgroundLine:SetPoint("TOPLEFT", 0, yPosition);
		backgroundLine:SetHeight(YDIFF);
		backgroundLine:SetBackdrop(Backdrop);
		backgroundLine:SetBackdropColor(0.2,0.2,0.2,((i+1)%2) * 0.5);

		for j=1, #table[i] do
			table[i][j][1]:SetParent(backgroundLine);
			SGTCore:SetElementPosition(table[i][j][1], xPosition, 0);
			SGTCore:DebugPrintTable(table[i][j][1]);
			table[i][j][1]:SetText("WTF");
			xPosition = xPosition + XDIFF + maxWidth[j];
		end
		backgroundLine:SetWidth(xPosition - XDIFF);
		xPosition = xStartValue;
		yPosition = yPosition - YDIFF;
	end
end

function SGTCore:CompareTableValue(frame, table, index, toCompare)
	if (toCompare > table[index]) then
		table[index] = toCompare
	end
end

function SGTCore:SetElementPosition(element, x, y)
	element:SetPoint("LEFT", x, 0);
	element:SetPoint("TOP", 0, y);
end

function SGTCore:CreateTableElement(frame, pool, text, r, g, b, a)
	local fontString = SGTCore.fontStringPools[pool]:Acquire();
	fontString:SetParent(frame);
	fontString:SetTextColor(r,g,b,a);
	print("--")
	print(r)
	print(a)
	fontString:SetJustifyH("LEFT");
	fontString:SetJustifyV("MIDDLE");
	fontString:SetPoint("LEFT", 15, 0);
	fontString:SetPoint("TOP", 0, -15);
	--print(text)
	fontString:SetText(text);
	fontString:Show();
	--fontString:SetSize(100,50);
	--print("created")
	return {fontString, fontString:GetStringWidth(text)}
end

function SGTCore:AddAnchoredFontString(name, parent, anchor, horizontalOffset, verticalOffset, textValue, font)
	if(font == nil) then
		font = "GameFontHighlight";
	end
	local text = parent:CreateFontString(name,"ARTWORK", font);
	text:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", horizontalOffset, verticalOffset)
	text:SetPoint("RIGHT", anchor, "RIGHT", -horizontalOffset)
	text:SetText(textValue);
	text:SetJustifyH("LEFT");
	return text;
end

function SGTCore:AddInitialAnchor(name, parent, anchor)
	local anchorFrame = CreateFrame("Frame", name, parent);
	anchorFrame:SetPoint("TOPLEFT", anchor, "TOPLEFT", 100)
	anchorFrame:SetPoint("RIGHT", anchor, "RIGHT", -100)
	anchorFrame:SetHeight(1);
	return anchorFrame;
end