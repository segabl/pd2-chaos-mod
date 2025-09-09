ChaosModifierRubberBullets = ChaosModifier.class("ChaosModifierRubberBullets")
ChaosModifierRubberBullets.conflict_tags = { "BulletChange" }
ChaosModifierRubberBullets.loud_only = true
ChaosModifierRubberBullets.duration = 30

function ChaosModifierRubberBullets:start()
	local hurt_severity = setmetatable({}, {
		__index = function(t, k)
			if k == "fire" or k == "poison" then
				return {
					health_reference = "full",
					zones = {
						{
							none = 1
						}
					}
				}
			else
				return {
					health_reference = "full",
					zones = {
						{
							moderate = 0.8,
							heavy = 0.15,
							explode = 0.05
						}
					}
				}
			end
		end
	})

	for _, entry in pairs(tweak_data.character) do
		if type(entry) == "table" and type(entry.damage) == "table" then
			self:override(entry.damage, "hurt_severity", hurt_severity)
		end
	end

	self:post_hook(CopDamage, "_apply_damage_reduction", function() return Hooks:GetReturn() * 0.001 end)
	self:pre_hook(TeamAIDamage, "_apply_damage", function(_, attack_data) attack_data.damage = attack_data.damage * 0.001 end)
	self:pre_hook(PlayerDamage, "_calc_armor_damage", function(_, attack_data) attack_data.damage = attack_data.damage * 0.001 end)

	self:override(PlayerCamera, "play_shaker", function(cam, effect, amplitude, ...)
		if effect == "player_bullet_damage" then
			effect = table.random({ "melee_hit", "melee_hit_var2" })
			amplitude = amplitude * 0.35
		end
		return self:get_override(PlayerCamera, "play_shaker")(cam, effect, amplitude, ...)
	end)
end

return ChaosModifierRubberBullets
