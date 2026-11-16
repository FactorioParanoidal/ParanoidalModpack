-- Case №A113-6: the chapters of her memory, their fragments (locale [nan-e-memory]) and the questions of the case
-- board ([nan-e-case]). The solution is in LORE-NAN-E.md. Fragments marked bnl are fakes the BnL update wrote into her
-- memory: they contradict the true ones, which is the detective part.
local shared = require("shared")

local story = {}

-- cost: what one card of the chapter takes besides the card itself (the first item that exists in the game).
story.chapters =
{
  {
    title = "chapter-1",
    fragments = {"c1-f1", "c1-f2", "c1-f3", "c1-f4", "c1-f5"},
    bnl = {["c1-f3"] = true},
    cost = {{"bob-basic-circuit-board", 2}, {"electronic-circuit", 2}},
    question = "q1"
  },
  {
    title = "chapter-2",
    tech = shared.tech.memory[1],
    fragments = {"c2-f1", "c2-f2", "c2-f3", "c2-f4", "c2-f5"},
    cost = {{"bob-basic-circuit-board", 4}, {"electronic-circuit", 3}},
    question = "q2"
  },
  {
    title = "chapter-3",
    tech = shared.tech.memory[2],
    fragments = {"c3-f1", "c3-f2", "c3-f3", "c3-f4", "c3-f5"},
    cost = {{"electronic-circuit", 3}},
    question = "q3"
  },
  {
    title = "chapter-4",
    tech = shared.tech.memory[3],
    fragments = {"c4-f1", "c4-f2", "c4-f3", "c4-f4", "c4-f5"},
    bnl = {["c4-f2"] = true},
    cost = {{"electronic-circuit", 6}},
    question = "q4"
  },
  {
    title = "chapter-5",
    tech = shared.tech.memory[4],
    fragments = {"c5-f1", "c5-f2", "c5-f3", "c5-f4"},
    cost = {{"advanced-circuit", 3}, {"electronic-circuit", 10}},
    question = "q5"
  }
}

-- The answer is the number of the right option; reward is what she remembers on the map (script/memory.lua).
story.questions =
{
  q1 = {chapter = 1, options = 4, answer = 3, reward = "ore"},
  q2 = {chapter = 2, options = 4, answer = 3, reward = "ruin"},
  q3 = {chapter = 3, options = 4, answer = 3, reward = "toolbox"},
  q4 = {chapter = 4, options = 4, answer = 4, reward = "direction"},
  q5 = {chapter = 5, options = 4, answer = 4, reward = "camp"}
}
story.question_order = {"q1", "q2", "q3", "q4", "q5"}

-- Cards after the story are bedtime tales ([nan-e-tale]).
story.tales = 10

-- Every fragment: its chapter and position.
story.fragment = {}
story.total = 0
for index, chapter in ipairs(story.chapters) do
  for position, id in ipairs(chapter.fragments) do
    story.fragment[id] = {chapter = index, position = position, bnl = chapter.bnl and chapter.bnl[id] or false}
    story.total = story.total + 1
  end
end

-- The first item of a cost list that exists, with its count.
story.cost = function(chapter)
  for _, entry in ipairs(chapter.cost) do
    if prototypes.item[entry[1]] then
      return entry[1], entry[2]
    end
  end
  return nil, 0
end

return story
