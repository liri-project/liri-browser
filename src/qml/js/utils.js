.import Material.Extras 0.1 as Extras
.pragma library

var searchEngine = "google"

function getValidUrl(url) {
    url = String(url)

    if (isMedia(url)) {
        // TODO: This probably shouldn't be showing dialogs from a getter function
        page.mediaDialog.url = url
        page.mediaDialog.show()
        return
    } else if (isPdf(url)) {
        url = "https://docs.google.com/viewer?url=" + url;
    } else if (url.indexOf('.') !== -1 && url.indexOf('?') !== 0) {
        if (url.lastIndexOf('http://', 0) !== 0){
            if (url.lastIndexOf('https://', 0) !== 0){
                url = 'http://' + url;
            }
        }
    } else if (isSearchQuery(url)) {
        if (url.indexOf('?') === 0 && url.length > 1) {
            url = url.substring(1);
        }

        url = getSearchUrl(url)
    }

    return url;
}

function getSearchUrl(query) {
    if(searchEngine == "duckduckgo")
        return "https://duckduckgo.com/?q=" + query;
    else if(searchEngine == "yahoo")
        return "https://search.yahoo.com/search?q=" + query;
    else if(searchEngine == "bing")
        return "http://www.bing.com/search?q=" + query;
    else
        return "https://www.google.com/search?q=" + query;
}

function isSearchQuery(url) {
    url = String(url)
    if (url.indexOf('.') !== -1) {
        if (url.indexOf('http://', 0) === 0 && url.indexOf('https://', 0) === 0) {
            return false;
        } else {
            return url.indexOf(' ') !== -1
        }
    } else if (url.indexOf('liri://') !== -1) {
        return false
    } else {
        return true;
    }
}

function isMedia(url) {
    url = String(url)
    return url.slice(-4) == ".mp3" || url.slice(-4) == ".mp4"  || url.slice(-4) == ".avi"
}

function isPdf(url) {
    url = String(url)
    return url.slice(-4) == ".pdf";
}

function getBetterIcon(url) {
    return Extras.Http.get("http://icons.better-idea.org/api/icons?url=" + url).then(function(json) {
        if ("error" in json) {
            throw new Error(json.error)
        } else {
            return json.icons[0].url
        }
    });
}
