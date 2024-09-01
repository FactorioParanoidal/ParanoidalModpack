--https://habr.com/ru/articles/346892/
function Class(parent)
    local class = {}
    local mClass = {}

    -- Сам класс будет метатаблицей для объектов.
    -- Это позволит дописывать ему метаметоды.
    class.__index = class

    -- Поля объектов будут искаться по цепочке __index,
    -- и дотянутся, в том числе, до родительского класса.
    mClass.__index = parent

    -- Резервируем поле Super под родителя.
    class.Super = parent
    -- ссылка на себя
    class.self = class

    -- Функция, которая будет вызываться при вызове класса
    function mClass:__call(...)
        local instance = setmetatable({}, class)

        -- Резервируем поле класса "init"
        if type(class.init) == "function" then
            -- Возвращаем экземпляр и всё что он вернул функцией init
            return instance, instance:init(...)
        end
        -- Но если её нет - тоже ничего.
        return instance
    end

    return setmetatable(class, mClass)
end
