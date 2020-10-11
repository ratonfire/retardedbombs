AddCSLuaFile()

DEFINE_BASECLASS("rb_base")

ENT.PrintName="Blackhole  Bomb"
ENT.Category="Retarded Bombs"

ENT.Spawnable=true
ENT.AdminSpawnable=true

ENT.ClassName="blackhole_bomb"
ENT.Model="models/props_c17/canister_propane01a.mdl"
ENT.Effect=""
ENT.WaterEffect=""
ENT.ArmSound="buttons/button14.wav"
ENT.ShockEffect="RPGShotDown"
ENT.SpecialScripts={"blackhole_ent"}
ENT.SpecialScriptsOnUse={}
ENT.ShouldExplodeOnImpact=true
ENT.ShouldIgniteInRadius=false

ENT.CanArm=true
ENT.Life=50
ENT.ExplosionDamage=0
ENT.ExplosionRadius=10000
ENT.Mass=200

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