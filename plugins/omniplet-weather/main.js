/* Weather Omniplet */

function onOmniBoxSearch(text){
    if(text.substring(0,8) === "weather ") {
        liri.fetchURL("http://api.openweathermap.org/data/2.5/weather?q=" + text.substring(8,text.length) + "&APPID=7d2c3897b58a06210476db2ba6ae39d2", function(reply) {
            var data = JSON.parse(reply);
            if (typeof(data.message) === "string" && data.message.indexOf("Error") === 0) {
                liri.print(data.message);
                return;
            }
            liri.appendSearchSuggestion(data.name + ": " + data.weather[0].main + " - " + parseInt(data.main.temp - 273) + " °C", "image/wb_sunny", "start");
        });
    }
}

function onLoad(){
    liri.print("Weather Omniplet loaded");
}

liri.on("load", onLoad);
liri.on("omnibox.search", onOmniBoxSearch);
