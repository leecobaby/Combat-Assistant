require "utils/main"
GLOBAL.setmetatable(env, {__index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end})
Assets = {Asset("SOUNDPACKAGE", "sound/tips.fev"), Asset("SOUND", "sound/tips.fsb")}

local _G = GLOBAL
local require = _G.require
local SendRPCToServer = _G.SendRPCToServer
local RPC = _G.RPC
local ACTIONS = _G.ACTIONS
local TUNING = _G.TUNING
local Player = _G.ThePlayer

local FRAMES_UP = 11
local boss = "mutatedbearger"
local search_range = 20
local cache = {butt_pst = false}

local function DoAttackBearger(player, target)
  if player ~= nil and player:IsValid() and target ~= nil and target:IsValid() then
    local item = GetItemFromAll("staff_lunarplant")
    if item then
      -- 切换到亮茄法杖
      -- 此处客户端缺乏动作，但出奇的块
      SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, ACTIONS.EQUIP.code, item)

      -- 发送攻击动作 后期优化玩家移动操作的干扰
      SendRPCToServer(RPC.AttackButton, target, false, true)
      SendRPCToServer(RPC.AttackButton, target, false, true)
      SendRPCToServer(RPC.AttackButton, target, false, true)
      cache.butt_pst = false
      print("[DoAttackBearger]: SendRPCToServer")
      -- SendRPCToServer(RPC.AttackButton, target, false, true)
      -- inst:DoTaskInTime(0.2, function()
      --   SendRPCToServer(RPC.AttackButton, target, false, true)
      --   inst:DoTaskInTime(0.2, function() SendRPCToServer(RPC.AttackButton, target, false, true) end)
      -- end)

    end

  end
end

-- client 没有 sg，所以不能判断熊獾是否处于脆弱状态，只能判断动画状态，此函数暂时作废
-- local function OnMutatedBeargerVulnerable(inst)
-- if inst.sg.statemem.vulnerable then
--   local player = ThePlayer
--   local target = inst
--   DoAttackBearger(player, target)
-- end
-- end
print("========战斗助手========")

AddPrefabPostInit(boss, function(inst)
  print('============Start============')
  if inst == nil or not inst.AnimState then
    return
  end

  local player = ThePlayer
  local target = inst
  inst.SoundEmitter:PlaySound("tips/brief/8bit recovery 2")

  inst:DoPeriodicTask(GLOBAL.FRAMES * 10, function()
    if FindRecentEnt(boss, search_range, nil, nil, nil) then
      if IsAnims("butt_pst", inst) and not cache['butt_pst'] then
        print("[AinmState]: butt_pst")
        cache.butt_pst = true
        inst.SoundEmitter:PlaySound("tips/brief/8bit recovery 2")

        inst:DoTaskInTime(0.1, function() DoAttackBearger(player, target) end)
      end

      -- 做是坐下起始动作，动画帧数短暂，有可能监听不到，并且如果直接执行攻击，可能会干扰躲避操作，后期可优化再考虑。
      -- if IsAnim("butt", inst) then
      --   print("[AinmState]: butt")
      --   inst.SoundEmitter:PlaySound("tips/brief/8bit recovery 2")

      --   inst:DoTaskInTime(0.1, function() DoAttackBearger(player, target) end)
      -- end
    end

  end)
  -- local AnimState = inst.AnimState
  -- 给动画状态机添加新方法
  -- inst.AnimState = setmetatable(AnimState, NewAnimState)

end)

