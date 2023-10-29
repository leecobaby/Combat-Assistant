-- 为 AnimState 添加一些新的方法，还有一些问题，暂时不用
local NewAnimState = {}

function NewAnimState:IsAnim(anim) return self.AnimState and self.AnimState:IsCurrentAnimation(anim) end

function NewAnimState:IsAnimsOf(anims)
  if type(anims) == "table" then
    for _, anim in ipairs(anims) do
      if self:IsAnim(anim) then
        return true
      end
    end
  else
    return false
  end
end

return NewAnimState
