AddCSLuaFile()

DEFINE_BASECLASS("rb_base")

ENT.PrintName="Fire Bomb"
ENT.Category="Retarded Bombs"

ENT.Spawnable=true
ENT.AdminSpawnable=true

ENT.ClassName="propane_tank"
ENT.Model="models/props_junk/plasticbucket001a.mdl"
ENT.Effect="Explosion"
ENT.WaterEffect="WaterSurfaceExplosion"
ENT.ArmSound="buttons/button14.wav"
ENT.ShockEffect="RPGShotDown"
ENT.SpecialScripts={}
ENT.SpecialScriptsOnUse={}
ENT.IgniteTime=15
ENT.ShouldExplodeOnImpact=true
ENT.ShouldIgniteInRadius=true
ENT.Timer=0
ENT.Timed=false

ENT.CanArm=false
ENT.Life=50
ENT.ExplosionDamage=55
ENT.ExplosionRadius=1500
ENT.Mass=25

ENT.Owner=nil

function ENT:SpawnFunction(ply,tr) 
	if(!tr.Hit) then return end
	self.Owner=ply
	local entity=ents.Create(self.ClassName)
	entity:SetPhysicsAttacker(ply)
	entity:SetPos(tr.HitPos+tr.HitNormal*25)
	entity:Spawn()
	entity:Activate()
	return entity
end