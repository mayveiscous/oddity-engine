local SelectionService = {}

SelectionService.current = nil

function SelectionService.Select(inst)
    if SelectionService.current == inst then return end
    SelectionService.current = inst
    print(("Selected: %s"):format(inst.Name))
end

function SelectionService.Clear()
    SelectionService.current = nil
end

return SelectionService