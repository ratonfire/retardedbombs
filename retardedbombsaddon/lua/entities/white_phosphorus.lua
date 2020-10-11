AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Class="white_phosphorus"
ENT.Model="models/props_junk/watermelon01_chunk02c.mdl"
ENT.Mass=3

ENT.PrintName="White Phosphorus"

ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.BurnTime=20

function ENT:Initialize()
	self.v=nil
	self.reacted=false
	self.TouchedWater=false
	self.hPos=nil
	self.parented=false
	self.PoisonedTable={}
	self.BannedTable={"white_phosphorus","white_phosphorus_bomb","w_p_bomb_script","trigger_teleport","shockwave","blackhole_ent","entityflame","env_spritetrail"}
	self.WhiteTable={"prop_physics","player"}
	if(SERVER) then
		self:SetModel(self.Model)
		self:SetColor(Color(255,255,255))
		self:SetMaterial("models/debug/debugwhite")
	    self:PhysicsInit(SOLID_VPHYSICS)
	    self:SetMoveType(MOVETYPE_VPHYSICS)
	    self:SetSolid(SOLID_VPHYSICS)
	    local phys=self:GetPhysicsObject()
	    if phys:IsValid() then 
	    	phys:SetMass(self.Mass)
		    phys:Wake()
	    end
	    timer.Simple(20,function()
	    	if IsValid(self) then
	    	self:Remove()
	    end
	    end)
	    if self:WaterLevel()<3 then
	    	timer.Simple(0.5,function()
	    		if !IsValid(self) then return end
	    		self:Ignite(self.BurnTime,100)
	    	    util.SpriteTrail( self, 0, Color( 255, 255, 255 ), false, 1, 10, 3, 1 / ( 1 + 3 ) * 0.5, "trails/smoke" )
	    	    self.reacted=true
	    	end)
	    else
	    	self.TouchedWater=true
	    end
	end
end
function ENT:Reaction()
	if self:WaterLevel()>2 and self.reacted and !self.TouchedWater then
		self.TouchedWater=true
		timer.Simple(3,function()
			if !IsValid(self) then return end
			self:Extinguish()
			self.reacted=false
			return
		end)
	end
	if self:WaterLevel()<3  and !self.reacted and self.TouchedWater then
		self.TouchedWater=false
		timer.Simple(3,function()
			if !IsValid(self) then return end
			self:Ignite(self.BurnTime,100)
			self.reacted=true
		end)
	end
end
function ENT:StickToDeath(v)
	if !IsValid(self) and !self.reacted then return end
	if !self.parented and IsValid(v) then 
		self:SetCollisionGroup(COLLISION_GROUP_WORLD)
		self:SetParent(v)
		self.parented=true
	end
	if self.parented and !IsValid(v) then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self.parented=false
		self:SetParent()
	end
	if IsValid(v) and v:IsPlayer() then
		if !table.HasValue(self.PoisonedTable,v) then table.insert(self.PoisonedTable,v) end
		if !v:Alive() then
			self.v=nil
		end
	end
end
function ENT:StickMoreShit()
	for k,v in pairs(ents.FindInSphere(self:GetPos(),150)) do
		if !table.HasValue(self.BannedTable,v:GetClass()) and IsValid(v) and table.HasValue(self.WhiteTable,v:GetClass()) or v:IsNPC() then
			if (v:IsPlayer() or v:IsNPC()) and !table.HasValue(self.PoisonedTable,v) and v:Health()>0 then
				table.insert(self.PoisonedTable,v)
			end
		end
	end
end
function ENT:PoisonSomeShit()
	if table.IsEmpty(self.PoisonedTable) then return end
	for k,v in pairs(self.PoisonedTable) do
		if IsValid(v) and v:Health()>0 then
		v:TakeDamage(v:Health()*0.2,self,self)
	end
	end
end
function ENT:PhysicsCollide(info)
	if IsValid(info.HitEntity) and !self.parented and !IsValid(self.v) then
		if table.HasValue(self.BannedTable,info.HitEntity:GetClass()) then return end
		self.v=info.HitEntity
	end
end
function ENT:Think()
	if (SERVER) then
		self:Reaction()
		self:StickToDeath(self.v)
		self:PoisonSomeShit()
		self:StickMoreShit()
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
