import QtQuick 2.4
import Material.Extras 0.1

ListModel {
    id: bookmarksModel

    dynamicRoles: true

    function toArray() {
        var bookmarks = []

        for (var i = 0; i < count; i++) {
            var item = get(i);
            bookmarks.push({
                "title": item.title,
                "url": item.url.toString(),
                "faviconUrl": item.faviconUrl.toString()
            });
        }

        return bookmarks;
    }

    function fromArray(bookmarks) {
        for (var i = 0; i < bookmarks.length; i++) {
            var item = bookmarks[i];
            item["uid"] = i;

            append(item);
        }
    }
}
