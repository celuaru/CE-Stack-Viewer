--Author: MasterGH, 02.04.2015, Gamehacklab[RU] (http://gamehacklab.ru)

frmStackViewer = createFormFromFile(getCheatEngineDir().."\\autorun\\frmStackViewer.xml")

-- Проверяет существование формы
if(frmStackViewer == nil) then
	messageDialog('Can not find frmStackViewer', mtError, mbOK)
	return
end
frmStackViewer.Hide()
frmStackViewer.Caption = 'Stack Viewer [CE Lua Plugin, ver 1.0]'

-- Добавление подменю '* Stack Viewer [Plugin]' в иерархию меню в окне Дизассемблера
local menuItems = getMemoryViewForm().findComponentByName('MainMenu1').Items
local count = menuItems.Count - 1
frmSaveDialog = nil
frmOpenDialog = nil

-- Показывает TinyDumper из главного меню в окне Дизассемблера
function OnClickMenuItemStackViewer()
	frmStackViewer.Show()
end

for i = 0, count do
	local item = menuItems.getItem(i)
	if( (item.Caption == 'Tools') or (item.Caption == 'Инструменты') ) then
		local mi = createMenuItem(popupmenu)
		menuItem_setCaption(mi, '* Stack Viewer [Plugin]')
		menuItem_onClick(mi, OnClickMenuItemStackViewer)
		item.add(mi)
		break
	end
end



stackESPRSP = 0
isCurrentActive = false
AAReadMemESP0 = ''
AAReadMemRIP0 = ''


function debugger_onBreakpoint()
	if(isCurrentActive) then
		if(targetIs64Bit()) then
			if(RSP == stackESPRSP) then
				autoAssemble(AAReadMemRIP0)
				return 1
			end
		else
			if(ESP == stackESPRSP) then
				autoAssemble(AAReadMemESP0)
				return 1
			end
		end
	end
	return 0
end

function CECheckboxIsActiveChange(sender)

	if (getOpenedProcessID() == 0) then
		messageDialog('No target any process', mtError, mbOK)
		isCurrentActive = false
		return
	end

	isCurrentActive = not isCurrentActive
	
	local labelMem = frmStackViewer.CEEditAllocLabel.Text
	AAReadMemRIP0 = string.format([[
%s:
READMEM($RSP,$1000)]],labelMem)

	AAReadMemESP0 = string.format([[
%s:
READMEM($ESP,$1000)]],labelMem)

	if(isCurrentActive) then
		--AllocMem()
		autoAssemble(string.format([[
alloc(%s, $1000)
registersymbol(%s)]],labelMem,labelMem))
		--SetBreakpoint()
		stackESPRSP = tonumber(frmStackViewer.CEEditStack.Text, 16)
		local addressCode = tonumber(frmStackViewer.CEEditAdress.Text, 16)
		debug_setBreakpoint(addressCode)
	else
		--DeAllocMem()
		autoAssemble(string.format('dealloc(%s)',labelMem))
		--DelteLastBreakpoint()
		local addressCode = tonumber(frmStackViewer.CEEditAdress.Text, 16)
		debug_removeBreakpoint(addressCode)
	end

end