local Sway = require("sway")
local sway = Sway.connect()
local cjson = require("cjson")

-- helper methods
local function read(fname)
  local f = io.open(fname)
  if not f then
    return nil
  end

  local content = f:read("*all")
  f:close()
  return content
end
local function write(fname, str)
  local f = io.open(fname, "w")

  local content = f:write(str)
  f:close()
  return content
end

local default_state = {
  current_workroom = "h",
  active_workspaces = {}
}

local statefile_path = "/tmp/sway_workrooms"
local current_workroom_path = "/tmp/current_workroom"
local State = {}
local State_mt = {__index = State}

-- Assumption: the output-configuration does not change after first running the
-- script.
local output_default_workspace = require("output_conf")

function State:activate_workroom(id)
  -- store current workspaces
  self.active_workspaces[self.current_workroom] = {}
  local outputs = sway:getOutputs()
  local output_names = {}
  for _, output in ipairs(outputs) do
    self.active_workspaces[self.current_workroom][output.name] = output.current_workspace
    table.insert(output_names, output.name)
  end

  local active_output_spec
  local inactive_output_specs = {}
  for _, output in ipairs(outputs) do
    if output.focused then
      active_output_spec = output
    else
      table.insert(inactive_output_specs, output)
    end
  end

  -- set new state here
  self.current_workroom = id
  -- adjust variable for keybindings.
  sway:msg(("set $workroom %s"):format(id))
  write(current_workroom_path, self.current_workroom)

  -- map from output-name to workspace-name
  local new_workspaces
  if self.active_workspaces[id] then
    new_workspaces = self.active_workspaces[id]
  else
    new_workspaces = {}
    for _, output_name in ipairs(output_names) do
      new_workspaces[output_name] = id .. output_default_workspace[output_name]
    end
  end

  -- first set inactive outputs, then active one => we stay on the active output.
  local ordered_output_names = {}
  for _, output in ipairs(inactive_output_specs) do
    table.insert(ordered_output_names, output.name)
  end
  table.insert(ordered_output_names, active_output_spec.name)

  for _, output in ipairs(ordered_output_names) do
    local workspace = new_workspaces[output]
    sway:msg(("focus output %s"):format(output))
    os.execute("sleep 0.001")
    sway:msg(("workspace %s"):format(workspace))
  end
  write(statefile_path, cjson.encode(self))
end

local function get_state()
  local state_str = read(statefile_path)
  return setmetatable(state_str and cjson.decode(state_str) or default_state, State_mt)
end

local next_workroom = arg[1]

assert(#next_workroom == 1)

local state = get_state()
state:activate_workroom(next_workroom)
