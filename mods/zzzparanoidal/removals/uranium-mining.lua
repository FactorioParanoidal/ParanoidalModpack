require("__zzzparanoidal__.paralib")

-- «Продвинутая добыча» (uranium-mining, переименована Angels) убрана по решению пользователя:
-- её эффект mining-with-fluid уже открывает «Твердотопливная механизация» (zzzcompability).
-- Прототип оставлен скрытым ради сохранений; предшественником других технологий не является.
if data.raw.technology["uranium-mining"] then
	paralib.bobmods.lib.tech.hide("uranium-mining")
end
