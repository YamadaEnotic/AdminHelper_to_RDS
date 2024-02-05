script_name("SY:NC Development | Admin Helper")
script_author("SY:NC Develope.")
script_version('0.1 Reborn')

require 'lib.moonloader'
local sampev							= require "lib.samp.events"
local font_admin_chat					= require ("moonloader").font_flag
local ev								= require ("moonloader").audiostream_state
local dlstat							= require ("moonloader").download_status
--local as_action                         = require('moonloader').audiostream_state
local ffi 								= require "ffi"
local getBonePosition 					= ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local mem 								= require "memory"
local imgui 							= require "imgui"
local encoding							= require "encoding"
local vkeys								= require "vkeys"
local inicfg							= require "inicfg"
local notfy								= import 'lib/imgui_notf.lua'
local res, sc_board						= pcall(import, 'lib/scoreboard.lua')
local fai                               = require 'fAwesome5'

encoding.default = 'CP1251' 
u8 = encoding.UTF8 

-- ## For ImGUI ## --
local fai_font = nil
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })

function imgui.BeforeDrawFrame()
    if fai_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fai_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/lib/fa-solid-900.ttf', 13.0, font_config, fai_glyph_ranges)
    end
end

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
imgui.Tooltip = require('imgui_addons').Tooltip

local i_elements = {
    windows = {
        main = imgui.ImBool(false),
    },
    boolean = {
        gset = false,
        keyset = false,
        achatset = false,
        floods = false,
        developer = false
    },
}
-- ## For ImGUI ## -- 
local sw, sh = getScreenResolution()

function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local icol = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowPadding = imgui.ImVec2(5, 5)
    style.WindowRounding = 15
    style.ChildWindowRounding = 10
    style.FramePadding = imgui.ImVec2(3, 3)
    style.FrameRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(3.0, 3.0)
    style.ItemInnerSpacing = imgui.ImVec2(3.0, 3.0)
    style.IndentSpacing = 21
    style.ScrollbarSize = 6.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 17.0
    style.GrabRounding = 16.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[icol.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00);
    colors[icol.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00);
    colors[icol.WindowBg]               = ImVec4(0.11, 0.11, 0.11, 0.50);
    colors[icol.ChildWindowBg]          = ImVec4(0.13, 0.13, 0.13, 1.00);
    colors[icol.PopupBg]                = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.Border]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.BorderShadow]           = ImVec4(0.26, 0.46, 0.82, 0.00);
    colors[icol.FrameBg]                = ImVec4(0.26, 0.46, 0.82, 0.59);
    colors[icol.FrameBgHovered]         = ImVec4(0.26, 0.46, 0.82, 0.88);
    colors[icol.FrameBgActive]          = ImVec4(0.28, 0.53, 1.00, 1.00);
    colors[icol.TitleBg]                = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgActive]          = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgCollapsed]       = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.MenuBarBg]              = ImVec4(0.26, 0.46, 0.82, 0.75);
    colors[icol.ScrollbarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.ScrollbarGrab]          = ImVec4(0.26, 0.46, 0.82, 0.68);
    colors[icol.ScrollbarGrabHovered]   = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ScrollbarGrabActive]    = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ComboBg]                = ImVec4(0.26, 0.46, 0.82, 0.79);
    colors[icol.CheckMark]              = ImVec4(1.000, 0.000, 0.000, 1.000)
    colors[icol.SliderGrab]             = ImVec4(0.263, 0.459, 0.824, 1.000)
    colors[icol.SliderGrabActive]       = ImVec4(0.66, 0.66, 0.66, 1.00);
    colors[icol.Button]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ButtonHovered]          = ImVec4(0.26, 0.46, 0.82, 0.59);
    colors[icol.ButtonActive]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.Header]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.HeaderHovered]          = ImVec4(0.26, 0.46, 0.82, 0.74);
    colors[icol.HeaderActive]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.Separator]              = ImVec4(0.37, 0.37, 0.37, 1.00);
    colors[icol.SeparatorHovered]       = ImVec4(0.60, 0.60, 0.70, 1.00);
    colors[icol.SeparatorActive]        = ImVec4(0.70, 0.70, 0.90, 1.00);
    colors[icol.ResizeGrip]             = ImVec4(1.00, 1.00, 1.00, 0.30);
    colors[icol.ResizeGripHovered]      = ImVec4(1.00, 1.00, 1.00, 0.60);
    colors[icol.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90);
    colors[icol.CloseButton]            = ImVec4(0.00, 0.00, 0.00, 1.00);
    colors[icol.CloseButtonHovered]     = ImVec4(0.00, 0.00, 0.00, 0.60);
    colors[icol.CloseButtonActive]      = ImVec4(0.35, 0.35, 0.35, 1.00);
    colors[icol.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[icol.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[icol.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[icol.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[icol.TextSelectedBg]         = ImVec4(0.00, 0.00, 1.00, 0.35);
    colors[icol.ModalWindowDarkening]   = ImVec4(0.20, 0.20, 0.20, 0.35);
end
apply_custom_style()

function main()
    while not isSampAvailable() do wait(0) end

    sampRegisterChatCommand('tool', function()
        i_elements.windows.main.v = not i_elements.windows.main.v
        imgui.Process = i_elements.windows.main.v
    end)
    
    while true do
        wait(0)

        imgui.Process = true
        
    end
end

function imgui.SelectableButton(text, check_press, question, size)
	local button_check
	if check_press then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.67, 0.67, 0.67, 1.00))
		
		button_check = imgui.Button(text, size)

		imgui.PopStyleColor(1)
	else
		imgui.PushStyleColor(imgui.Col.Button, imgui.Col.WindowBg)
		
		button_check = imgui.Button(text, size)

		imgui.PopStyleColor(1)
	end
    if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(500)
		imgui.TextUnformatted(question)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
	return button_check
end

function imgui.OnDrawFrame()
    if i_elements.windows.main.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver)

        imgui.Begin("##Main", i_elements.windows.main, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
            imgui.BeginChild('##Settings', imgui.ImVec2(-1,25), true)
                imgui.SetCursorPosX((imgui.GetWindowWidth()/2) - (imgui.CalcTextSize(u8"Настройки").x/2))
                imgui.Text(fai.ICON_FA_WRENCH .. u8" Настройки")
            imgui.EndChild()

            imgui.BeginChild('##FrameMenu', imgui.ImVec2(40,imgui.GetWindowHeight()-87), true)
                if imgui.SelectableButton(fai.ICON_FA_GLOBE, i_elements.boolean.gset, u8"Основные настройки", imgui.ImVec2(30, 30)) then
                    i_elements.boolean.gset = not i_elements.boolean.gset
                    i_elements.boolean.keyset = false
                    i_elements.boolean.achatset = false
                    i_elements.boolean.floods = false
                    i_elements.boolean.developer = false
                end
                if imgui.SelectableButton(fai.ICON_FA_KEYBOARD, i_elements.boolean.keyset, u8"Настройка клавишь скрипта", imgui.ImVec2(30, 30)) then
                    i_elements.boolean.gset = false
                    i_elements.boolean.keyset = not i_elements.boolean.keyset
                    i_elements.boolean.achatset = false
                    i_elements.boolean.floods = false
                    i_elements.boolean.developer = false
                end
                if imgui.SelectableButton(fai.ICON_FA_TH_LIST, i_elements.boolean.achatset, u8"Настройки админ чата", imgui.ImVec2(30, 30)) then
                    i_elements.boolean.gset = false
                    i_elements.boolean.keyset = false
                    i_elements.boolean.floods = false
                    i_elements.boolean.achatset = not i_elements.boolean.achatset
                    i_elements.boolean.developer = false
                end
                if imgui.SelectableButton(fai.ICON_FA_CODE_BRANCH, i_elements.boolean.floods, u8"Настройка флудов", imgui.ImVec2(30, 30)) then
                    i_elements.boolean.gset = false
                    i_elements.boolean.keyset = false
                    i_elements.boolean.achatset = false
                    i_elements.boolean.developer = false
                    i_elements.boolean.floods = not i_elements.boolean.floods
                end
                if imgui.SelectableButton(fai.ICON_FA_COGS, i_elements.boolean.developer, u8"Режим разработчика", imgui.ImVec2(30, 30)) then
                    i_elements.boolean.gset = false
                    i_elements.boolean.keyset = false
                    i_elements.boolean.achatset = false
                    i_elements.boolean.floods = false
                    i_elements.boolean.developer = not i_elements.boolean.developer
                end
            imgui.EndChild()

            imgui.SameLine()

            imgui.BeginChild('##FrameMain', imgui.ImVec2(-1,imgui.GetWindowHeight()-87), true)
                if i_elements.boolean.gset then  
                    imgui.Text("Test 1")
                end  
                if i_elements.boolean.keyset then  
                    imgui.Text("Test 2")
                end  
                if i_elements.boolean.achatset then  
                    imgui.Text("Test 3")
                end  
                if i_elements.boolean.floods then  
                    imgui.Text("Test 4")
                end  
                if i_elements.boolean.developer then  
                    imgui.Text("Test 5")
                end
            imgui.EndChild()

            imgui.SetCursorPosY(imgui.GetWindowHeight() - 50)
            imgui.BeginChild('##Description', imgui.ImVec2(-1, -1), true)
                if i_elements.boolean.gset then  
                    imgui.Text("Test 1")
                end  
                if i_elements.boolean.keyset then  
                    imgui.Text("Test 2")
                end  
                if i_elements.boolean.achatset then  
                    imgui.Text("Test 3")
                end  
                if i_elements.boolean.floods then  
                    imgui.Text("Test 4")
                end  
                if i_elements.boolean.developer then  
                    imgui.Text("Test 5")
                end
            imgui.EndChild()

        imgui.End()
    end
end