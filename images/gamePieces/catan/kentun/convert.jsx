var inputFolder = Folder.selectDialog("Select PSD folder");
var outputFolder = Folder.selectDialog("Select output folder");
var files = inputFolder.getFiles("*.psd");

for (var i = 0; i < files.length; i++) {
    var doc = app.open(files[i]);
    var pngFile = new File(outputFolder + "/" + doc.name.replace(".psd", ".png"));
    var opts = new ExportOptionsSaveForWeb();
    opts.format = SaveDocumentType.PNG;
    opts.PNG8 = false;
    doc.exportDocument(pngFile, ExportType.SAVEFORWEB, opts);
    doc.close(SaveOptions.DONOTSAVECHANGES);
}