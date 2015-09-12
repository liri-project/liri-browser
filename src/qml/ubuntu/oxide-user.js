
oxide.addMessageHandler("GET_HTML", function (msg) {
    var event = new CustomEvent("QMLmessage", {detail: msg.args});
    document.dispatchEvent(event);
    msg.reply({html: document.documentElement.innerHTML});
});

oxide.addMessageHandler("RUN_JAVASCRIPT", function (msg) {
    var event = new CustomEvent("QMLmessage", {detail: msg.args});
    document.dispatchEvent(event);
    msg.reply({result: eval(msg.args["script"])});
});

oxide.addMessageHandler("SET_SOURCE", function (msg) {
    var event = new CustomEvent("QMLmessage", {detail: msg.args});
    document.dispatchEvent(event);

    var e = new CustomEvent("SetSource", {detail: {theme: msg.args["theme"], temp: msg.args["temp"]}});
    document.dispatchEvent(e);

    msg.reply({result: true});
});
