<div align="center"></div><img src="https://raw.githubusercontent.com/Chuckleberry-Finn/game-night/main/images/TITLE.png"></div>

## *Interested in making an Add-On?*

The framework for Game Night is designed to handle any game you can imagine.  Arguably, the biggest hurdle is <a href=https://github.com/Chuckleberry-Finn/game-night/blob/main/ART.md>acquiring the art assets</a> for your game. If you're a more hands-on learner, try reading through existing add-ons. Much of the information below is taken from them.
** **
#### <a href=https://github.com/Chuckleberry-Finn/game-night/blob/main/ART.md><b>Acquiring art assets</b></a>
** **
<details> <summary><b>Implementation Modules:</b></summary>

**These are the relevant modules to call on when implementing your add-on.**
```lua
local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler
```
`ApplyDetails handles` applies details to *Game Night* items.<br>
`deckActionHandler` houses actions/mechanics related to cards.<br>
`gamePieceAndBoardHandler` houses action/mechanics related to game pieces.<br>

<sup>Note: Many functions in *deckActionHandler* call on functions within *gamePieceAndBoardHandler*; there are also plans for the two to be merged.</sup>
<br>
<br>
</details>

** **

<details> <summary><b>Implementing Cards:</b></summary>
Technically you just need a table of strings corresponding to textures/names for card items. You can use any means to obtain the list of cards, for example for playing cards, and <I>Uno</I>, the card names/IDs are assembled using string manipulation. This is entirely a preference to avoid having to type/copy-and-paste the entries.

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
  
- `Item` scripts have a `Module.Type`, `addDeck` assumes the `Module` will be `Base`. So the `name` argument should be the corresponding `Type` for the item.

- All the entries in the `cards` list needs to match a corresponding texture in a directory named after the `name` of the item.
- Additionally, the filename of the texture(s) will act as the item's display-name (unless overridden.)
<br>`Example:` `media/textures/Item_[name]/`
<br>
<br>
 
**Card Texture Directory Contents:**
- `FlippedInPlay` for flipped cards.
- `card` for inventory icon for single cards.
- `deck` for inventory icon for deck.
- `deckTexture` for model(s) texture.
- Otherwise, the remaining textures name will reflect `name` for each card.

#### Example: ```deckActionHandler.addDeck("UnoCards", unoCards.cards)```


**Alternative Names/Icons:**
It may not be always practical to name textures the intended names of cards, when defining a card deck you can supply an alternative name and icons for each cardID.
```lua
local MonopolyChanceDeck = {}
MonopolyChanceDeck.cards = {}
MonopolyChanceDeck.altIcons = {}
MonopolyChanceDeck.altNames = {}

for n=1, 25 do
    local cardID = "Chance"..n
    local fetchCard = getTextOrNull("Tooltip_"..cardID)
    if fetchCard then
        table.insert(MonopolyChanceDeck.cards, cardID)
        MonopolyChanceDeck.altNames[cardID] = "MonopolyChance"
        MonopolyChanceDeck.altIcons[cardID] = "ChanceCard"
    end
end

deckActionHandler.addDeck("MonopolyChance", MonopolyChanceDeck.cards, MonopolyChanceDeck.altNames, MonopolyChanceDeck.altIcons)
```
<br>
</details>

** **

<details><summary><b>Implementing Game Pieces:</b></summary>

**Registering Types:**<br>
Register game pieces by type, and enables the display of items using textures found in: `Item_InPlayTextures` and `Item_OutOfPlayTextures`.
<br><sup>Note: In-Play defaults to Out of play textures. Out of play textures replaces the item's texture/icon.</sup><br>
```lua
gamePieceAndBoardHandler.registerTypes({
"Base.CatanCityWhite", "Base.CatanSettlementWhite", "Base.CatanRoadWhite",
"Base.CatanCityRed", "Base.CatanSettlementRed", "Base.CatanRoadRed",
"Base.CatanCityBlue", "Base.CatanSettlementBlue", "Base.CatanRoadBlue",
"Base.CatanCityOrange", "Base.CatanSettlementOrange", "Base.CatanRoadOrange",
"Base.CatanRobber", "Base.CatanLongestRoad", "Base.CatanLargestArmy", "Base.CatanBoard",
"Base.CatanPlayerCostsWhite", "Base.CatanPlayerCostsRed", "Base.CatanPlayerCostsOrange", "Base.CatanPlayerCostsBlue"})
```
** **
**Register Special Parameters:**<br>
This allows you to apply special parameters and values to gamePieces (and cards as with this example.)
```lua
gamePieceAndBoardHandler.registerSpecial("Base.UnoCards", { actions = { drawCards=7 }, })
```
<br>

`actions`: Used to add additional contextual actions for items, the key is required to match a function belonging to either of the handlers (deck/gamePiece). The value (in the above example the `7`) is supplied as an argument to the matching function.


<details><summary>Example actions:</summary>

`examineCard`: Displays the piece's texture to the side of the game-window when the hovering over said piece or through a context menu option. Also applies to the search-window for decks/cards. Recommended to use a very large texture for a better effect with examination, and to utilize 'textureSize' in order to make the game-piece smaller in use.
</details>
<br>

`examineScale`: The scaling of the examine texture, can be larger or smaller than 1.

`shiftAction`: Used to control which of the actions can be executed quickly using shift + click. It will also display a texture from `actionIcons`.


`alternateStackRendering`: Table of optional arguments to feed into volumetric rendering. To emphasize, all arguments are optional. 
```lua
{ func="DrawTextureCardFace", depth=5, rgb = {0.741, 0.725, 0.710} }
``````

`category`: Alternate category for the item, default would be "Game Piece.

`cardFaceType`: Provide an alternative texture directory for cards. Useful for cards sets with different backs but identical faces.

`textureSize`: = Table of width and height for texture size overrides. Useful for large textures to not get sized down when compressed. Useful for cards/pieces of examine enabled, so the examine texture is large, while the in-game piece is smaller.

`noRotate`: Boolean. Sets if rotation via mouse wheel is blocked, default is nil (false).

`applyCards`: Set an alternative detailApply for card items. The value must match a function within deckActionHandler.

`onDraw`: Additional function to execute when a card is drawn.

`weight`: Override the weight of an item, useful if converting vanilla items. Weight respects stacking.

`canStack`: If the game piece can be stacked. Value intended as default stack when item is found.

`moveSound`: Alternative sound whne moving the game piece/card.

`tooltips`: Table of x, y, w, h, text to use as tooltips on the game piece. Coordinates are top-left as 0x0.
<br>
<br>
</details>