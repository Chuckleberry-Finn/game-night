<img src="https://raw.githubusercontent.com/Chuckleberry-Finn/game-night/main/images/TITLE.png">

## *Interested in making an Add-On?*

The framework for Game Night is designed to handle any game you can imagine.  Arguably, the biggest hurdle is getting the art assets for your game.
** **
### Implementing cards and other game pieces:
#### These are the relevant modules to call on when implementing your add-on.
```lua
local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler
```
`ApplyDetails handles` applies details to *Game Night* items.<br>
`deckActionHandler` houses actions/mechanics related to cards.<br>
`gamePieceAndBoardHandler` houses action/mechanics related to game pieces.<br>

<sup>Note: Many functions in *deckActionHandler* call on functions within *gamePieceAndBoardHandler*; there are also plans for the two to be merged.</sup>
** **

<details> <summary><b>Implementing Cards:</b></summary>
Technically you just need a table of strings corresponding to textures/names for card items. You can use any means to obtain the list of cards, for example for playing cards, and *Uno*, the card names/IDs are assembled using string manipulation. This is entirely a preference to avoid having to type/copy-and-paste the entries.

<sup>Note: Table entries must match a corresponding Texture in the correct texture directory (more on this later).</sup>

```lua
--- UNO
--This is a table to house all the related stuff to Uno.
local unoCards = {}

-- (19) Red, Blue, Green, Yellow – 0 (1x), 1 to 9 (2x)
-- (8) Skip, Reverse, Draw2 – 2 cards of each color
unoCards.cards = {"Red 0","Green 0","Blue 0","Yellow 0"}
unoCards.suits = {"Red","Green","Blue","Yellow"}
unoCards.values = {"1","2","3","4","5","6","7","8","9","Skip","Reverse","Draw 2"}

for i=1, 2 do -- Reiterate for 2 sets
    for _,s in pairs(unoCards.suits) do -- For each 'suit' (color in Uno)
        for _,v in pairs(unoCards.values) do -- For each value
            -- put suit and value together to match the corresponding Texture
            table.insert(unoCards.cards, s.." "..v)
        end
    end
end

-- (8) Black – 4 Wild cards and 4 Wild Draw 4 cards
unoCards.wilds = {"Wild", "Wild Draw 4"}

for i=1, 4 do -- Reiterate for sets of 4
    -- For each wild (there's no suit/value combo)
    for _,wild in pairs(unoCards.wilds) do
        table.insert(unoCards.cards, wild)
    end
end
```
<BR>

**Defining the card deck/catalogue:**
- arguments/parameters/variables:<br>
  - name (string), cards (table)
  
- `Item` scripts have a `Module.Type`, add Deck assume the module will be `Base`. So the `name` argument should be the corresponding `type` for the item.

- All of the entries in the `cards` list needs to match a corresponding texture in a directory named after the `name` item.
- Additionally, the name of the texture's image file will act as the item's name unless overridden.
<br>`Example:` `media/textures/Item_[name]/`
<br>
<br>
 
**Card Texture Directory Contents:**
- `FlippedInPlay` for flipped cards.
- `card` for inventory icon for single cards.
- `deck` for inventory icon for deck.
- `deckTexture` for model(s) texture.
- Otherwise, the remaining textures name will reflect `name` for each card.

### Example: ```deckActionHandler.addDeck("UnoCards", unoCards.cards)```
</details><br>

<details><summary><b>Implementing Game Pieces:</b></summary>

**Register Special Actions:**<br>
This allows you to apply special parameters and values to gamePieces (and cards as with this example.)
```lua
gamePieceAndBoardHandler.registerSpecial("Base.UnoCards", { actions = { drawCards=7}, })
```
</details>