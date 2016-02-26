import QtQuick 2.4
import Material.Extras 0.1

ListModel {
    id: dashboardModel

    dynamicRoles: true

    function toArray() {
        var dashboard = []

        for (var i = 0; i < count; i++) {
            var item = get(i);
            dashboard.push({
                "title": item.title,
                "url": item.url,
                "iconUrl": item.iconUrl,
                "bgColor": item.bgColor,
                "fgColor": item.fgColor,
                "uid": item.uid
            })
        }

        return bookmarks;
    }

    function fromArray(dashboard) {
        for (var i = 0; i < dashboard.length; i++)
            append(dashboard[i]);
    }
}
