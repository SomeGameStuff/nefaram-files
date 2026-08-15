Scriptname UIListMenu extends UIMenuBase

function ResetMenu()
endfunction

int function AddEntryItem(string entry, int parentIndex = -1, int callback = -1, bool hasChildren = false)
endfunction

function SetPropertyIndexInt(string propertyName, int value, int index)
endfunction

bool function OpenMenu(Form akForm = none, Form akReceiver = none)
endfunction

int function GetResultInt()
endfunction
