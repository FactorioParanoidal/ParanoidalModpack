game.simulation.camera_position = { 0, 0.5 }
game.surfaces[1].create_entities_from_blueprint_string({
  string = "0eNrFltlyozAQRf9FzyiFxCr/ytSUS+A2oxkQlJZUHJf/PQJPSLCVWPAS3lh0buteGvqMqtbCoIQ0aHdGou6lRrtfZ6RFI3k7XpO8A7RDRnGph14ZXEFr0CVCQh7gBe3I5XeEQBphBFzXTienvbRdBco9EL0zoIXaKFFjkKCaE3aqoI68BhShodeO0MtR0lFLlkfohHY0dkoHodzC6SahEars8Qhqr8Wrg5J4Pi7RnTadtbWttOETxCNWvot5GMnMEPIopLuFBzH4ai7ZU3YFZU/Z5ND1+b0GY4Rs9Cc/BzCqb8F2uOF6ZIGqnTBvYHLMQOeucGMVjLgIdf1hXMYNboFrF4Cn0nSudCwQmx43qrfy4NtxvCx1YbEHna1AZ1+iUw8532Bv/iP2FlvszYPsLbfYm4fYy2bywdZmbDn+z9tvxX/oYySJl8y2l809kcVxOJGEEdNw4kfny15iBS5qiUe4j7ti78myUt3xtvUh2RVZ3GZU+qDpEmrwXytr/7dqJucB3GzJhZc/3GqfA2MAoQ7kwe8qI3RdG5BiBbtY1QekDP3OMFJ+JvtYy6b6JiT2OCR60021Vc/wNTIhj/dKycrcg6B0Q+5JHJQ7TTbkfs/2lp2uz30i+1hZ0DjByHWcSKgXkm+Zh2ZmevNGfTMOublMuB+dE/oY8iL0DEpPS7OcspSxLKVxUaT55fIG3AJF4w==",
  position = { 0, -1 },
})

for _, duct in
  pairs(game.surfaces[1].find_entities_filtered({ name = { "duct-small", "duct", "duct-long", "duct-t-junction" } }))
do
  local fluidbox = duct.fluidbox
  local capacity = fluidbox.get_capacity(1)
  fluidbox[1] = { name = "petroleum-gas", amount = capacity * 0.8 }
end
