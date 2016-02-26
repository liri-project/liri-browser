import QtQuick 2.4
import Material.Extras 0.1

ListModel {
    id: historyModel

    dynamicRoles: true

    function toArray() {
        var history = []

        for (var i = 0; i < count; i++) {
            var item = get(i);
            if (item.type !== "date")
                history.push({
                    "title": item.title,
                    "url": item.url.toString(),
                    "faviconUrl": item.faviconUrl.toString(),
                    "date": item.date,
                    "type": item.type,
                    "color": item.color
                });
        }

        return history;
    }

    function fromArray(history) {
        if (!history)
            history = [];

        // Load the browser history
        var locale = Qt.locale()
        var currentDate = new Date()
        var dateString = currentDate.toLocaleDateString();

        var currentItemDate = dateString;

        for (var i = 0; i < history.length; i++) {
            var item = history[i];

            // Append a date header
            // TODO: Use listview section headers
            if (currentItemDate != item.date) {
                append({
                    "title": item.date,
                    "url": false,
                    "faviconUrl": false,
                    "date": item.date,
                    "type": "date",
                    "color": item.color
                })
                currentItemDate = item.date
            }

            append(item);
        }
    }
}
