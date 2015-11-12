function onOmniBoxSearch(text){
    liri.print(text);
}

function onLoad(){
    return liri.print("Hello World")
}

liri.on("load", onLoad);
liri.on("omnibox.search", onOmniBoxSearch);
