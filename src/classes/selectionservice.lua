local SelectionService = {}

SelectionService.current = nil
SelectionService._selected = {}

function SelectionService.Select(inst)
    SelectionService._selected = { inst }
    SelectionService.current = inst
    print(("Selected: %s"):format(inst.Name))
end

function SelectionService.Add(inst)
    for _, s in ipairs(SelectionService._selected) do
        if s == inst then return end
    end
    table.insert(SelectionService._selected, inst)
    SelectionService.current = SelectionService._selected[1]
    print(("Selected: %s (+%d more)"):format(inst.Name, #SelectionService._selected - 1))
end

function SelectionService.Toggle(inst)
    for i, s in ipairs(SelectionService._selected) do
        if s == inst then
            table.remove(SelectionService._selected, i)
            SelectionService.current = SelectionService._selected[1] or nil
            return
        end
    end
    SelectionService.Add(inst)
end

function SelectionService.Contains(inst)
    for _, s in ipairs(SelectionService._selected) do
        if s == inst then return true end
    end
    return false
end

function SelectionService.GetAll()
    return SelectionService._selected
end

function SelectionService.Clear()
    SelectionService._selected = {}
    SelectionService.current = nil
end

return SelectionService
