--- For anyone looking to make a sub-mod:
--- ! SEE: `gameNight - implementUno`

local gamePieceHandler = require("gameNight-gamePieceHandler.lua")

--- Basic Playing Cards
--Joker red and black
local playingCards = {}
playingCards.cards = {"Red Joker","Black Joker"}
--Hearts, Clubs, Diamonds, Spades
playingCards.suits = {"Hearts","Clubs","Diamonds","Spades"}
playingCards.values = {"2","3","4","5","6","7","8","9","10","Jack","King","Queen","Ace"}
---Parse through suits and values to generate playingCards
-- this is not 'technically' required but I didn't see a point in typing out a list of 52 entries
for _,s in pairs(playingCards.suits) do
    for _,v in pairs(playingCards.values) do
        table.insert(playingCards.cards, v.." of "..s)
    end
end

gamePieceHandler.card.addDeck("CardDeck", playingCards.cards)
gamePieceHandler.card.addDeck("PlayingCards1", playingCards.cards)
gamePieceHandler.card.addDeck("PlayingCards2", playingCards.cards)
gamePieceHandler.card.addDeck("PlayingCards3", playingCards.cards)

gamePieceHandler.registerSpecial("Base.PlayingCards1", { cardFaceType = "CardDeck" })
gamePieceHandler.registerSpecial("Base.PlayingCards2", { cardFaceType = "CardDeck" })
gamePieceHandler.registerSpecial("Base.PlayingCards3", { cardFaceType = "CardDeck" })