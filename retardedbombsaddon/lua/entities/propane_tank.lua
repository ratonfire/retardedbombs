AddCSLuaFile()

DEFINE_BASECLASS("rb_base")

ENT.PrintName="Propane Tank"
ENT.Category="Retarded Bombs"

ENT.Spawnable=true
ENT.AdminSpawnable=true

ENT.ClassName="propane_tank"
ENT.Model="models/props_c17/canister_propane01a.mdl"
ENT.Effect="Explosion"
ENT.WaterEffect="WaterSurfaceExplosion"
ENT.ArmSound="buttons/button14.wav"
ENT.ShockEffect="RPGShotDown"
ENT.SpecialScripts={}
ENT.SpecialScriptsOnUse={}
ENT.ShouldExplodeOnImpact=true
ENT.ShouldIgniteInRadius=true

ENT.CanArm=false
ENT.Life=50
ENT.ExplosionDamage=350
ENT.ExplosionRadius=400
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