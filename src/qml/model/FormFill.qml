import QtQuick 2.4
import Material.Extras 0.1
import Papyros.Core 0.2

Object {
    id: formFill

    property Item webview

    readonly property string extractorJS: "(function (){ \
        var forms; \
        var formList = document.forms; \
        if (formList.length > 0) { \
            forms = new Array; \
            for (var i = 0; i < formList.length; ++i) { \
                var inputList = formList[i].elements; \
                if (inputList.length < 1) { \
                    continue; \
                } \
                var formObject = new Object; \
                formObject.name = formList[i].name; \
                if (typeof(formObject.name) != 'string') { \
                    formObject.name = String(formList[i].id); \
                } \
                formObject.index = i; \
                formObject.elements = new Array; \
                for (var j = 0; j < inputList.length; ++j) { \
                    if (inputList[j].type != 'text' && inputList[j].type != 'email' && inputList[j].type != 'password') { \
                        continue; \
                    } \
                    if (inputList[j].disabled || inputList[j].autocomplete == 'off') { \
                        continue; \
                    } \
                    var element = new Object; \
                    element.name = inputList[j].name; \
                    if (typeof(element.name) != 'string' ) { \
                        element.name = String(inputList[j].id); \
                    } \
                    element.value = String(inputList[j].value); \
                    element.type = String(inputList[j].type); \
                    element.readonly = Boolean(inputList[j].readOnly); \
                    formObject.elements.push(element); \
                } \
                if (formObject.elements.length > 0) { \
                    forms.push(formObject); \
                } \
            } \
        } \
        return forms; \
    }())"

    property var forms
    readonly property var passwordForms: ListUtils.filter(forms, function(form) {
        return form.elements.filter(function(element) {
            return element.type === "password"
        }).length > 0
    })

    function isFormFilledIn(form) {
        return form.elements.filter(function(element) {
            return element.value !== ""
        }).length > 0
    }

    function findForms() {
        var promise = new Promises.Promise()

        webview.runJavaScript(extractorJS, function(forms) {
            formFill.forms = forms
            promise.resolve(forms)
        })

        return promise
    }

    function findAndSaveForms() {
        findForms(webview).then(function() {
            passwordForms.forEach(function(form) {
                if (isFormFilledIn(form)) {
                    saveForm(webview.url, form)
                }
            })
        });
    }

    function saveForm(url, form) {
        var key = walletKey(url, form)
        wallet.writePassword(key, JSON.stringify(form))
    }

    function findAndFillForms() {
        findForms(webview).then(function() {
            passwordForms.forEach(function(form) {
                fillForm(webview.url, form)
            })
        });
    }

    function fillForm(url, form) {
        var keyPrefix = extractDomain(url) + "#"

        var matchingKeys = ListUtils.filter(wallet.entryList(), function(entry) {
            return entry.indexOf(keyPrefix) == 0
        })

        if (matchingKeys.length == 0)
            return;

        var key = matchingKeys[0]
        var formData = JSON.parse(wallet.readPassword(key))

        var script = ""

        formData.elements.forEach(function(field) {
            script += "if (document.forms[\"%1\"].elements[\"%2\"]) document.forms[\"%1\"].elements[\"%2\"].value=\"%3\";\n"
                      .arg(form.name && form.name.length > 0 ? form.name : form.index)
                      .arg(field.name).arg(field.value);
        });

        webview.runJavaScript(script, function() {
            // Nothing needed here
        })
    }

    function walletKey(url, form) {
        var hostname = extractDomain(url)

        var queries = [
            function(field) { return field.name == "user" && field.type == "text" },
            function(field) { return field.name == "name" && field.type == "text" },
            function(field) { return field.type == "text" },
            function(field) { return field.type == "email" },
            function(field) { return field.type != "hidden" && field.type != "password" },
        ]
        var usernameField = findFieldInForm(form, queries)

        if (usernameField && usernameField.value.length > 0) {
            return hostname + "#" + usernameField.value
        } else {
            return hostname
        }
    }

    function extractDomain(url) {
        url = String(url)

        var domain;
        //find & remove protocol (http, ftp, etc.) and get domain
        if (url.indexOf("://") > -1) {
            domain = url.split('/')[2];
        }
        else {
            domain = url.split('/')[0];
        }

        //find & remove port number
        domain = domain.split(':')[0];

        return domain;
    }

    function findFieldInForm(form, queries) {
        var fields = [];

        queries.forEach(function(query) {
            fields = fields.concat(ListUtils.filter(form.elements, query))
        })

        if (fields.length > 0)
            return fields[0]
    }

    KQuickWallet {
        id: wallet
        folder: "Form Data"
    }
}
