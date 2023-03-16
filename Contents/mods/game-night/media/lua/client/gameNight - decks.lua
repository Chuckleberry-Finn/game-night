--- For anyone looking to make a sub-mod:
-- This file is all that you should need.

---First require this file so that the cataloger module can be called on.
local deckCataloger = require "gameNight - deckCataloger"

--- Examples of defining a table
-- this example is overly complicated as it pieces together a table for the sake of typing up a large list
-- technically you just need a table of strings corresponding to textures/names for items


--- Basic Playing Cards
--Joker red and black
local playingCards = {}
playingCards.cards = {"Red Joker","Black Joker"}
--Hearts, Clubs, Diamonds, Spades
playingCards.suites = {"Hearts","Clubs","Diamonds","Spades"}
playingCards.values = {"2","3","4","5","6","7","8","9","10","Jack","King","Queen","Ace"}
---Parse through suites and values to generate playingCards
-- this is not 'technically' required but I didn't see a point in typing out a list of 52 entries
for _,s in pairs(playingCards.suites) do
    for _,v in pairs(playingCards.values) do
        table.insert(playingCards.cards, v.." of "..s)
    end
end
deckCataloger.addDeck("CardDeck", playingCards.cards)


--- UNO
-- (19) Red, Blue, Green, Yellow – 0, 1 to 9 (2x)
-- (8) Skip, Reverse, Draw2 – 2 cards of each color
-- (8) Black – 4 Wild cards and 4 Wild Draw 4 cards
local unoCards = {}
unoCards.cards = {"Red 0","Green 0","Blue 0","Yellow 0","Wild","Wild","Wild","Wild","Wild Draw 4","Wild Draw 4","Wild Draw 4","Wild Draw 4"}

unoCards.suites = {"Red","Green","Blue","Yellow"}
unoCards.values = {"1","2","3","4","5","6","7","8","9","Skip","Reverse","Draw 2"}

for i=1, 2 do --Two sets of 1-9, 0s are single
    for _,s in pairs(unoCards.suites) do
        for _,v in pairs(unoCards.values) do
            table.insert(unoCards.cards, s.." "..v)
        end
    end
end
deckCataloger.addDeck("UnoCards", unoCards.cards)
