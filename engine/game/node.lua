-- Node is the common tree primitive for engine-level ownership.
-- It intentionally uses node_parent instead of parent because SNKRX already
-- uses parent as gameplay ownership data in many objects.
EngineNode = Object:extend()
function EngineNode:init(args)
  self:init_node(args)
end


function EngineNode:init_node(args)
  args = args or {}
  self.node_parent = args.node_parent
  self.children = {}
  self.children.by_tag = {}
  self.children.by_id = {}
  self.node_tag = args.node_tag
  self.id = args.id or self.id or random:uid()
  return self
end


function EngineNode:tag(name)
  if self.node_parent and self.node_tag then
    self.node_parent.children.by_tag[self.node_tag] = nil
    self.node_parent[self.node_tag] = nil
  end
  self.node_tag = name
  if self.node_parent and name then
    self.node_parent.children.by_tag[name] = self
    self.node_parent[name] = self
  end
  return self
end


function EngineNode:append(child, tag)
  if not child then return end
  if child.node_parent and child.node_parent ~= self and child.detach then
    child:detach()
  end

  child.node_parent = self
  if not child.id then child.id = random:uid() end
  if tag then child.node_tag = tag end

  table.insert(self.children, child)
  self.children.by_id[child.id] = child
  if child.node_tag then
    self.children.by_tag[child.node_tag] = child
    self[child.node_tag] = child
  end
  return child
end


function EngineNode:remove(child)
  if not child then return end
  table.delete(self.children, function(v) return v == child end)
  if child.id then self.children.by_id[child.id] = nil end
  if child.node_tag then
    self.children.by_tag[child.node_tag] = nil
    self[child.node_tag] = nil
  end
  child.node_parent = nil
  return child
end


function EngineNode:detach()
  local parent = self.node_parent
  if not parent then return self end

  parent:remove(self)
  return self
end


function EngineNode:get_child(tag_or_id)
  return self.children.by_tag[tag_or_id] or self.children.by_id[tag_or_id]
end


function EngineNode:update_children(dt)
  for _, child in ipairs(self.children) do
    if child.update and not child.dead then child:update(dt) end
  end
  self:remove_dead_children()
end


function EngineNode:draw_children(...)
  for _, child in ipairs(self.children) do
    if child.draw and not child.hidden and not child.dead then child:draw(...) end
  end
end


function EngineNode:remove_dead_children()
  for i = #self.children, 1, -1 do
    local child = self.children[i]
    if child.dead then
      if child.destroy then child:destroy() end
      if child.id then self.children.by_id[child.id] = nil end
      if child.node_tag then
        self.children.by_tag[child.node_tag] = nil
        self[child.node_tag] = nil
      end
      child.node_parent = nil
      table.remove(self.children, i)
    end
  end
end


function EngineNode:destroy()
  for _, child in ipairs(self.children) do
    if child.destroy then child:destroy() end
    child.node_parent = nil
  end
  self.children = {}
  self.children.by_tag = {}
  self.children.by_id = {}
  return self
end
