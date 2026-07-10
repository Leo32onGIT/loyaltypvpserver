local MAIN_AREAS = {
	AREA_BEAM6,
	AREA_BEAM7,
	AREA_BEAM8
}

local FLANK_AREAS = {
	{
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 3, 1 },
	},
	{
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 3, 1 },
	},
	{
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 0, 1 },
		{ 1, 3, 1 },
	},
}

local function getBeamDamage(level, maglevel)
	local min = calculateBaseDamageHealing(level) + (maglevel * 5.5)
	local max = calculateBaseDamageHealing(level) + (maglevel * 9)
	return min, max
end


-- Main beam: 100%
function onGetFormulaValuesGreatDeathBeam(player, level, maglevel)
	local min, max = getBeamDamage(level, maglevel)
	return -min, -max
end


-- Flank beams: 40/60/80%
function onGetFormulaValuesGreatDeathBeamFlank(player, level, maglevel)
	local stage = player:revelationStageWOD("Beam Mastery")

	local factor = 0

	if stage >= 3 then
		factor = 0.80
	elseif stage >= 2 then
		factor = 0.60
	elseif stage >= 1 then
		factor = 0.40
	end

	local min, max = getBeamDamage(level, maglevel)

	return -(min * factor), -(max * factor)
end


local beamCombat = Combat()
beamCombat:setCallback(
	CALLBACK_PARAM_LEVELMAGICVALUE,
	"onGetFormulaValuesGreatDeathBeam"
)
beamCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
beamCombat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)


local flankCombat = Combat()
flankCombat:setCallback(
	CALLBACK_PARAM_LEVELMAGICVALUE,
	"onGetFormulaValuesGreatDeathBeamFlank"
)
flankCombat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
flankCombat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)


local function applyStanceElement(player)
	local combatType = COMBAT_DEATHDAMAGE
	local effect = CONST_ME_MORTAREA

	local stance = player:getElementalStance()

	if stance == STANCE_MASTER_OF_FLAMES then
		combatType = COMBAT_FIREDAMAGE
		effect = 334

	elseif stance == STANCE_MASTER_OF_THUNDER then
		combatType = COMBAT_ENERGYDAMAGE
		effect = 335
	end

	beamCombat:setParameter(COMBAT_PARAM_TYPE, combatType)
	beamCombat:setParameter(COMBAT_PARAM_EFFECT, effect)

	flankCombat:setParameter(COMBAT_PARAM_TYPE, combatType)
	flankCombat:setParameter(COMBAT_PARAM_EFFECT, effect)
end


local spell = Spell("instant")


function spell.onCastSpell(creature, var)
	if not creature or not creature:isPlayer() then
		return false
	end

	local player = creature:getPlayer()

	applyStanceElement(player)

	local grade = creature:upgradeSpellsWOD("Great Death Beam")
	local beamIndex = (grade == WHEEL_GRADE_NONE) and 1 or grade

	beamCombat:setArea(createCombatArea(MAIN_AREAS[beamIndex]))
	flankCombat:setArea(createCombatArea(FLANK_AREAS[beamIndex]))


	local result = beamCombat:execute(creature, var)

	if creature:revelationStageWOD("Beam Mastery") > 0 then
		flankCombat:execute(creature, var)
	end

	return result
end


spell:group("attack", "greatbeams")
spell:id(260)
spell:name("Great Death Beam")
spell:words("exevo max mort")
spell:level(66)
spell:mana(140)
spell:basePower(170)
spell:isPremium(false)
spell:needDirection(true)
spell:blockWalls(true)
spell:cooldown(10 * 1000)
spell:groupCooldown(2 * 1000, 6 * 1000)
spell:needLearn(false)
spell:vocation("sorcerer;true", "master sorcerer;true")
spell:register()
