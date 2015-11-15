/* DuckDuckGo Omniplet */

function onOmniBoxSearch(text){
    liri.fetchURL("https://duckduckgo.com/ac/?q=" + text, function(reply) {
        var data = JSON.parse(reply);
        liri.appendSearchSuggestion(text, "action/search");
        for(var i in data)
            liri.appendSearchSuggestion(data[i].phrase,"action/search");
    });
}

function onLoad(){
    liri.print("DuckDuckGo Omniplet loaded");
}

liri.on("load", onLoad);
liri.on("omnibox.search", onOmniBoxSearch);
