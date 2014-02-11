require('sdk.states.empty.StateEmpty')

local state = StateEmpty:new()

GameInfoBase:instance():managerStates():onCurrentStateCreated(state);

return state:sceneStoryboard()