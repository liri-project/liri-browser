/* Bookmarks Omniplet */

var bookmarksModel;

function onOmniBoxSearch(text){
    var count = bookmarksModel.length, temp, i, current=0, temp2
    for(i=0;i<count;i++) {
        temp = bookmarksModel[i]
        try{
            temp2 = temp.url.indexOf(text)
        }
        catch(e){
            temp2 = -1
        }

        if(temp2 !== -1 && current <= 1) {
            current++;
            liri.appendSearchSuggestion(temp.url, "action/bookmark")
        }
    }
}

function onLoad(){
    bookmarksModel = liri.getBookmarks();
    liri.print("Bookmarks Omniplet loaded");
}

liri.on("load", onLoad);
liri.on("omnibox.search", onOmniBoxSearch);
