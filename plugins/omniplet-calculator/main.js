/* Calculator Omniplet */

function search(expr,a,b) {
    var i = 0
    while (i != -1) {
        i = expr.indexOf(a,i);
        if (i>=0) {
            if (i==0) {
                expr = expr.substring(0,i)+b+expr.substring(i+a.length);
                i += b.length
            } else {
                if (expr.substring(i-1,i) != "a") {
                    expr = expr.substring(0,i)+b+expr.substring(i+a.length);
                    i += b.length
                } else {i++}
            }

        }
    }
    return expr
}

function calculate(f) {
    var expr = f;
    expr = search(expr,'cos','Math.cos');
    expr = search(expr,'sin','Math.sin');
    expr = search(expr,'tan','Math.tan');
    expr = search(expr,'acos','Math.acos');
    expr = search(expr,'asin','Math.asin');
    expr = search(expr,'atan','Math.atan');
    expr = search(expr,'ln','Math.log');
    expr = search(expr,'exp','Math.exp');
    expr = search(expr,'pow','Math.pow');
    expr = search(expr,'sqrt','Math.sqrt');
    expr = search(expr,'pi','Math.PI');
    return eval(expr);
}

function onOmniBoxSearch(text){
    if(text.substring(0,1) === "=") {
        liri.appendSearchSuggestion("Result : " + calculate(text.substring(1,text.length)), "action/code", "start");
    }
}

function onLoad(){
    liri.print("Calculator Omniplet loaded");
}

liri.on("load", onLoad);
liri.on("omnibox.search", onOmniBoxSearch);
