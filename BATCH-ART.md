### Required:
- Photoshop (Unclear if another program can do batching obviously not everyone can afford an Adobe subscription - but the steps below are specific to Photoshop.)
- Google Sheets (Or something that creates CSVs)

You can use this technique to create values in a spreadsheet that feeds into Photoshop, producing a batch of images based on those values. Simply put, if you have a list of words for a series of cards, you can use this process to generate images for each card from one template.

** **

### Setting up the CSV:

It is required that each column’s value is used, you cannot have any filler columns or photoshop will throw a really vague error about there being too many/few data points. A way to get around this is to set up your data on one sheet and have another (final) sheet pull data from the first. This can help keep things organized.

** **

### Setting up a Photoshop file:

<table>
Topbar menu: Image > Variables > Data Sets
<td>
Select <b>Import</b> and select the CSV file (you may need to change the filetype in the selection window).

Select '<b>Use First Columns for Data Set Names</b>'. (This is important for exporting.)

If all the data is setup correctly there should be no issues or error popups.
</td></table>

<table>
Topbar menu: Image > Variables > Define
<td>
<b>Layer</b> would be the layer the variable will impact. It is highly recommended to name your layers so they’re easily identifiable, I like to name them the same thing as the CSV header it’s to be associated with.

Under the <b>Variable Type</b> section is where the magic happens.

<b>Visibility</b> determines if the layer should be visible or not, the ‘Name’ should be equal to the header value in the CSV.

<b>Pixel Replacement</b> grabs a file from the file path listed in the csv and applies that to the layer as a linked file. You can also dictate how the image will be inserted. Simplest is using conform and having the layer set to the size you’d like. This is useful for setting artworks for cards.

For images the CSV value has to be a reachable path to the file - however, relative paths are possible if you have the images inside of a folder in the same place as the PSD (photoshop file).
</td></table>

** **

#### Running a batch:

<b>Topbar Menu: Image > Apply Data Set:</b> This option lets you preview the different data sets, <b>do not select Apply.</b> It is recommended to do this first just to confirm everything is in order.

<b>Topbar Menu: File > Export > Data Sets as Files:</b> This is where the 'Use First Columns for Data Set Names' option is Import helps, as now you can ask that the file name match the data set name.

<sup>Unfortunately, the export option only produces PSDs of each file. On the bright side, all elements included in each PSD are linked elements - so you can keep the artwork, and individual card PSDs and change either to alter the final result. This can be extremely useful if you need to change the template itself.</sup>

<b>Final Step:</b> Converting the PSDs to PNGs. This can be done using a conversion tool if you'd like something simple. Otherwise you can also use Photoshop to automate a save as PNG process.

<b>Topbar Menu: Windows > Actions:</b> Record yourself opening one of the produces files, then Save As PNG. Stop the record. Go to <b>Topbar Menu: File > Automate > Batch</b> and select the source folder, override open actions, select destination folder, override save as actions. Run and wait. Photoshop should start opening, saving, and closing the PSDs.