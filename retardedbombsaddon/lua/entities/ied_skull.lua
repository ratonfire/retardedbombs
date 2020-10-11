AddCSLuaFile()

DEFINE_BASECLASS("rb_base")

ENT.PrintName="IED Skull"
ENT.Category="Retarded Bombs"

ENT.Spawnable=true
ENT.AdminSpawnable=true

ENT.ClassName="propane_tank"
ENT.Model="models/Gibs/HGIBS.mdl"
ENT.Effect="Explosion"
ENT.WaterEffect="WaterSurfaceExplosion"
ENT.ArmSound="ied.wav"
ENT.ShockEffect="RPGShotDown"
ENT.SpecialScripts={}
ENT.SpecialScriptsOnUse={}
ENT.IgniteTime=0
ENT.ShouldExplodeOnImpact=true
ENT.ShouldIgniteInRadius=false
ENT.Timer=4.5
ENT.Timed=true

ENT.CanArm=true
ENT.Life=15
ENT.ExplosionDamage=150
ENT.ExplosionRadius=600
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