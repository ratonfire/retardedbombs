AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName=""
ENT.Category=""

ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.SpecialScripts={}
ENT.SpecialScriptsOnUse={}

ENT.ClassName=""
ENT.Model=""
ENT.Effect=""
ENT.WaterEffect=""
ENT.ArmSound=""
ENT.ShockEffect=""
ENT.IgniteTime=0
ENT.ShouldExplodeOnImpact=false
ENT.ShouldIgniteInRadius=false
ENT.Timer=0
ENT.Timed=false

ENT.CanArm=false
ENT.Life=30
ENT.ExplosionDamage=0
ENT.ExplosionRadius=0
ENT.Mass=1

ENT.Owner=nil

function ENT:Initialize()
	util.PrecacheSound(self.ArmSound)
	self.Armed=false
	self.Exploded=false
	if (SERVER) then
		self:SetModel(self.Model)
	    self:PhysicsInit(SOLID_VPHYSICS)
	    self:SetMoveType(MOVETYPE_VPHYSICS)
	    self:SetSolid(SOLID_VPHYSICS)
	    local phys=self:GetPhysicsObject()
	    if phys:IsValid() then 
	    	phys:SetMass(self.Mass)
		    phys:Wake()
	    end
	end
end
function ENT:CallScriptsOnExp(arr)
	if table.IsEmpty(arr) then return end
	for k,v in ipairs(arr) do
		local ent=ents.Create(v)
		if !IsValid(ent) or !(SERVER) then return end
		ent:SetPos(self:GetPos())
		ent:Spawn()
		ent:Activate()
	end
end
function ENT:CallScriptsOnUse(arr)
	if table.IsEmpty(arr) then return end
	for k,v in ipairs(arr) do
		local ent=ents.Create(v)
		if !IsValid(ent) or !(SERVER) then return end
		ent:SetVar("CallerEntity",self)
		ent:SetPos(self:GetPos())
		ent:Spawn()
		ent:Activate()
	end
end
function ENT:Arm()
	if !self.Armed then
		self:EmitSound(self.ArmSound)
		self.Armed=true
		self:CallScriptsOnUse(self.SpecialScriptsOnUse)
		if self.Timed then
		timer.Simple(self.Timer,function()
			if self.Exploded or !IsValid(self) then return end
			self.Exploded=true
		    self:Explode(self)
		    if !self.ShouldIgniteInRadius then return end
		    self:SetOnFire()
		end)
		end
	end
end
function ENT:Use(ply)
	if !self.Armed and self.CanArm then
		self:Arm()
		self.Owner=ply
		return
	end
end
function ENT:Explode(attacker)
	local pos=self:GetPos()
	local shock=ents.Create("shockwave")
	local eff=EffectData()
	if self:WaterLevel()>=1 then
	    shock:SetVar("ShockRadius",self.ExplosionRadius*self.ExplosionRadius/(100*self:WaterLevel()))
	    shock:SetVar("ShockwaveEffect",self.ShockEffect)
	    shock:SetVar("ShockDamage",self.ExplosionDamage/(5*self:WaterLevel()))
	    self:SetVar("Effect",self.WaterEffect)
	    self:SetVar("ExplosionDamage",self.ExplosionDamage/(5*self:WaterLevel()))
	    self:SetVar("ExplosionRadius",self.ExplosionRadius/(5*self:WaterLevel()))
    else
    	shock:SetVar("ShockRadius",self.ExplosionRadius*self.ExplosionRadius/100)
	    shock:SetVar("ShockwaveEffect",self.ShockEffect)
	    shock:SetVar("ShockDamage",self.ExplosionDamage/20)
	end
	shock:SetPos(pos)
	shock:Spawn()
	shock:Activate()
	eff:SetOrigin(pos)
	eff:SetMagnitude(math.Clamp(self.ExplosionDamage,0,1023))
	eff:SetScale(self.ExplosionRadius/100)
	self:CallScriptsOnExp(self.SpecialScripts)
	util.BlastDamage(self,attacker,pos,self.ExplosionRadius,self.ExplosionDamage)
	util.Effect(self.Effect,eff,true,true)
	self:Remove()
end
function ENT:SetOnFire()
	for k,v in pairs(ents.FindInSphere(self:GetPos(),self.ExplosionRadius)) do
		if v:IsValid() then
			if v~=self then
				v:Ignite(self.IgniteTime+math.Clamp((self.ExplosionRadius-(self:GetPos()-v:GetPos()):Length())/100,1,10),1)
			end
		end
	end
end
function ENT:OnTakeDamage(dmg)
	self.Life=self.Life-dmg:GetDamage()
	if self.CanArm then
	    if self.Armed and !self.Exploded then
		    self.Exploded=true
		    self:Explode(dmg:GetAttacker())
		    if !self.ShouldIgniteInRadius then return end
		    self:SetOnFire()
		    return
	   end
	   if self.Life<=0 and !self.Armed and !self.Exploded then
		    self:Arm()
		    return
	   end
	end
    if !self.CanArm or self.Timed then
    	if self.Life<=0 and !self.Exploded then
    		self.Exploded=true
    		self:Explode(dmg:GetAttacker())
    		if !self.ShouldIgniteInRadius then return end
    		self:SetOnFire()
    		return
    	end
    end
end
function ENT:PhysicsCollide(info,collider)
	local damage=info.HitSpeed[3]/75
	self.Life=self.Life-damage
	if self.CanArm then
		if self.Armed and !self.Exploded and (self.Life<=0 or damage>3) and self.ShouldExplodeOnImpact then
			self.Exploded=true
			self:Explode(self.Owner)
			if !self.ShouldIgniteInRadius then return end
			self:SetOnFire()
			return
		end
		if !self.Armed and !self.Exploded and damage>10 and self.ShouldExplodeOnImpact then
			self:Arm()
			return
		end
	else
		if !self.Exploded and self.Life<=0 and self.ShouldExplodeOnImpact then
			self.Exploded=true
			self:Explode(self.Owner)
			if !self.ShouldIgniteInRadius then return end
			self:SetOnFire()
			return
		end
	end
end
function ENT:OnRemove()
	self:StopParticles()
end
if (CLIENT) then
	function ENT:Draw() 
		self:DrawModel()
	end
end
