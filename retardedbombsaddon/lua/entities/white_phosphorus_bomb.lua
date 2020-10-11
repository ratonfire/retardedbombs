AddCSLuaFile()

DEFINE_BASECLASS("rb_base")

ENT.PrintName="White Phosphorus Bomb"
ENT.Category="Retarded Bombs"

ENT.Spawnable=true
ENT.AdminSpawnable=true

ENT.ClassName="white_phosphorus_bomb"
ENT.Model="models/props_phx/ww2bomb.mdl"
ENT.Effect="HelicopterMegaBomb"
ENT.WaterEffect=""
ENT.ArmSound="buttons/button14.wav"
ENT.ShockEffect="RPGShotDown"
ENT.SpecialScripts={"w_p_bomb_script"}
ENT.SpecialScriptsOnUse={}
ENT.ShouldExplodeOnImpact=true
ENT.ShouldIgniteInRadius=true

ENT.CanArm=true
ENT.Life=50
ENT.ExplosionDamage=50
ENT.ExplosionRadius=400
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