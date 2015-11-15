/* History Omniplet */

var historyModel;

function onOmniBoxSearch(text){
    var count = historyModel.length, current = 0, temp, temp2
    for(var i=0; i<count; i++) {
        temp = historyModel[i]
        try{
            temp2 = temp.url.indexOf(text)
        }
        catch(e){
            temp2 = -1
        }

        if(temp2 !== -1 && current <= 1) {
            current++;
            liri.appendSearchSuggestion(temp.url, "action/history");
        }
    }
}

function onLoad(){
    historyModel = liri.getHistory();
}

liri.on("load", onLoad);
liri.on("omnibox.search", onOmniBoxSearch);
