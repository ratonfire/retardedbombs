AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName=""

ENT.Spawnable=false
ENT.AdminSpawnable=false

ENT.Model="models/props_junk/watermelon01_chunk02c.mdl"

function ENT:Initialize()
	if (SERVER) then 
		self:SetModel(self.Model)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_NONE)
	end
end
function ENT:SpawnPhosphorus()
	for i=0,30,1 do
		local phos=ents.Create("white_phosphorus")
		phos:SetPos(self:GetPos()+Vector(0,0,50))
		phos:Spawn()
		phos:Activate()
		local phys=phos:GetPhysicsObject()
		phys:AddVelocity(VectorRand()*phys:GetMass()*math.random(50,60))
	end
	self:Remove()
end
function ENT:Think()
	if (SERVER) then
		self:SpawnPhosphorus()
	end
end
if (CLIENT) then
	function ENT:Draw()
		return false
	end
end