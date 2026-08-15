Scriptname MariasUtils extends Quest

UIListMenu function PrepareQuickMenu(string firstEntry = "", Form f = none)
endfunction

function AddQuickMenuEntry(string entry, Form f = none)
endfunction

function AddQuickMenuLocationEntries(Form[] entries, Form filter = none)
endfunction

Form function DoQuickMenuForm(bool forceSelection = false, bool random = false)
endfunction

string function PerformQuickMenuString(string[] menuitems, bool random = false)
endfunction

ObjectReference function SelectObjectReference(Form[] refs, bool forceSelection = false, bool random = false, bool addLocation = false, Form filter = none)
endfunction
