-- 判断是否是指定动画
function IsAnim(anim, inst) return inst.AnimState and inst.AnimState:IsCurrentAnimation(anim) end

-- 判断是否有指定动画，支持单个或多个动画
function IsAnims(anims, inst)
  if type(anims) == "table" then
    for _, anim in ipairs(anims) do
      if IsAnim(anim, inst) then
        return true
      end
    end
  else
    if type(anims) == "string" then
      return IsAnim(anims, inst)
    end
  end
end

-- 获取所有物品（未指定prefab则获取全部）
function GetItemsFromAll(prefab, alltags)
  local items = {}
  local initems = ThePlayer and ThePlayer.replica.inventory:GetItems() or {}
  local equipitems = ThePlayer and ThePlayer.replica.inventory:GetEquips() or {}
  local containeritems = GetItemsFromOpenContainer() or {}
  for _, ent in pairs(mergeTable(containeritems, equipitems, initems)) do
    if ((prefab == ent.prefab)
    or ((type(prefab) == "table" and table.contains(prefab, ent.prefab)) or (type(prefab) == "nil"))) then
      local allflag = true
      if type(alltags) == "table" then
        allflag = ent:HasTags(alltags)
      elseif type(alltags) == "string" then
        allflag = ent:HasTag(alltags)
      end
      if allflag then
        table.insert(items, ent)
      end
    end
  end
  return items
end

-- 获取所有容器的单个物品
function GetItemFromAll(prefab, alltags, func)
  local prefabs = GetItemsFromAll(prefab, alltags)
  for _, v in pairs(prefabs) do
    if not func or func(v) then
      return v
    end
  end
end

-- 获取装备物品
function GetEquippedItemFrom(slot)
  return ThePlayer and ThePlayer.replica.inventory and ThePlayer.replica.inventory:GetEquippedItem(slot)
end

-- 获取容器内的物品
function GetItemsFromOpenContainer()
  local items = {}
  if not ThePlayer or not ThePlayer.replica.inventory then
    return items
  end

  local lastitems = {}
  for container, v in pairs(ThePlayer.replica.inventory:GetOpenContainers()) do
    if container and container.replica and container.replica.container then
      local items_container = container.replica.container:GetItems()
      if container:HasTag("INLIMBO") then
        lastitems = mergeTable(lastitems, items_container)
      else
        items = mergeTable(items, items_container)
      end
    end
  end
  return mergeTable(items, lastitems)
end

-- 返回value集合但什么都不查
function mergeTable(...)
  local mTable = {}
  for _, v in pairs({...}) do
    if type(v) == "table" then
      for _, k in pairs(v) do
        table.insert(mTable, k)
      end
    end
  end
  return mTable
end

function IsEmpty(t)
  if t == nil or (type(t) == "table" and #t == 0) then
    return true
  end
  return false
end

-- 查找玩家附近的实体
function FindRecentEnt(name, range, tags, exclude_tags, allowAnims, banAnims, isInValidPos, func)
  if not range then
    range = 80
  end
  if type(tags) ~= "table" then
    tags = nil
  end
  if type(exclude_tags) ~= "table" then
    exclude_tags = {'FX', 'DECOR', 'INLIMBO', 'NOCLICK', 'player'}
  end
  if type(banAnims) == "nil" then
    banAnims = {"death"}
  end
  local neardist = 6400
  local pos = ThePlayer:GetPosition()
  local ents = TheSim:FindEntities(pos.x, 0, pos.z, range, tags, exclude_tags)
  local nearent
  for _, ent in pairs(ents) do
    if ((type(name) == "table" and table.contains(name, ent.prefab)) or (name == ent.prefab) or (type(name) == "nil"))
    and ((allowAnims and IsAnims(allowAnims, ent)) or (not allowAnims)) and (banAnims and not IsAnims(banAnims, ent))
    and (isInValidPos and IsInValidPos(ent) or (not isInValidPos)) and ((not func) or func(ent)) then
      local dist = ent:GetPosition():DistSq(pos)
      if dist and dist < neardist then
        neardist = dist
        nearent = ent
      end
    end
  end
  return nearent
end

-- 有效位置
function IsInValidPos(ent)
  return (not TheWorld:HasTag("cave") and (ent:IsOnValidGround() or not ent:IsOnOcean(false)))
         or (TheWorld:HasTag("cave") and ent:IsOnValidGround())
end
