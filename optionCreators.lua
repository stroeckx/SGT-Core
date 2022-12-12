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
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate");
	slider:SetSize(100,20);
	slider:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5);
	slider.textLow = _G[name.."Low"];
	slider.textHigh = _G[name.."High"];
	slider.text = _G[name.."Text"];
	slider:SetMinMaxValues(min, max);
	slider.minValue, slider.maxValue = slider:GetMinMaxValues() ;
	slider.textLow:SetText(slider.minValue);
	slider.textHigh:SetText(slider.maxValue);
	slider.text:SetText(value);
	slider.text:SetPoint("TOP", slider, "BOTTOM", 0, -25);
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

	return slider;
end