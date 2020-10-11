AddCSLuaFile()

DEFINE_BASECLASS("base_anim") 

ENT.PrintName="Blackhole"
ENT.Spawnable=false
ENT.AdminSpawnable=false
ENT.Model="models/props_junk/watermelon01_chunk02a.mdl"

ENT.ActiveTime=10
ENT.EventHorizonDamage=5000
ENT.BlackholePullRadius=5000
ENT.EventHorizonRadius=500
ENT.Sounds={"vo/npc/male01/help01.wav","vo/npc/male01/goodgod.wav","vo/npc/male01/ohno.wav"}
function ENT:Initialize()
	self.ShouldStop=false
	self.ShouldRagdoll=true
	self.ragdolled=false
	self.x=0
	self.RagdolledPlayerTable={}
	self.KillRadius=self.EventHorizonRadius/1.2
	if(SERVER) then
		self:SetModel(self.Model)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_NONE)
	timer.Simple(self.ActiveTime-0.2,function()
		self.ShouldRagdoll=false
	end)
	timer.Simple(self.ActiveTime,function()
		self.ShouldStop=true
	end)
end
end
function ENT:KillInRadius(v)
	if self.ShouldRagdoll then return end
	local dist=self:GetPos():DistToSqr(v:GetPos())
	if dist<self.KillRadius*self.KillRadius then
		v:EmitSound("vo/npc/male01/moan01.wav")
		v:TakeDamage(self.EventHorizonDamage,self,self)
	end

end
function ENT:TurnToRagdoll(v,ShouldTurn)
		if ShouldTurn and v:IsPlayer() and v:Alive() then
		if !IsValid(v.doll) then	
		v.doll=ents.Create("prop_ragdoll")
		v.doll:SetModel(v:GetModel())
		v.doll:SetPos(v:GetPos())
		v.doll:SetAngles(v:GetAngles())
		v.doll:Spawn()
		v.doll:Activate()
		v:EmitSound(self.Sounds[math.random(1,3)])
	    end
	    if IsValid(v.doll) then
	        v:DrawViewModel(false)
	        v:StripWeapons()
	        v:Freeze(true)
	        v:Spectate(OBS_MODE_CHASE)
	        v:SpectateEntity(v.doll)
	        v:SetParent(v.doll)
	        self.ragdolled=true
	        self.RagdolledPlayerTable[v]=v.doll
	    end
	    end--ShouldTurn end
	    if !ShouldTurn and self.ragdolled and v:Alive() then
	    	if IsValid(v.doll) then
	    		v.pos=v.doll:GetPos()
	    		v.doll:Remove()
	    	else
	    		v.pos=self:GetPos()
	    	end
	    	self.RagdolledPlayerTable[v]=nil
	    	v:DrawViewModel(true)
	    	v:SetParent()
	    	v:Freeze(false)
	    	v:Spawn()
	    	v:SetPos(v.pos)
	    end
end
function ENT:ApplyGravity(v)
	local pos=self:GetPos()
	local vPos=v:GetPos()
	for i=0,v:GetPhysicsObjectCount()-1 do
		local phys=v:GetPhysicsObjectNum(i)
		if IsValid(phys) then
			local vec=((pos-vPos)+Vector(self.EventHorizonRadius*math.cos(self.x/4),self.EventHorizonRadius*math.sin(self.x/4),0))*50
			if v:IsPlayer() then
				phys:SetVelocity(vec)						
			else
				if self.ShouldRagdoll then
				    phys:AddVelocity(vec)
				else
					phys:AddVelocity(VectorRand()*math.random(100,200)*phys:GetMass())
				end
			end
		end
		self.x=self.x+1
	end
end
function ENT:FindStuffDoShit()
	for k,v in pairs(ents.FindInSphere(self:GetPos(),self.BlackholePullRadius)) do
		if v:IsPlayer() then
		self:TurnToRagdoll(v,self.ShouldRagdoll)
		self:KillInRadius(v)
	    end
		self:ApplyGravity(v)
	end
end
function ENT:Think()
	if (SERVER) then
	if !self.ShouldStop then
		self:FindStuffDoShit()
	else
		self:Remove()
		return
	end
end
end
function ENT:OnRemove()
	if(SERVER) then
		if  table.IsEmpty(self.RagdolledPlayerTable) then return end
		for k,v in pairs(self.RagdolledPlayerTable) do
			if IsValid(v) and k:Alive() then
				k:DrawViewModel(true)
				k:SetParent()
				k:Freeze(false)
				k:Spawn()
				k:SetPos(v:GetPos())
				self.RagdolledPlayerTable[k]=nil
			end
		end
	end
end
if(CLIENT) then
	function ENT:Draw()
		return false
	end
end