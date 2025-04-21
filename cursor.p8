pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- ヒままヒ☉◆フ⌂へヒ█▒
player = {x=64, y=64, sprite=16}
enemies = {}
score = 0
time_elapsed = 0
max_enemies = 6
state = "start"


particles = {}


function init_particles()
    for i=1,50 do
        add(particles, {
            x = rnd(128), -- 粒子初始x坐标
            y = rnd(128), -- 粒子初始y坐标
            dx = rnd(2) - 1, -- 粒子x方向速度
            dy = rnd(2) - 1, -- 粒子y方向速度
            life = rnd(60) + 60 -- 粒子生命时长
        })
    end
end

function update_particles()
    for p in all(particles) do
        p.x += p.dx -- 更新粒子x坐标
        p.y += p.dy -- 更新粒子y坐标
        p.life -= 1 -- 减少粒子生命
        if p.life <= 0 then -- 如果粒子生命结束
            p.x = rnd(128) -- 重置粒子x坐标
            p.y = rnd(128) -- 重置粒子y坐标
            p.dx = rnd(2) - 1 -- 重置粒子x方向速度
            p.dy = rnd(2) - 1 -- 重置粒子y方向速度
            p.life = rnd(60) + 60 -- 重置粒子生命时长
        end
    end
end

function draw_particles()
    for p in all(particles) do
        local color = (p.life % 2 == 0) and 14 or 15 -- 交替使用14号色和15号色
        pset(p.x, p.y, color) -- 绘制粒子
    end
end


function _init()
    init_enemies() -- 初始化敌人
    init_particles() -- 初始化粒子
    state = "start" -- 设置初始状态为 start
    music(0, 0, 7) -- 播放 00 号音乐并循环
end


function _update()
    if state == "start" then
        update_particles() -- 更新粒子效果
        if btnp(4) then
            state = "playing" -- 切换到游戏进行状态
            reset_game() -- 重置游戏
        end
    elseif state == "playing" then
        update_player() -- 更新玩家位置
        update_enemies() -- 更新敌人位置
        time_elapsed += 1 -- 增加时间计数
        if time_elapsed % 60 == 0 then
            score += 1 -- 每秒增加1分
        end
        if btnp(4) then
            generate_player_particles() -- 在玩家位置生成粒子效果
        end
    elseif state == "gameover" then
        if btnp(4) then
            _init() -- 重新初始化游戏
        end
    end
end


function reset_game()
    player.x = 64
    player.y = 64
    score = 0
    time_elapsed = 0
    state = "playing"
    enemies = {}
    init_enemies()
end

function _draw()
    cls() -- 清屏
    if state == "start" then
        draw_particles() -- 绘制粒子效果
        print_centered("Press Z to Start", 64, 60, 7) -- 显示开始提示
    elseif state == "playing" then
        map() -- 绘制地图
        draw_player() -- 绘制玩家
        draw_enemies() -- 绘制敌人
        print("Score: "..score, 5, 5, 7) -- 显示分数
    elseif state == "gameover" then
        print_centered("Game Over!", 64, 50, 8) -- 显示游戏结束
        print_centered("Score: "..score, 64, 60, 7) -- 显示最终分数
        print_centered("Press Z to restart", 64, 70, 7) -- 显示重启提示
    end
end


function update_player()
    if btn(0) then player.x -= 2 end 
    if btn(1) then player.x += 2 end 
    if btn(2) then player.y -= 2 end 
    if btn(3) then player.y += 2 end 
    player.x = mid(0, player.x, 128-16)
    player.y = mid(0, player.y, 128-16)
end


function draw_player()
    
    spr(player.sprite, player.x, player.y, 2, 2)
end

function init_enemies()
    for i=1,max_enemies do
    
        local direction = flr(rnd(4))
        local x, y, dx, dy
        if direction == 0 then
            x, y, dx, dy = rnd(128), -8, 0, rnd(2)+1 
        elseif direction == 1 then
            x, y, dx, dy = rnd(128), 136, 0, -(rnd(2)+1) 
            x, y, dx, dy = -8, rnd(128), rnd(2)+1, 0  
        else
            x, y, dx, dy = 136, rnd(128), -(rnd(2)+1), 0 
        end
    
        add(enemies, {x=x, y=y, dx=dx, dy=dy, sprite=0})
    end
end


function update_enemies()
    for e in all(enemies) do
        e.x += e.dx
        e.y += e.dy
    
        if e.x < -8 or e.x > 136 or e.y < -8 or e.y > 136 then
            local direction = flr(rnd(4))
            if direction == 0 then
                e.x, e.y, e.dx, e.dy = rnd(128), -8, 0, rnd(2)+1
            elseif direction == 1 then
                e.x, e.y, e.dx, e.dy = rnd(128), 136, 0, -(rnd(2)+1)
            elseif direction == 2 then
                e.x, e.y, e.dx, e.dy = -8, rnd(128), rnd(2)+1, 0
            else
                e.x, e.y, e.dx, e.dy = 136, rnd(128), -(rnd(2)+1), 0
            end
        end
        
        if check_collision(player, e) then
            state = "gameover"
        end
    end
end


function draw_enemies()
    for e in all(enemies) do
    
        spr(e.sprite, e.x, e.y)
    end
end


function check_collision(a, b)
    
    return a.x < b.x+8 and a.x+16 > b.x and a.y < b.y+8 and a.y+16 > b.y
end


function print_centered(text, x, y, col)
    
    local w = #text * 4
    print(text, x - w / 2, y, col)
end

-- 在玩家位置生成粒子
function generate_player_particles()
    for i=1,10 do -- 每次生成10个粒子
        local angle = rnd(1) * 2 * 3.14159 -- 随机角度
        local speed = rnd(1) + 0.5 -- 随机速度
        add(particles, {
            x = player.x + 8, -- 粒子初始x坐标
            y = player.y + 8, -- 粒子初始y坐标
            dx = cos(angle) * speed, -- 粒子x方向速度
            dy = sin(angle) * speed, -- 粒子y方向速度
            life = rnd(30) + 30 -- 粒子生命时长
        })
    end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ee00ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeefe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeefe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeefee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088800008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888880088888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888e88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888ee8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888ee8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888e88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088888888e888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00 0001000100010001 0000000000000000 0
01 0010001000100010 0000000000000000 0
02 0100010001000100 0000000000000000 0
03 1000100010001000 0000000000000000 0

__music__
00 0 1 2 3
