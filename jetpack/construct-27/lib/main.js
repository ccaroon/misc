exports.main = function(options, callbacks) {

    var contextMenu = require("context-menu");
    var widget      = require("widget");
    var self        = require("self");
    var xhr         = require("xhr");
    
    // Google Link Text Menu item
    var menuItem = contextMenu.Item({
        label: "Google Link Text",
        context: "a[href]",
        onClick: function (contextObj, item) {
            var anchor = contextObj.node;
            var searchUrl = "http://www.google.com/search?q=" + anchor.textContent;
            contextObj.window.location.href = searchUrl;
        }
    });
    contextMenu.add(menuItem);
    
    // Workman "goto" button
    var wm_widget = widget.Widget({
        label: "Workman",
        image: "http://localhost:3000/favicon.ico",
        onClick: function (e) {
            e.view.content.location = "http://localhost:3000/main/home";
        }
    });
    widget.add(wm_widget);
    
    // Source
    var src = widget.Widget({
        label: "Source",
        image: self.data.url("source.png"),
        onClick: function (e) {
            e.view.content.location = self.data.url("main.js.html");
        }
    });
    widget.add(src);
    
    // New Note
    var new_note = widget.Widget({
        label: "New Note",
        image: "http://localhost:3000/images/themes/default/notes.png",
        onClick: function (e) {

            var selection = e.view.content.getSelection();
            var title = selection.toString().substr(0,48) + '...';
            var note = "<note><title>"+title+"</title><body>"+selection+"</body></note>";
            console.info(note);
            
            var req = new xhr.XMLHttpRequest();
            req.open('POST', 'http://localhost:3000/notes', false, 'ccaroon', 'fish4free');
            req.setRequestHeader('Content-type','text/xml');
            req.setRequestHeader('Accept','text/xml');
            req.send(note);
            
            if (req.status == 201) {
                var resp = req.responseXML;
                //console.debug(resp);
                var id = resp.getElementsByTagName("id")[0].childNodes[0].nodeValue;
                e.view.content.location = "http://localhost:3000/notes/"+id;
            }
            else {
                console.info("Error - status: "+req.status);
            }
        }
    });
    widget.add(new_note);
    
    // About
    var about = widget.Widget({
        label: "About",
        content: "?",
        onClick: function (e) {
            e.view.content.location = self.data.url("about.html");
        }
    });
    widget.add(about);
};
