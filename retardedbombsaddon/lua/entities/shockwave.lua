AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName="Shockwave"

ENT.Spawnable=false
ENT.AdminSpawnable=false

ENT.Model="models/props_junk/watermelon01_chunk02c.mdl"

ENT.ShockwaveEffect=""

ENT.ShockRadius=0
ENT.ShockDamage=0
function ENT:Initialize()
	self.ShouldStop=false
	self.exploded=false
	if (SERVER) then
		self:SetModel(self.Model)
	    self:PhysicsInit(SOLID_NONE)
	    self:SetMoveType(MOVETYPE_NONE)
	    self:SetSolid(SOLID_NONE)
	    self:SetUseType(ONOFF_USE)
	    timer.Simple(1,function()
	    	self.ShouldStop=true
	    end)
	end
end
function ENT:ChangePhys(v)
	if v:IsValid() then
		for i=0,v:GetPhysicsObjectCount()-1 do
			local phys=v:GetPhysicsObjectNum(i)
			if phys:IsValid() then
				phys:Wake()
				phys:EnableMotion(true)
				constraint.RemoveAll(v)
				self:Throw(phys,self:GetPos(),v:GetPos())
			end
		end
	end
end
function ENT:Throw(phys,origin,physPos)
	local vec=(physPos-origin)*math.Clamp(self.ShockRadius/(origin-physPos):Length(),0,self.ShockDamage)/phys:GetMass()
	phys:AddVelocity(vec)
end
function ENT:DoEffect()
	for k,v in pairs(ents.FindInSphere(self:GetPos(),self.ShockRadius/1.5)) do
			self:ChangePhys(v)
	end
end
function ENT:DoShockwaveDamage()
	if self.exploded then return end
	local eff=EffectData()
	eff:SetOrigin(self:GetPos())
	eff:SetScale(self.ShockRadius/20)
	eff:SetMagnitude(math.Clamp(self.ShockDamage,0,1023))
	util.Effect(self.ShockwaveEffect,eff,true,true)
	util.BlastDamage(self,self,self:GetPos(),self.ShockRadius,self.ShockDamage)
	self.exploded=true
end
function ENT:Think() 
	if !self.ShouldStop then
		self:DoEffect()
		self:DoShockwaveDamage()
	else 
		self:Remove()
		return
	end
end
if (CLIENT) then
	function ENT:Draw() 
		return false
	end
end