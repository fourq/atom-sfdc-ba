(function() {

  console.log('hi');

  function walk(node)
  {
    // I stole this function from here:
    // http://is.gd/mwZp7E

    var child, next;

    switch ( node.nodeType )
    {
      case 1:  // Element
      case 9:  // Document
      case 11: // Document fragment
        child = node.firstChild;
        while ( child )
        {
          next = child.nextSibling;
          walk(child);
          child = next;
        }
        break;

      case 3: // Text node
        handleText(node);
        break;
    }
  }

  function handleText(textNode)
  {
    var v = textNode.nodeValue;

    v = v.replace(/\bThe Cloud\b/g, "My Butt");
    v = v.replace(/\bThe cloud\b/g, "My butt");
    v = v.replace(/\bthe Cloud\b/g, "my Butt");
    v = v.replace(/\bthe cloud\b/g, "my butt");

    textNode.nodeValue = v;
  }

  function windowLoadHandler()
  {
    // Dear Mozilla: I hate you for making me do this.
    window.removeEventListener('load', windowLoadHandler);

    document.getElementById('appcontent').addEventListener('DOMContentLoaded', function(e) {
      walk(e.originalTarget.body);
    });
  }

  window.addEventListener('load', windowLoadHandler);
}());
