
include("shared.lua")

function ENT:Calibration()

--[[ 	These codes below help you to calibrate the barrel.
  Forward direction is where the x axis aims in local.
  You should use local coordinates to adjust the attachment position too. ]]

  local td = {}
    td.start = self.Entity:GetAttachment(1).Pos
    td.endpos = self.Entity:GetAttachment(1).Pos + self.Entity:GetAttachment(1).Ang:Forward() * 10000
    td.filter = { self.Entity }
  local tr = util.TraceLine(td)

  render.SetMaterial(Material("cable/redlaser"))
  render.DrawBeam(self.Entity:GetAttachment(1).Pos, tr.HitPos, 10, 0, 1, Color(255, 255, 255, 255))

  local self_ang = self.Entity:GetAngles()
  self_ang:RotateAroundAxis(self_ang:Up(), (self.Entity:GetAttachment(1).Ang.y - self.Entity:GetAngles().y))

  local td2 = {}
    td2.start = self.Entity:GetPos()
    td2.endpos = self.Entity:GetPos() + self_ang:Forward() * 10000
    td2.filter = { self.Entity }
  local tr2 = util.TraceLine(td2)

  render.SetMaterial(Material("cable/redlaser"))
  render.DrawBeam(td2.start, tr2.HitPos, 10, 0, 1, Color(255, 255, 255, 255))

end
