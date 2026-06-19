Media = Object:extend()
Media:implement(State)
function Media:init(name)
  self:init_state(name)
end


function Media:on_enter(from)
  camera.x, camera.y = gw/2, gh/2
  self.main = self:add_layer('main', Group())
  self.effects = self:add_layer('effects', Group())
  self.ui = self:add_layer('ui', Group())

  graphics.set_background_color(blue[0])
  Text2{group = self.ui, x = gw/2, y = gh/2, lines = {
    {text = '[fg]SNKRX', font = fat_font, alignment = 'center', height_offset = -15},
    {text = '[fg]loop update', font = pixul_font, alignment = 'center'},
  }}
end


function Media:update(dt)
  self:update_layers(dt*slow_amount, {'main', 'effects', 'ui'})
end


function Media:draw()
  self:draw_layers{'main', 'effects', 'ui'}

  mercenary:draw(30, 30, 0, 1, 1, 0, 0, yellow2[-5])
end
