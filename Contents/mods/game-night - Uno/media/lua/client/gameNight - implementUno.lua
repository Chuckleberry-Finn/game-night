--- For anyone looking to make a sub-mod:

---First require this so that these modules can be called on as needed.
local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

--- DEFINING A `CARDS` TABLE/LIST
-- Technically you just need a table of strings corresponding to textures/names for items.
-- In this example we use arguably complicated means to handle the entries by piecing together a table for the sake of not typing up a large list.

--- ! Table entries must match a corresponding Texture in the correct texture directory (more on this later).

--- UNO
--This is a table to house all the related stuff to Uno.
local unoCards = {}

-- (19) Red, Blue, Green, Yellow – 0 (1x), 1 to 9 (2x)
-- (8) Skip, Reverse, Draw2 – 2 cards of each color
unoCards.cards = {"Red 0","Green 0","Blue 0","Yellow 0"}
unoCards.suits = {"Red","Green","Blue","Yellow"}
unoCards.values = {"1","2","3","4","5","6","7","8","9","Skip","Reverse","Draw 2"}

for i=1, 2 do -- Reiterate for sets of 2
    for _,s in pairs(unoCards.suits) do -- For each 'suit' (color in Uno)
        for _,v in pairs(unoCards.values) do -- For each value
            table.insert(unoCards.cards, s.." "..v) -- put suit and value together to match the corresponding Texture
        end
    end
end

-- (8) Black – 4 Wild cards and 4 Wild Draw 4 cards
unoCards.wilds = {"Wild", "Wild Draw 4"}

for i=1, 4 do -- Reiterate for sets of 4
    for _,wild in pairs(unoCards.wilds) do -- For each wild (there's no suit/value combo)
        table.insert(unoCards.cards, wild)
    end
end

-- arguments/parameters/variables:
--- name (string), cards (table)
--
--- Where `Item` scripts are defined as `Module.Type`
--- The `name` argument has to correspond to a `Type` under the `Base` module.
--
--- ALL OF THE ENTRIES IN `CARDS` NEEDS TO MATCH WHAT THE CARD WILL BE CALLED IN GAME *AND* MATCH A TEXTURE IN THE CORRECT `DIRECTORY`
--- DIRECTORY: `media/textures/Item_[name]/`
-- Textures should include
    -- `FlippedInPlay` for flipped cards.
    -- `card` for inventory icon for single cards.
    -- `deck` for inventory icon for deck.
    -- `deckTexture` for model(s) texture.
    -- Otherwise the texture name will reflect `name` for each card.
deckActionHandler.addDeck("UnoCards", unoCards.cards)

---Register Special Actions
gamePieceAndBoardHandler.registerSpecial("Base.UnoCards", { actions = { drawCards=7}, })
