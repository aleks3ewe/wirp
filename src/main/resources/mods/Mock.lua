function isClient()
    return false
end

local mockEvents = {}

function mockEvents.OnClientCommand_Add(callback)
    print("Mock method called with callback!\n", callback)
end

Events = {
    OnClientCommand = {
        Add = mockEvents.OnClientCommand_Add
    }
}