local deckCataloger = require "gameNight - deckCataloger"

--Joker red and black
local playingCards = {"JokerR","JokerB"}
--Hearts, Clubs, Diamonds, Spades
playingCards.suites = {"H","C","D","S"}
playingCards.values = {"2","3","4","5","6","7","8","9","10","J","K","Q","A"}
---Parse through suites and values to generate playingCards - this is not 'technically' required but I didn't see a point in typing out a list of 52 entries
for _,s in pairs(playingCards.suites) do
    for _,v in pairs(playingCards.values) do
        table.insert(playingCards, v..s)
    end
end

deckCataloger.AddDeck("playing cards", playingCards)