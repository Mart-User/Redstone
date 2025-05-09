#if defined _smlib_math_included
	#endinput
#endif
#define _smlib_math_included

#include <sourcemod>

#define SIZE_OF_INT		2147483647		// without 0

#define GAMEUNITS_TO_METERS	0.01905
#define METERS_TO_GAMEUNITS	52.49343832020997
#define METERS_TO_FEET		3.2808399
#define FEET_TO_METERS		0.3048

enum VecAngle
{
	ANG_ALPHA,
	ANG_BETA,
	ANG_GAMMA
}

stock int RoundToMult(int value, int mult) {
	return (value + mult -1) / mult * mult;
}

stock float RoundToMultEx(int value, int mult) {
	return float(value + mult -1) / float(mult) * float(mult);
}

/**
 * Makes a negative integer number to a positive integer number.
 *
 * @param number		A number that can be positive or negative.
 * @return				Positive number.
 */
stock any:Math_Abs(any:number) {	
	return number >= 0 ? number : (number * -1);
}

/**
 * Checks if 2 vectors are equal.
 * You can specfiy a tolerance.
 *
 * @param vec1			First vector (3 dim array)
 * @param vec2			Second vector (3 dim array)
 * @param tolerance 	If you want to check that those vectors are somewhat even. 0.0 means they are 100% even if this function returns true.
 * @return				True if vectors are equal, false otherwise.
 */
stock bool:Math_VectorsEqual(Float:vec1[3], Float:vec2[3], Float:tolerance=0.0) {	
	return GetVectorDistance(vec1, vec2) <= tolerance;
}

/**
 * Sets the given value to min
 * if the value is smaller than the given.
 * 
 * @param value			Value
 * @param min			Min Value used as lower border
 * @return				Correct value not lower than min
 */
stock any:Math_Min(any:value, any:min) {
	return value < min ? min : value;
}

/**
 * Sets the given value to max
 * if the value is greater than the given.
 * 
 * @param value			Value
 * @param max			Max Value used as upper border
 * @return				Correct value not upper than max
 */
stock any:Math_Max(any:value, any:max) {	
	return value > max ? max : value;
}

/**
 * Makes sure a value is within a certain range and
 * returns the value.
 * If the value is outside the range it is set to either
 * min or max, if it is inside the range it will just return
 * the specified value.
 * 
 * @param value			Value
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Correct value not lower than min and not greater than max.
 */
stock any:Math_Clamp(any:value, any:min, any:max)
{
	value = Math_Min(value, min);
	value = Math_Max(value, max);

	return value;
}

/* 
 * Checks if the value is within the given bounds (min & max).
 * 
 * @param value		The value you want to check.
 * @param min		The lower border.
 * @param max		The upper border.
 * @return			True if the value is within bounds (bigger or equal min / smaller or equal max), false otherwise.
 */
stock bool:Math_IsInBounds(any:value, any:min, any:max) {
	return !(value < min || value > max);
}

/**
 * Let's the specified value "overflow" if it is outside the given limit.
 * This is like with integers when it reaches a value above the max possible
 * integer size.
 * 
 * @param value			Value
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Overflowed number
 */
stock any:Math_Overflow(any:value, any:min, any:max)
{
	return (value % max) + min;
}

/**
 * Returns a random, uniform Integer number in the specified (inclusive) range.
 * This is safe to use multiple times in a function.
 * The seed is set automatically for each plugin.
 * Rewritten by MatthiasVance, thanks.
 * 
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Random Integer number between min and max
 */
stock Math_GetRandomInt(min, max)
{
	new random = GetURandomInt();
	
	if (random == 0) {
		random++;
	}

	return RoundToCeil(float(random) / (float(SIZE_OF_INT) / float(max - min + 1))) + min - 1;
}

/**
 * Returns a random, uniform Float number in the specified (inclusive) range.
 * This is safe to use multiple times in a function.
 * The seed is set automatically for each plugin.
 * 
 * @param min			Min value used as lower border
 * @param max			Max value used as upper border
 * @return				Random Float number between min and max
 */
stock Float:Math_GetRandomFloat(Float:min, Float:max)
{
	return (GetURandomFloat() * (max  - min)) + min;
}

/**
 * Gets the percentage of amount in all as Integer where
 * amount and all are numbers and amount usually
 * is a subset of all.
 * 
 * @param value			Integer value
 * @param all			Integer value
 * @return				An Integer value between 0 and 100 (inclusive).
 */
stock Math_GetPercentage(value, all) {
	return RoundToNearest((float(value) / float(all)) * 100.0);
}

/**
 * Gets the percentage of amount in all as Float where
 * amount and all are numbers and amount usually
 * is a subset of all.
 * 
 * @param value			Float value
 * @param all			Float value
 * @return				A Float value between 0.0 and 100.0 (inclusive).
 */
stock Float:Math_GetPercentageFloat(Float:value, Float:all) {
	return (value / all) * 100.0;
}

/*
 * Moves the start vector on a direct line to the end vector by the given scale.
 * Note: If scale is 0.0 the output will be the same as the start vector and if scale is 1.0 the output vector will be the same as the end vector.
 * Exmaple usage: Move an entity to another entity but only 12 units: Vector_MoveVector(entity1Origin,entity2Origin,(12.0 / GetVectorDistance(entity1Origin,entity2Origin)),newEntity1Origin); now only teleport your entity to newEntity1Origin.
 *
 * @param start			The start vector where the imagined line starts.
 * @param end			The end vector where the imagined line ends.
 * @param scale			The position on the line 0.0 is the start 1.0 is the end.
 * @param output		Output vector
 * @noreturn
 */
stock Math_MoveVector(const Float:start[3], const Float:end[3], Float:scale, Float:output[3])
{
	SubtractVectors(end,start,output);
	ScaleVector(output,scale);
	AddVectors(start,output,output);
}

/**
 * Converts Source Game Units to metric Meters
 * 
 * @param units			Float value
 * @return				Meters as Float value.
 */
stock Float:Math_UnitsToMeters(Float:units)
{
	return (units * GAMEUNITS_TO_METERS);
}

/**
 * Converts Source Game Units to Meters
 * 
 * @param units			Float value
 * @return				Feet as Float value.
 */
stock Float:Math_UnitsToFeet(Float:units)
{
	return (Math_UnitsToMeters(units) * METERS_TO_FEET);
}
