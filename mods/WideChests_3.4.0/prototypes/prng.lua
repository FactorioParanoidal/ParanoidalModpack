-- Code from https://github.com/bobbens/ArtTreeKS/blob/master/examples/prng.lua

prng = { z = 1 }

function prng.initHash(str)
   local hash = 5381
   local i = 1
   local bytes = { string.byte(str, 1, string.len(str)) }
   for _,c in ipairs(bytes) do
      hash = hash * 33 + c
   end
   prng.z = math.abs(math.fmod(hash, 4294967295))
end

function prng.num()
   prng.z = math.abs(math.fmod(prng.z * 279470273, 4294967295))
   return prng.z / 4294967295
end

function prng.range(min, max)
   local n = prng.num()
   return math.floor(min + n * (max - min) + 0.5)
end

prng.initHash("MergingChests")