local function formulaFunction(level, maglevel)
	local min = (calculateBaseDamageHealing(level)) + (maglevel * 5.5)
	local max = (calculateBaseDamageHealing(level)) + (maglevel * 9)
	return -min, -max
end

-- One uniquely-named formula callback per grade Combat (Canary won't load the same callback name onto
-- two different Combat objects -> the duplicates silently lose their formula). All delegate to formulaFunction.
function onGetFormulaValuesGrade1(player, level, maglevel)
	return formulaFunction(level, maglevel)
end
function onGetFormulaValuesGrade2(player, level, maglevel)
	return formulaFunction(level, maglevel)
end
function onGetFormulaValuesGrade3(player, level, maglevel)
	return formulaFunction(level, maglevel)
end

-- Vocation Adjustment: Beam Mastery fires two identical beams parallel to the main one (left + right),
-- each dealing 40/60/80% of the beam damage at Beam Mastery stage 1/2/3.
local function flankFormula(player, level, maglevel)
	local stage = player:revelationStageWOD("Beam Mastery")
	local factor = (stage >= 3 and 0.80) or (stage >= 2 and 0.60) or (stage >= 1 and 0.40) or 0
	local min = ((calculateBaseDamageHealing(level)) + (maglevel * 5.5)) * factor
	local max = ((calculateBaseDamageHealing(level)) + (maglevel * 9)) * factor
	return -min, -max
end
function onGetFormulaValuesBeamFlank1(player, level, maglevel)
	return flankFormula(player, level, maglevel)
end
function onGetFormulaValuesBeamFlank2(player, level, maglevel)
	return flankFormula(player, level, maglevel)
end
function onGetFormulaValuesBeamFlank3(player, level, maglevel)
	return flankFormula(player, level, maglevel)
end

local BEAM_AREAS = {
	{
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 0, 3, 0 },
	},
	{
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 0, 3, 0 },
	},
	{
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 1, 1, 1 },
		{ 0, 3, 0 },
	},
}

local BEAM_CB = {
	"onGetFormulaValuesGrade1",
	"onGetFormulaValuesGrade2",
	"onGetFormulaValuesGrade3",
}

local function createCombat(area, combatFunc)
	local c = Combat()
	c:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, combatFunc)
	c:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
	c:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
	c:setArea(createCombatArea(area))
	return c
end

local combat = {}

for i = 1, 3 do
	combat[i] = createCombat(BEAM_AREAS[i], BEAM_CB[i])
end

local function applyStanceElement(player)
	local combatType, effect = COMBAT_DEATHDAMAGE, CONST_ME_MORTAREA
	local stance = player:getElementalStance()

	if stance == STANCE_MASTER_OF_FLAMES then
		combatType, effect = COMBAT_FIREDAMAGE, 334
	elseif stance == STANCE_MASTER_OF_THUNDER then
		combatType, effect = COMBAT_ENERGYDAMAGE, 335
	end

	for i = 1, 3 do
		combat[i]:setParameter(COMBAT_PARAM_TYPE, combatType)
		combat[i]:setParameter(COMBAT_PARAM_EFFECT, effect)
	end
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

	return combat[beamIndex]:execute(creature, var)
end
