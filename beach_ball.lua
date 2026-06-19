BeachBallArena = Object:extend()
BeachBallArena:implement(State)
BeachBallArena:implement(GameObject)
function BeachBallArena:init(name)
  self:init_state(name)
  self:init_game_object()
end


function BeachBallArena:on_enter(from)
  slow_amount = 1
  self.hfx:add('condition1', 1)
  self.hfx:add('condition2', 1)
  self.main_slow_amount = 1
  self.damage_dealt = 0
  self.damage_taken = 0
  self.enemies = {Seeker, EnemyCritter}
  self.wave = 0
  self.score = 0
  self.combo = 0
  self.elapsed = 0
  self.wall_bounces = 0
  self.reward_text = nil
  self.units = {}
  self.passives = {}
  self.color = fg[0]

  self.ranger_level = 0
  self.warrior_level = 0
  self.mage_level = 0
  self.rogue_level = 0
  self.nuker_level = 0
  self.curser_level = 0
  self.forcer_level = 0
  self.swarmer_level = 0
  self.voider_level = 0
  self.enchanter_level = 0
  self.healer_level = 0
  self.psyker_level = 0
  self.conjurer_level = 0
  self.sorcerer_level = 0
  self.mercenary_level = 0

  if not state.mouse_control then
    input:set_mouse_visible(false)
  end

  trigger:tween(2, main_song_instance, {volume = 0.5, pitch = 1}, math.linear)
  steam.friends.setRichPresence('steam_display', '#StatusFull')
  steam.friends.setRichPresence('text', 'Beach Ball')

  self.floor = self:add_layer('floor', Group())
  self.main = self:add_layer('main', Group():set_as_physics_world(32, 0, 0, {'player', 'enemy', 'projectile', 'enemy_projectile', 'force_field', 'ghost'}))
  self.post_main = self:add_layer('post_main', Group())
  self.effects = self:add_layer('effects', Group())
  self.ui = self:add_layer('ui', Group())
  self.main:disable_collision_between('player', 'player')
  self.main:disable_collision_between('projectile', 'projectile')
  self.main:disable_collision_between('projectile', 'enemy')
  self.main:disable_collision_between('projectile', 'enemy_projectile')
  self.main:disable_collision_between('enemy_projectile', 'enemy')
  self.main:disable_collision_between('enemy_projectile', 'enemy_projectile')
  self.main:disable_collision_between('player', 'force_field')
  self.main:disable_collision_between('projectile', 'force_field')
  self.main:disable_collision_between('ghost', 'player')
  self.main:disable_collision_between('ghost', 'projectile')
  self.main:disable_collision_between('ghost', 'enemy')
  self.main:disable_collision_between('ghost', 'enemy_projectile')
  self.main:disable_collision_between('ghost', 'ghost')
  self.main:disable_collision_between('ghost', 'force_field')
  self.main:enable_trigger_between('projectile', 'enemy')
  self.main:enable_trigger_between('enemy_projectile', 'player')
  self.main:enable_trigger_between('player', 'enemy_projectile')
  self.main:enable_trigger_between('enemy_projectile', 'enemy')

  self.x1, self.y1 = gw/2 - 0.8*gw/2, gh/2 - 0.8*gh/2
  self.x2, self.y2 = gw/2 + 0.8*gw/2, gh/2 + 0.8*gh/2
  self.w, self.h = self.x2 - self.x1, self.y2 - self.y1
  self.spawn_points = {
    {x = self.x1 + 32, y = self.y1 + 32},
    {x = self.x1 + 32, y = self.y2 - 32},
    {x = self.x2 - 32, y = self.y1 + 32},
    {x = self.x2 - 32, y = self.y2 - 32},
    {x = gw/2, y = self.y1 + 32},
    {x = gw/2, y = self.y2 - 32},
  }
  self.spawn_offsets = {{x = -12, y = -12}, {x = 12, y = -12}, {x = 12, y = 12}, {x = -12, y = 12}, {x = 0, y = 0}}

  Wall{group = self.main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  Wall{group = self.main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(-40, -40, self.x1, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x2, -40, gw + 40, gh + 40), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, -40, self.x2, self.y1), color = bg[-1]}
  WallCover{group = self.post_main, vertices = math.to_rectangle_vertices(self.x1, self.y2, self.x2, gh + 40), color = bg[-1]}
  BeachBallPillar{group = self.main, x = self.x1 + self.w/3, y = self.y1 + self.h/3, rs = 14}
  BeachBallPillar{group = self.main, x = self.x1 + 2*self.w/3, y = self.y1 + self.h/3, rs = 14}
  BeachBallPillar{group = self.main, x = self.x1 + self.w/2, y = self.y1 + 2*self.h/3, rs = 14}

  for i = 1, 5 do
    local unit = BeachBallUnit{group = self.main, x = gw/2 - (i-1)*12, y = gh/2 + 16, leader = i == 1, follower_index = i - 1, parent = self.player}
    if i == 1 then
      self.player = unit
      self.units[1] = unit
    else
      unit.parent = self.player
      table.insert(self.player.followers, unit)
      table.insert(self.units, unit)
    end
  end

  self.ball = BeachBall{group = self.main, x = gw/2, y = gh/2 - 38, r = random:float(-math.pi/4, math.pi/4), v = 132, parent = self.player}
  self.title_text = Text2{group = self.ui, x = gw/2, y = self.y1 - 14, lines = {{text = '[fg, wavy_mid]beach ball', font = fat_font, alignment = 'center'}}}
  self.help_text = Text2{group = self.floor, x = gw/2, y = gh/2 + 54, sx = 0.6, sy = 0.6, lines = {{text = '[light_bg]bounce the ball with your snake - 7th wall bounce loses', font = fat_font, alignment = 'center'}}}
  self.help_text.t:after(8, function() self.help_text.t:tween(0.2, self.help_text, {sy = 0}, math.linear) end)

  self.t:every(0.375, function()
    local p = random:table(star_positions)
    Star{group = star_group, x = p.x, y = p.y}
  end)

  self:spawn_wave()
  self.t:every(6, function()
    if self.died then return end
    self:spawn_wave()
  end)
end


function BeachBallArena:on_exit()
  self:destroy_layers()
  self.t:destroy()
  self.floor = nil
  self.main = nil
  self.post_main = nil
  self.effects = nil
  self.ui = nil
  self.player = nil
  self.ball = nil
  self.t = nil
  self.springs = nil
  self.flashes = nil
  self.hfx = nil
  input:set_mouse_visible(true)
end


function BeachBallArena:update(dt)
  if main_song_instance:isStopped() then
    main_song_instance = _G[random:table{'song1', 'song2', 'song3', 'song4', 'song5'}]:play{volume = 0.5}
  end

  if input.escape.pressed and not self.transitioning then
    if not self.paused then open_options(self)
    else close_options(self) end
  end

  self:update_game_object(dt*slow_amount)
  if not self.paused and not self.died and not self.transitioning then
    self.elapsed = self.elapsed + dt
    run_time = self.elapsed
    star_group:update(dt*slow_amount)
    self:update_layers(dt*self.main_slow_amount, {'floor', 'main', 'post_main', 'effects', 'ui'})
  else
    self:update_layers(dt*slow_amount, {'ui'})
  end
end


function BeachBallArena:draw()
  self:draw_layers{'floor', 'main', 'post_main', 'effects'}
  graphics.draw_with_mask(function()
    star_canvas:draw(0, 0, 0, 1, 1)
  end, function()
    camera:attach()
    graphics.rectangle(gw/2, gh/2, self.w, self.h, nil, nil, fg[0])
    camera:detach()
  end, true)

  camera:attach()
    graphics.print_centered('score: ' .. tostring(self.score), pixul_font, self.x1 + 42, self.y1 - 12, 0, 1, 1, nil, nil, fg[0])
    graphics.print_centered('wave: ' .. tostring(self.wave), pixul_font, self.x1 + 116, self.y1 - 12, 0, 1, 1, nil, nil, blue[0])
    graphics.print_centered('wall bounces: ' .. tostring(self.wall_bounces) .. '/6', pixul_font, self.x2 - 58, self.y1 - 12, 0, 1, 1, nil, nil, self.wall_bounces >= 5 and red[0] or yellow[0])
    local hp = self:get_total_hp()
    local max_hp = self:get_total_max_hp()
    graphics.line(self.x1, self.y2 + 14, self.x2, self.y2 + 14, bg[-3], 3)
    graphics.line(self.x1, self.y2 + 14, self.x1 + self.w*math.clamp(max_hp > 0 and hp/max_hp or 0, 0, 1), self.y2 + 14, green[0], 3)
  camera:detach()

  if self.paused or self.died then graphics.rectangle(gw/2, gh/2, 2*gw, 2*gh, nil, nil, modal_transparent) end
  self:draw_layers{'ui'}
end


function BeachBallArena:get_total_hp()
  local hp = 0
  for _, unit in ipairs(self.units) do
    if not unit.dead then hp = hp + math.max(unit.hp, 0) end
  end
  return hp
end


function BeachBallArena:get_total_max_hp()
  local hp = 0
  for _, unit in ipairs(self.units) do
    if not unit.dead then hp = hp + unit.max_hp end
  end
  return hp
end


function BeachBallArena:remove_unit(unit)
  if self.died or unit.removed_from_snake then return end
  unit.removed_from_snake = true
  unit.dead = true
  HitCircle{group = self.effects, x = unit.x, y = unit.y, rs = 10, color = red[0], duration = 0.18}

  local surviving_units = {}
  for _, u in ipairs(self.units) do
    if u ~= unit and not u.dead then table.insert(surviving_units, u) end
  end
  self.units = surviving_units

  if #self.units == 0 then
    self:die('the enemies killed the snake')
    return
  end

  local leader = self.units[1]
  self.player = leader
  leader.leader = true
  leader.parent = nil
  leader.follower_index = 0
  leader.followers = {}
  leader.previous_positions = leader.previous_positions or {}
  if #leader.previous_positions == 0 then
    table.insert(leader.previous_positions, 1, {x = leader.x, y = leader.y, r = leader.r})
  end

  for i = 2, #self.units do
    local follower = self.units[i]
    follower.leader = false
    follower.parent = leader
    follower.follower_index = i - 1
    follower.followers = {}
    table.insert(leader.followers, follower)
  end

  if self.ball then self.ball.parent = leader end
end


function BeachBallArena:spawn_wave()
  self.wave = self.wave + 1
  local count = math.min(5 + math.floor(self.wave*0.6) + math.floor(self.elapsed/20), 26)
  local p = random:table(self.spawn_points)
  local elite_type = self.wave % 15 == 0 and not self:has_active_elite() and random:table{'speed_booster', 'exploder', 'shooter', 'headbutter', 'tank', 'spawner'} or nil

  self.spawning_enemies = true
  SpawnMarker{group = self.effects, x = p.x, y = p.y}
  self.t:after(1.125, function() self:spawn_n_enemies(p, self.wave, count, elite_type) end)
  self.t:after(1.125 + count*0.1 + 0.5, function() self.spawning_enemies = false end, 'spawning_enemies')
end


function BeachBallArena:has_active_elite()
  local enemies = self.main:get_objects_by_classes(self.enemies)
  for _, enemy in ipairs(enemies) do
    if enemy.speed_booster or enemy.exploder or enemy.shooter or enemy.headbutter or enemy.tank or enemy.spawner then return true end
  end
end


function BeachBallArena:spawn_n_enemies(p, j, n, elite_type)
  if self.died then return end
  if n and n <= 0 then return end

  j = j or 1
  n = n or 4
  local level = 1 + math.floor(self.elapsed/18)
  local spawned_elite = false
  local check_circle = Circle(0, 0, 2)
  self.t:every(0.1, function()
    if self.died or not self.main.world then return end
    local o = self.spawn_offsets[(self.t:get_every_iteration('beach_ball_spawn_enemies_' .. j) % 5) + 1]
    SpawnEffect{group = self.effects, x = p.x + o.x, y = p.y + o.y, action = function(x, y)
      if self.died or not self.main.world then return end
      check_circle:move_to(x, y)
      local objects = self.main:get_objects_in_shape(check_circle, {Seeker, EnemyCritter, BeachBallUnit, BeachBall, Wall})
      if #objects > 0 then return end

      local spawn_elite = elite_type and not spawned_elite and not self:has_active_elite()
      if spawn_elite then spawned_elite = true end
      Seeker{group = self.main, x = x, y = y, character = 'seeker', level = level,
        speed_booster = spawn_elite and elite_type == 'speed_booster', exploder = spawn_elite and elite_type == 'exploder',
        shooter = spawn_elite and elite_type == 'shooter', headbutter = spawn_elite and elite_type == 'headbutter',
        tank = spawn_elite and elite_type == 'tank', spawner = spawn_elite and elite_type == 'spawner'}
      spawn1:play{pitch = random:float(0.9, 1.1), volume = 0.1}
    end}
  end, n, nil, 'beach_ball_spawn_enemies_' .. j)
end


function BeachBallArena:on_ball_hit_enemy(enemy)
  self.hfx:use('condition1', 0.25, 200, 10)
end


function BeachBallArena:on_ball_kill_enemy(enemy)
  self.combo = self.combo + 1
  self.score = self.score + ((enemy.boss or enemy.tank) and 5 or 1)
  self.hfx:use('condition1', 0.25, 200, 10)
  self:reward_health('beach ball kill')
end


function BeachBallArena:reward_health(reason)
  if self.died then return end
  for _, unit in ipairs(self.units) do
    if not unit.dead then
      unit:heal(0.08*unit.max_hp)
    end
  end
  heal1:play{pitch = random:float(0.95, 1.05), volume = 0.45}
  self.reward_text = Text2{group = self.ui, x = gw/2, y = self.y2 + 32, lines = {{text = '[green, wavy_mid]+' .. reason .. ' health', font = pixul_font, alignment = 'center'}}}
  self.reward_text.t:after(1.25, function() self.reward_text.dead = true end)
end


function BeachBallArena:die(reason)
  if self.died then return end
  self.died = true
  input:set_mouse_visible(true)
  self.t:tween(1, self, {main_slow_amount = 0}, math.linear, function() self.main_slow_amount = 0 end)
  self.died_text = Text2{group = self.ui, x = gw/2, y = gh/2 - 28, lines = {
    {text = '[wavy_mid, cbyc]beach ball ended', font = fat_font, alignment = 'center', height_multiplier = 1.25},
    {text = '[fg]' .. reason, font = pixul_font, alignment = 'center', height_multiplier = 1.4},
    {text = '[fg]score: [yellow]' .. tostring(self.score), font = pixul_font, alignment = 'center'},
  }}
  self.restart_button = Button{group = self.ui, x = gw/2, y = gh/2 + 42, force_update = true, button_text = 'restart beach ball', fg_color = 'bg10', bg_color = 'bg', action = function()
    self.transitioning = true
    ui_transition2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    TransitionEffect{group = main.transitions, x = gw/2, y = gh/2, color = state.dark_transitions and bg[-2] or fg[0], transition_action = function()
      main:add(BeachBallArena'beach_ball')
      main:go_to('beach_ball')
    end}
  end}
  self.main_menu_button = Button{group = self.ui, x = gw/2, y = gh/2 + 66, force_update = true, button_text = 'main menu', fg_color = 'bg10', bg_color = 'bg', action = function()
    self.transitioning = true
    ui_transition2:play{pitch = random:float(0.95, 1.05), volume = 0.5}
    TransitionEffect{group = main.transitions, x = gw/2, y = gh/2, color = state.dark_transitions and bg[-2] or fg[0], transition_action = function()
      main:add(MainMenu'mainmenu')
      main:go_to('mainmenu')
    end}
  end}
end


BeachBallPillar = Wall:extend()
function BeachBallPillar:init(args)
  self:init_game_object(args)
  self.rs = self.rs or 14
  self:set_as_circle(self.rs, 'static', 'solid')
  self:set_restitution(0.65)
  self.color = self.color or bg[-2]
  self.outline_color = self.outline_color or fg[0]
end


function BeachBallPillar:update(dt)
  self:update_game_object(dt)
end


function BeachBallPillar:draw()
  graphics.circle(self.x, self.y, self.rs, self.color)
  graphics.circle(self.x, self.y, self.rs, self.outline_color, 1)
  graphics.circle(self.x, self.y, 0.45*self.rs, bg[-1])
end


BeachBallUnit = Object:extend()
BeachBallUnit:implement(GameObject)
BeachBallUnit:implement(Physics)
function BeachBallUnit:init(args)
  self:init_game_object(args)
  self:set_as_rectangle(9, 9, 'dynamic', 'player')
  self:set_restitution(0.5)
  self.hfx:add('hit', 1)
  self.color = fg[0]
  self.max_hp = 75
  self.hp = self.max_hp
  self.dmg = 5
  self.max_v = 82*1.35
  self.r = args.r or -math.pi/8
  self.followers = {}
  self.previous_positions = {}
end


function BeachBallUnit:update(dt)
  self:update_game_object(dt)
  if self.leader then
    table.insert(self.previous_positions, 1, {x = self.x, y = self.y, r = self.r})
    if #self.previous_positions > 256 then self.previous_positions[257] = nil end
    if state.mouse_control then
      self.r = self.r + math.sign(Vector(math.cos(self.r), math.sin(self.r)):perpendicular():dot(Vector(math.cos(self:angle_to_mouse()), math.sin(self:angle_to_mouse()))))*1.66*math.pi*dt
    else
      if input.move_left.down then self.r = self.r - 1.66*math.pi*dt end
      if input.move_right.down then self.r = self.r + 1.66*math.pi*dt end
    end
    self:set_velocity(self.max_v*math.cos(self.r), self.max_v*math.sin(self.r))
    self:set_angle(self.r)
  else
    local target_distance = 10.4*self.follower_index
    local distance_sum = 0
    local p
    local previous = self.parent
    for _, point in ipairs(self.parent.previous_positions) do
      distance_sum = distance_sum + math.distance(previous.x, previous.y, point.x, point.y)
      if distance_sum >= target_distance then
        p = point
        break
      end
      previous = point
    end
    if p then
      self:set_position(p.x, p.y)
      self:set_angle(p.r)
      self.r = p.r
    end
  end
end


function BeachBallUnit:draw()
  graphics.push(self.x, self.y, self.r, self.hfx.hit.x, self.hfx.hit.x)
    local hp_ratio = math.clamp(self.hp/self.max_hp, 0, 1)
    local body_color = self.hfx.hit.f and fg[0] or self.color
    if state.unit_health_as_fill == false then
      graphics.rectangle(self.x, self.y, self.shape.w, self.shape.h, 3, 3, body_color)
      if hp_ratio < 1 then
        graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x + 0.5*self.shape.w, self.y - self.shape.h, bg[-3], 2)
        graphics.line(self.x - 0.5*self.shape.w, self.y - self.shape.h, self.x - 0.5*self.shape.w + hp_ratio*self.shape.w, self.y - self.shape.h, green[0], 2)
      end
    else
      local outline_w, outline_h = math.max(self.shape.w - 1, 0), math.max(self.shape.h - 1, 0)
      local fill_h = outline_h*hp_ratio
      graphics.rectangle(self.x, self.y + outline_h/2 - fill_h/2, outline_w, fill_h, 2, 2, green[0])
      graphics.rectangle(self.x, self.y, outline_w, outline_h, 3, 3, body_color, 1)
    end
  graphics.pop()
end


function BeachBallUnit:heal(amount)
  self.hp = math.min(self.max_hp, self.hp + amount)
  HitCircle{group = main.current.effects, x = self.x, y = self.y, rs = 6, color = green[0], duration = 0.1}
end


function BeachBallUnit:hit(damage)
  if self.dead or main.current.died then return end
  self.hp = self.hp - math.max(damage, 0)
  self.hfx:use('hit', 0.25, 200, 10)
  hit1:play{pitch = random:float(0.95, 1.05), volume = 0.25}
  main.current.damage_taken = main.current.damage_taken + damage
  if self.hp <= 0 then
    main.current:remove_unit(self)
  end
end


function BeachBallUnit:get_all_units()
  local units = {self}
  for _, unit in ipairs(self.followers or {}) do table.insert(units, unit) end
  return units
end


function BeachBallUnit:bounce(nx, ny)
  local vx, vy = self:get_velocity()
  if nx == 0 then
    self:set_velocity(vx, -vy)
    self.r = 2*math.pi - self.r
  end
  if ny == 0 then
    self:set_velocity(-vx, vy)
    self.r = math.pi - self.r
  end
  return self.r
end


function BeachBallUnit:on_collision_enter(other, contact)
  local x, y = contact:getPositions()
  if other:is(Wall) then
    self.hfx:use('hit', 0.3, 200, 10, 0.1)
    self:bounce(contact:getNormal())
    player_hit_wall1:play{pitch = random:float(0.95, 1.05), volume = 0.08}
  elseif table.any(main.current.enemies, function(v) return other:is(v) end) then
    other:hit(self.dmg, self, nil, true)
    other:push(20, self:angle_to_object(other))
    self:hit(other.dmg or 6)
    HitCircle{group = main.current.effects, x = x, y = y, rs = 6, color = fg[0], duration = 0.1}
  end
end


function BeachBallUnit:on_trigger_enter(other)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    other:hit(self.dmg, self)
    self:hit(other.dmg or 6)
  end
end


BeachBall = Object:extend()
BeachBall:implement(GameObject)
BeachBall:implement(Physics)
BeachBall:implement(Unit)
function BeachBall:init(args)
  self:init_game_object(args)
  self:init_unit()
  self:set_as_circle(8, 'dynamic', 'projectile')
  self:set_restitution(1)
  self.color = fg[0]
  self.dmg = 45
  self.v = args.v or 132
  self.r = args.r or random:float(0, 2*math.pi)
  self:set_velocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
end


function BeachBall:update(dt)
  self:update_game_object(dt)
  local vx, vy = self:get_velocity()
  local v = math.length(vx, vy)
  if v < 1 then
    self:set_velocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
  else
    self.r = math.atan2(vy, vx)
    local target = main.current and main.current.player
    if target and not target.dead and self:distance_to_object(target) > 48 then
      local tracking = math.remap(math.clamp(self.wall_bounces or 0, 0, 6), 0, 6, 0.86, 0.55)
      self.r = math.lerp_angle_dt(tracking, dt, self.r, self:angle_to_object(target))
    end
    self:set_velocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
  end
  self:set_angle(self.r)
end


function BeachBall:draw()
  local colors = {red[0], orange[0], yellow[0], green[0], blue[0], purple[0]}
  local t = love.timer.getTime()
  graphics.push(self.x, self.y, self.r + t*4, self.hfx.hit.x, self.hfx.hit.x)
    graphics.circle(self.x, self.y, self.shape.rs + 1, fg[0], 1)
    for i, color in ipairs(colors) do
      graphics.arc('pie', self.x, self.y, self.shape.rs, (i-1)*math.pi/3 + t*2, i*math.pi/3 + t*2, color)
    end
    graphics.circle(self.x, self.y, self.shape.rs*0.35, fg[0])
  graphics.pop()
end


function BeachBall:on_collision_enter(other, contact)
  if other:is(Wall) then
    self:bounce(contact:getNormal())
    local target = main.current and main.current.player
    if target and not target.dead then
      self.r = math.lerp_angle(0.32, self.r, self:angle_to_object(target))
      self:set_velocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    end
    self.wall_bounces = (self.wall_bounces or 0) + 1
    main.current.wall_bounces = self.wall_bounces
    camera:spring_shake(2, self.r)
    pop1:play{pitch = random:float(0.9, 1.1), volume = 0.3}
    if self.wall_bounces >= 7 then
      main.current:die('the ball bounced off walls 7 times')
    end
  elseif other:is(BeachBallUnit) then
    self.wall_bounces = 0
    main.current.wall_bounces = 0
    local r = other:angle_to_object(self)
    self.r = r + random:float(-math.pi/12, math.pi/12)
    self.v = math.min(self.v + 1.6, 208)
    self:set_velocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    self.hfx:use('hit', 0.2, 200, 10)
    other.hfx:use('hit', 0.15, 200, 10)
    camera:spring_shake(3, self.r)
    hit2:play{pitch = random:float(0.95, 1.05), volume = 0.25}
  end
end


function BeachBall:on_trigger_enter(other)
  if table.any(main.current.enemies, function(v) return other:is(v) end) then
    local was_dead = other.dead
    other:hit(self.dmg, self)
    if other.dead and not was_dead then
      main.current:on_ball_kill_enemy(other)
    else
      if other.push then other:push(20, self.r) end
      main.current:on_ball_hit_enemy(other)
    end
    self.hfx:use('hit', 0.08, 200, 10)
    HitCircle{group = main.current.effects, x = other.x, y = other.y, rs = 6, color = fg[0], duration = 0.1}
    hit2:play{pitch = random:float(0.95, 1.05), volume = 0.18}
  end
end
