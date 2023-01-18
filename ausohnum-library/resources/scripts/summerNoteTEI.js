var italicTEI = function (context) {
    var ui = $.summernote.ui;
  
    // create button
    var button = ui.button({
      contents: '<em>Italics</em> TEI',
      tooltip: 'Divine name',
      
      click: function () {
        //get selected text
        var selectedText = window.getSelection();
        
        var element = document.createElement('rs');
        var range = selectedText.getRangeAt(0);
        
        element.innerHTML = selectedText;
        element.setAttribute("type", "divine");
        range.deleteContents();
        range.insertNode(element);
      }
    });
    return button.render().addClass('note-btn-italic');   // return button as jquery object
  }
  var noteBottom = function (context) {
    var ui = $.summernote.ui;
  
    // create button
    var button = ui.button({
      contents: 'Note',
      tooltip: 'Mark as a Note',
      click: function () {
        //get selected text
        var selectedText = window.getSelection();
        var element = document.createElement('note');
        var range = selectedText.getRangeAt(0);
        checkSelection = new RegExp('^note', 'i');
        console.log(checkSelection.test(selectedText.toString().substring(1)));
        console.log(selectedText.toString().substring(1));
        element.innerHTML = selectedText;
        element.setAttribute("place", "bottom");
        range.deleteContents();
        range.insertNode(element);
      }
    });
  
    return button.render();   // return button as jquery object
  }
