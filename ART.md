1. Find card scan assets
   Most TGCs have a site that catalogues all their cards. A simple search should find them.
   Cards are usually released in sets so it is best to do all cards that belong to a set at once, rather than creating partial or incomplete sets.

    The files should ideally be PNG image format, although JPGs are fine too if PNGs are not available.


2. Organizing images
   Download the images for every card in the set into a folder on your computer. You will need to organize the card images you downloaded into whatever different categories exist in your TGC. A simple way to do this is to create subfolders and drag the different card types into different subfolders.


3. Renaming image files
   You will need to rename the images to include their name, category, or whatever important criteria there are in your TGC. The mod code will read the image file name so it should be something that allows you to easily identify the card in the code.
   I use a program called 'Bulk Rename Utility', but you can use whatever bulk rename tool you prefer. Or even do it manually.

    <br>This is an example from the Magic: The Gathering image name:

   `MTG Alpha Artifacts 32`
   `MTG Fallen Empires Green 9`

    <br>The first section (MTG) is a shortened form of the game's name. The second (Alpha or Fallen Empires) denotes the set that those cards belonged to. The third (Artifacts or Green) denotes the type of card. The number at the end is an ascending suffix number for each card that belong in a type or suite. I found this was the quickest way to give them names.  Your TGC might have something similar, or be completely different so you will have to come up with something that works for your game.
   <BR>

4. Put images into the mod folder
   Once all the cards are named, put them into the it's proper directory in the mod folder. It should be the folder Item_mtgCards in the media\textures directory of that mod folder. You should see them all named and organized here. Do a quick check to see if you missed any.
   (This next step is for Windows, but an alternative should exist on your platform)
   At the navigation bat at the top your explorer window, right-click it and select 'Copy Address'
   Go to Command Prompt by clicking on your start menu and typing cmd


5. Getting a list of names
   In Command Prompt, type cd
   and then paste the address you just copied.
   It should look something like this, but obviously won't be this so don't copy what is below:

    
    cd C:\Users\[Your_Name]\Zomboid\Workshop\Game Night - New Card Game\Contents\mods\game-new-card-game\media\textures\Item_New_Card_Game

- Press Enter and you will be at that directory.
- Then paste: `dir /b > files.txt` into the command line.
- This will generate a text file called files.txt of all the files in the directory.


6. Cleaning up the text file
   Navigate again to the directory with the card images and you will find a new file there called files.txt. Open it in notepad. You will need to clean it up a bit. Delete the name of the file itself at the top, and then remove all the .png at the end of each entry.
   What you want is a clean list of cards names. They should already be organized in alphabetical order.


7. Polishing the cards images
   Most card images are rectangular with sharp corners. This doesn't look good in Game Night. Cards look their best when they have rounded corners (although if your particular TGC has sharp cards then skip this step). The next step will require a bit of work, but it is worth it and will give the mod more polish. It will also require a working understanding of image editors too.
    <br><br>
   The format you want your cards in is PNG. If the images are JPG, you will need to convert them to PNGs. The Alpha channel in the PNG format allow your transparency that allow for rounded corners (and other effects). If your cards are not already, you will need to batch convert them to the PNG format. Most image editors should have that functionality.
   If the cards you have are meant to have rounded corners, you will see them in the scan because image files are inherently rectangular. You will need to go through each card and delete the outside portion of the rounded corner. If you see some variant of a checkered grey grid, it's transparent. Do this for every card.