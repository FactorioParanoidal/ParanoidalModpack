-- Space Age updated the autoplace specifications of the Vanilla decoratives that we let remain untouched prior to 2.0
-- So in this source we return the autoplace specifications to an equivalent noise-expression.

-- local require_water = function(type, name)
--   local prototype = data.raw[type][name]
--   if not (prototype and prototype.autoplace and prototype.autoplace.peaks) then return end
--   -- apply negative out of max range
--   table.insert(prototype.autoplace.peaks, {
--     water_optimal = 1,
--     water_range = 0.5,
--     water_max_range = 0.7,
--     influence = 1,
--     max_influence = 0,
--   })

-- end
-- require_water("optimized-decorative", "brown-asterisk")
-- require_water("optimized-decorative", "brown-fluff-dry")
-- require_water("optimized-decorative", "brown-fluff")
-- require_water("optimized-decorative", "red-pita")

if    data.raw['optimized-decorative']['red-croton']
  and data.raw['optimized-decorative']['red-croton'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['red-desert-bush'].autoplace
  autoplace.probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}"
  autoplace.local_expressions = {
    max_probability = 0.5,
    penalty = 0.2,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.3)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
    peak1_expr = 0,
    peak2_expr = "peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='fluff', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_aux_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.2,
    peak3_moisture_range = 0.1,
    peak3_moisture_max_range = 0.2,
    peak3_aux_expr = "ab_mimic_peak_dimension(aux,peak3_aux_optimal,peak3_aux_range,peak3_aux_max_range)",
    peak3_aux_optimal = 1,
    peak3_aux_range = 0.2,
    peak3_aux_max_range = 0.3,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile - 1",
    quantile = -0.2,
  }
end
if    data.raw['optimized-decorative']['red-pita']
  and data.raw['optimized-decorative']['red-pita'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['red-desert-bush'].autoplace
  autoplace.probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}"
  autoplace.local_expressions = {
    max_probability = 0.5,
    penalty = 0.2,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.3)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr + peak4_expr",
    peak1_expr = -0.5,
    peak2_expr = "peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='fluff', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_aux_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.2,
    peak3_moisture_range = 0.1,
    peak3_moisture_max_range = 0.2,
    peak3_aux_expr = "ab_mimic_peak_dimension(aux,peak3_aux_optimal,peak3_aux_range,peak3_aux_max_range)",
    peak3_aux_optimal = 1,
    peak3_aux_range = 0.2,
    peak3_aux_max_range = 0.3,
    peak4_expr = "clamp(peak4_distance_expression,"..-math.huge..",0)",
    peak4_distance_expression = "(1 - (peak4_total_distance * (2 / 1)))",
    peak4_total_distance = "peak4_moisture_expr",
    peak4_moisture_expr = "ab_mimic_peak_dimension(moisture,peak4_moisture_optimal,peak4_moisture_range,peak4_moisture_max_range)",
    peak4_moisture_optimal = 1,
    peak4_moisture_range = 0.5,
    peak4_moisture_max_range = 0.7,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile - 0.5",
    quantile = -0.2,
  }
end

if    data.raw['optimized-decorative']['red-asterisk']
  and data.raw['optimized-decorative']['red-asterisk'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['brown-asterisk'].autoplace
  autoplace.probability_expression = "(max_probability * sharpness_filter)"
  autoplace.local_expressions = {
    max_probability = 1,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.6)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
    peak1_expr = -1,
    peak2_expr = "peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='brown-fluff', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_temperature_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.55,
    peak3_moisture_range = 0.15,
    peak3_moisture_max_range = 0.15*1.5,
    peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
    peak3_temperature_optimal = 15,
    peak3_temperature_range = 20,
    peak3_temperature_max_range = 20*1.5,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile",
    quantile = 0.6,
  }
end

if    data.raw['optimized-decorative']['brown-asterisk']
  and data.raw['optimized-decorative']['brown-asterisk'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['brown-asterisk'].autoplace
  autoplace.probability_expression = "(max_probability * sharpness_filter)"
  autoplace.local_expressions = {
    max_probability = 1,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.6)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr + peak4_expr",
    peak1_expr = -1,
    peak2_expr = "peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.9, seed0=map_seed, seed1='brown-fluff', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_temperature_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.3,
    peak3_moisture_range = 0.2,
    peak3_moisture_max_range = 0.2*1.5,
    peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
    peak3_temperature_optimal = 10,
    peak3_temperature_range = 25,
    peak3_temperature_max_range = 25*1.5,
    peak4_expr = "clamp(peak4_distance_expression,"..-math.huge..",0)",
    peak4_distance_expression = "(1 - (peak4_total_distance * (2 / 1)))",
    peak4_total_distance = "peak4_moisture_expr",
    peak4_moisture_expr = "ab_mimic_peak_dimension(moisture,peak4_moisture_optimal,peak4_moisture_range,peak4_moisture_max_range)",
    peak4_moisture_optimal = 1,
    peak4_moisture_range = 0.5,
    peak4_moisture_max_range = 0.7,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile",
    quantile = 0.7,
  }
end

if    data.raw['optimized-decorative']['brown-asterisk-mini']
  and data.raw["optimized-decorative"]['brown-asterisk-mini'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['brown-asterisk-mini'].autoplace
  autoplace.probability_expression = "(max_probability * sharpness_filter)"
  autoplace.local_expressions = {
    max_probability = 1,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.5)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
    peak1_expr = -0.5,
    peak2_expr = "0.5 * peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='brown-fluff', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_temperature_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.55,
    peak3_moisture_range = 0.15,
    peak3_moisture_max_range = 0.15*1.5,
    peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
    peak3_temperature_optimal = 15,
    peak3_temperature_range = 20,
    peak3_temperature_max_range = 20*1.5,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile",
    quantile = 0.7,
  }
end
if    data.raw['optimized-decorative']['brown-fluff']
  and data.raw['optimized-decorative']['brown-fluff'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['brown-fluff'].autoplace
  autoplace.probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}"
  autoplace.local_expressions = {
    max_probability = 1,
    penalty = 0.4,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 1)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr + peak4_expr",
    peak1_expr = 0,
    peak2_expr = "0.5 * peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='garballo', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_temperature_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.65,
    peak3_moisture_range = 0.35,
    peak3_moisture_max_range = 0.45,
    peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
    peak3_temperature_optimal = 30,
    peak3_temperature_range = 5,
    peak3_temperature_max_range = 10,
    peak4_expr = "clamp(peak4_distance_expression,"..-math.huge..",0)",
    peak4_distance_expression = "(1 - (peak4_total_distance * (2 / 1)))",
    peak4_total_distance = "peak4_moisture_expr",
    peak4_moisture_expr = "ab_mimic_peak_dimension(moisture,peak4_moisture_optimal,peak4_moisture_range,peak4_moisture_max_range)",
    peak4_moisture_optimal = 1,
    peak4_moisture_range = 0.5,
    peak4_moisture_max_range = 0.7,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile",
    quantile = 1.9,
  }
end
if    data.raw['optimized-decorative']['brown-fluff-dry']
  and data.raw['optimized-decorative']['brown-fluff-dry'].autopalce
then
  local autoplace = data.raw['optimized-decorative']['brown-fluff-dry'].autoplace
  autoplace.probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}"
  autoplace.local_expressions = {
    max_probability = 1,
    penalty = 0.4,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 1)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr + peak4_expr",
    peak1_expr = -0.5,
    peak2_expr = "0.75 * peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='garballo', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_temperature_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.1875,
    peak3_moisture_range = 0.0625,
    peak3_moisture_max_range = 0.1625,
    peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
    peak3_temperature_optimal = 30,
    peak3_temperature_range = 5,
    peak3_temperature_max_range = 10,
    peak4_expr = "clamp(peak4_distance_expression,"..-math.huge..",0)",
    peak4_distance_expression = "(1 - (peak4_total_distance * (2 / 1)))",
    peak4_total_distance = "peak4_moisture_expr",
    peak4_moisture_expr = "ab_mimic_peak_dimension(moisture,peak4_moisture_optimal,peak4_moisture_range,peak4_moisture_max_range)",
    peak4_moisture_optimal = 1,
    peak4_moisture_range = 0.5,
    peak4_moisture_max_range = 0.7,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile - 0.5",
    quantile = 0.5,
  }
end
if    data.raw['optimized-decorative']['brown-hairy-grass']
  and data.raw['optimized-decorative']['brown-hairy-grass'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['brown-hairy-grass'].autoplace
  autoplace.probability_expression = "(max_probability * sharpness_filter)"
  autoplace.local_expressions = {
    max_probability = 1,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 0.5)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr",
    peak1_expr = -0.5,
    peak2_expr = "0.6 * peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='grass2', octaves=octaves-2.8, input_scale=1, output_scale=1}",
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile + 0.5",
    quantile = 0.95,
  }
end
if    data.raw['optimized-decorative']['brown-carpet-grass']
  and data.raw['optimized-decorative']['brown-carpet-grass'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['brown-carpet-grass'].autoplace
  autoplace.probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}"
  autoplace.local_expressions = {
    max_probability = 0.25,
    penalty = 0.4,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 1)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
    peak1_expr = 0.5,
    peak2_expr = "0.3 * peak2_noise_expression",
    peak2_noise_expression = "clamp(multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='grass2', octaves=octaves-2.8, input_scale=1, output_scale=1}, 0,"..math.huge..")",
    peak3_expr = "0.6 * peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_temperature_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0.65,
    peak3_moisture_range = 0.25,
    peak3_moisture_max_range = 0.5,
    peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)",
    peak3_temperature_optimal = 20,
    peak3_temperature_range = 10,
    peak3_temperature_max_range = 15,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile - 1.1",
    quantile = 0.1,
  }
end
if    data.raw['optimized-decorative']['red-desert-bush']
  and data.raw['optimized-decorative']['red-desert-bush'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['red-desert-bush'].autoplace
  autoplace.placement_density = 1
  autoplace.probability_expression = "(max_probability * sharpness_filter)"
  autoplace.local_expressions = {
    max_probability = 0.4,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 1)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
    peak1_expr = 0,
    peak2_expr = "peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='fluff', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_aux_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0,
    peak3_moisture_range = 0.2,
    peak3_moisture_max_range = 0.3,
    peak3_aux_expr = "ab_mimic_peak_dimension(aux,peak3_aux_optimal,peak3_aux_range,peak3_aux_max_range)",
    peak3_aux_optimal = 1,
    peak3_aux_range = 0.6,
    peak3_aux_max_range = 1,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile - 1",
    quantile = 0.4,
  }
end
if    data.raw['optimized-decorative']['white-desert-bush']
  and data.raw['optimized-decorative']['white-desert-bush'].autoplace
then
  local autoplace = data.raw['optimized-decorative']['white-desert-bush'].autoplace
  autoplace.placement_density = 1
  autoplace.probability_expression = "(max_probability * sharpness_filter)"
  autoplace.local_expressions = {
    max_probability = 0.4,
    sharpness_filter = "ab_sharpness_function(peaks_expr, 1)",
    peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
    peak1_expr = 0,
    peak2_expr = "peak2_noise_expression",
    peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.7, seed0=map_seed, seed1='fluff', octaves=octaves-2, input_scale=1, output_scale=1}",
    peak3_expr = "peak3_distance_expression",
    peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 2)))",
    peak3_total_distance = "peak3_moisture_expr + peak3_aux_expr",
    peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
    peak3_moisture_optimal = 0,
    peak3_moisture_range = 0.2,
    peak3_moisture_max_range = 0.3,
    peak3_aux_expr = "ab_mimic_peak_dimension(aux,peak3_aux_optimal,peak3_aux_range,peak3_aux_max_range)",
    peak3_aux_optimal = 1,
    peak3_aux_range = 0.6,
    peak3_aux_max_range = 1,
    octaves = "10 - log2(var('control:trees:frequency'))",
    influence_modifier = "0.5 - quantile - 1",
    quantile = 0.4,
  }
end