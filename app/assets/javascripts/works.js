// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
$( document ).ready(function() {
    var ele = gon.elements;
    ele = JSON.stringify(ele);
    $( ".test" ).text(ele);

    var lel = gon.elements;
    $( ".test" ).text(JSON.stringify(lel));
});


//this is for text areas
(function ($, undefined) {
    $.fn.getCursorPosition = function() {
        var el = $(this).get(0);
        var pos = 0;
        if('selectionStart' in el) {
            pos = el.selectionStart;
        } else if('selection' in document) {
            el.focus();
            var Sel = document.selection.createRange();
            var SelLength = document.selection.createRange().text.length;
            Sel.moveStart('character', -el.value.length);
            pos = Sel.text.length - SelLength;
        }
        return pos;
    }
  })(jQuery);

//GETTING THE CARET POSITION
function getCaretCharacterOffsetWithin(element) {
    var caretOffset = 0;
    var doc = element.ownerDocument || element.document;
    var win = doc.defaultView || doc.parentWindow;
    var sel;
    if (typeof win.getSelection != "undefined") {
        var range = win.getSelection().getRangeAt(0);
        var preCaretRange = range.cloneRange();
        preCaretRange.selectNodeContents(element);
        preCaretRange.setEnd(range.endContainer, range.endOffset);
        caretOffset = preCaretRange.toString().length;
    } else if ( (sel = doc.selection) && sel.type != "Control") {
        var textRange = sel.createRange();
        var preCaretTextRange = doc.body.createTextRange();
        preCaretTextRange.moveToElementText(element);
        preCaretTextRange.setEndPoint("EndToEnd", textRange);
        caretOffset = preCaretTextRange.text.length;
    }
    return caretOffset;
}

function showCaretPos() {
    var el = document.getElementById("test");
    var caretPosEl = document.getElementById("caretPos");
    caretPosEl.innerHTML = "Caret position: " + getCaretCharacterOffsetWithin(el);
}



function updateElements(){
  changed_line="shoe";
  $.ajax({
    type:"GET",
    url:"modelements",
    data: {name: changed_line},
    dataType:"json",
    success: function(data){
      alert(JSON.stringify(data));
    }
  });
}

var lineText = "";
var prevLine = 0;

function checkChangedLine(currLine){
  if (currLine != prevLine){
   // alert("moved to line"+currLine + "from" + prevLine);
    prevLine = currLine;
    return true;
  }
  return false;
}

function getCurrentLine(el){
 // console.log(text);

  var caretPos = getCaretCharacterOffsetWithin(el);
  var currLine = 0;

  var text = el.innerText;
  var text_html = el.innerHTML;

 // alert(text_html);


  var i;

  /* attempts to use the way of displaying for breaking down lines
  for (i = 0; i < caretPos; i++){
    if (text_html[i] == "<"){
      if (text_html.substring(i, i+5) == "<div>"){
        caretPos += 5;
        console.log("div found" + i);
        currLine++;
      }
      else if (text_html.substring(i, i+6) == "</div>"){
        caretPos += 6;
    //    alert("b");
      }
      else if (text_html.substring(i, i+4) == "<br>"){
        caretPos+= 4;
    //    alert("c");
      }
    //  alert("okkaaay");
    }
  }*/

 
  for (i = 0; i <= caretPos; i++){
    console.log("*"+text[i]);
    if (text[i] == "\n"){
      currLine++;
      caretPos++;
    }
    else{
    }
  }

  //for text input, fixes the issue with the extra newline at the end
  if (currLine > 0 && text[caretPos-1] == "\n"){
    currLine--;
  }

  //solves issue with end of line moving cursor via arrows
  if (text[caretPos] == "\n"){
    currLine--;
  }
//if it's a newline...
  return currLine;
}

function pressFunction(e){
  var code = e.keyCode || e.which;

  var el = $("#editable")[0];
  var lines = $("#editable > *");
  
  var currLine = getCurrentLine(el);
  console.log(currLine);
  
  if (code == 13){
 //   caretPos++;
    currLine++;
    //console.log("he"+currLine);
  }
  else{
   // lineText += String.fromCharCode(code);
   // alert(String.fromCharCode(code));
  }

  checkChangedLine(currLine);
  //so, whenever I make changes to a line that's not a backspace, send its complete self to the parser, to do its best with
    //on the parser side, I don't want to just endlessly create shit... don't change to new element unless ordered to?
  //keep track of previous line number, so if backspace is hit, I can know whether or not a whole line is gone. 
}

function upFunction(e){
  code = e.code || e.which;
  
  //I believe these two are equivalent
  //var el = $("#editable")[0];
  var el = this;
  var currLine = 0;

  var sel = rangy.getSelection();
  var range = sel.getRangeAt(0);
  var cursorOffset = sel.focusOffset;
  //var cursorNode = sel.focusNode;
 // console.log("$$$"+cursorOffset);


  //delete never changes the LINE
  if ((code==8) || (code==46) || ((code >= 37) && (code <= 40))){ //kills the function if the key pressed wasn't an arrow or a del/backsp.
    currLine = getCurrentLine(el);
    if (cursorOffset == 0){
     currLine++;
    }
    console.log("bb"+currLine);
    checkChangedLine(currLine);
  }

  return;
}

function clickFunction(e){
  var currLine = getCurrentLine(this);
  checkChangedLine(currLine);
}

$( document ).ready(function() {
   $ ('#editable').get(0).onkeypress= pressFunction;
   $ ('#editable').get(0).onkeyup= upFunction;
   $ ('#editable').get(0).onclick= clickFunction;
   $ ('#ajtest').get(0).onclick= updateElements;
  // $ ('#work_markup').get(0).onkeypress= pressFunction;
});


//$(#editable).keypress(function(){
 // alert("shoo");
//});

$(loadCy = function(){
1
  options = {
    layout: {
      name: 'arbor',
      liveUpdate: true, // whether to show the layout as it's running
      ready: undefined, // callback on layoutready 
      stop: undefined, // callback on layoutstop
      maxSimulationTime: 4000, // max length in ms to run the layout
      fit: true, // reset viewport to fit defaualt simulationBounds
      padding: [ 50, 50, 50, 50 ], // top, right, bottom, left
      simulationBounds: undefined, // [x1, y1, x2, y2]; [0, 0, width, height] by defaualt
      ungrabifyWhileSimulating: true, // so you can't drag nodes during layout

      // forces used by arbor (use arbor defaualt on undefined)
      repulsion: undefined,
      stiffness: undefined,
      friction: undefined,
      gravity: true,
      fps: undefined,
      precision: undefined,

      // static numbers or functions that dynamically return what these
      // values should be for each element
      nodeMass: undefined,
      edgeLength: undefined,

      stepSize: 1, // size of timestep in simulation

      // function that returns true if the system is stable to indicate
      // that the layout can be stopped
      stableEnergy: function( energy ){
          var e = energy;
          return (e.max <= 0.5) || (e.mean <= 0.3);
      }
    },

    showOverlay: false,
    panningEnabled: true,
    boxSelectionEnabled: false,
    minZoom: 0.5,
    maxZoom: 2,

    style: cytoscape.stylesheet()
      .selector('node')
        .css({
          'content': 'data(title)',
          'font-family': 'helvetica',
          'font-size': 14,
          
          'width': 'mapData(weight, 30, 80, 20, 50)',
          'height': 'mapData(height, 0, 200, 10, 45)',
          'z-index' : 1
        })
    
      .selector(':selected')
        .css({
          'background-color': '#000',
          'line-color': '#000',
          'target-arrow-color': '#000',
          'text-outline-color': '#000'
        })
      .selector('edge')
        .css({
          'width': 3,
          'target-arrow-shape': 'none'
        })
      .selector('.starting')
        .css({
          'text-outline-width': 3,
          'text-outline-color': 'data(color)',
          'border-color':'data(color)',
          'border-width':3,
          'background-color': '#fff',
          'text-valign': 'center',
          'text-halign' : 'center',
          'color': '#fff',
          'font-size':"16px",
          'height':"30px",
         
          //this needs to be there, otherwise it doesn't draw the notes correctly the first time.
          'note-font-size': "16px",
          'note-font-weight': "bold",
          'note-text-outline-width': 0,
          
        })
      .selector('.focused')
       .css({
          'width' : '300px',
          'height' : 'auto',
          'shape' : 'roundrectangle',
          'border-width' : "3px",
          'border-color' : "data(color)",
          'background-color' : '#fff',
          'background-opacity' : 1,
          "opacity" : 1,
          "z-index" : 5,

          'content' : 'data(title)',
          'text-outline-width': 3,
          'text-outline-color': 'data(color)',
          'color': '#fff',
          'text-valign' : "top",
          'font-size':"18px",

          'notes': 'data(notes)',
          'note-text-outline-width': 0,
          'note-text-outline-color':"#fff",
          'note-color': '#444',
          'note-font-size': "16px",
          'note-font-weight': "bold",
        })
      .selector('.less-focused')
        .css({
          'z-index' : 3,
          'background-color':"#dddddd"
        })

      .selector('.faded')
        .css({
          'opacity': 0.9,
          'text-opacity': 0.9,
          'z-index': 1,
       }),



    
    elements:gon.elements,

    ready: function(){
      window.cy = this;
      cy.elements().unselectify();

      //centers the node further from the middle when clicking edge
      cy.on('tap', 'edge', function(e){
        var edge = e.cyTarget;
        var src = edge.source();
        var targ = edge.target();

        //center of canvas
        var cont = $('#cy')[0];
        //var cont = document.getElementById(cy);
        var cent_x = (cont.offsetWidth)/2;
        var cent_y = (cont.offsetHeight)/2;
     
        //x and y of the two nodes
        var src_x = src.renderedPosition("x");
        var src_y = src.renderedPosition("y");
        var targ_x = targ.renderedPosition("x");
        var targ_y = targ.renderedPosition("y");
       
        //distance function, sans sqrt
        var src_dist = (cent_x - src_x) * (cent_x - src_x) + (cent_y - src_y) * (cent_y - src_y);
        var targ_dist = (cent_x - targ_x) * (cent_x - targ_x) + (cent_y - targ_y) * (cent_y - targ_y);

        //whichever node is further away, center it
        if (src_dist >= targ_dist){
          cy.center(src);
        } else {
          cy.center(targ);
        }

      });
      
      //bring focus to the element as they're clicked, prioritizing the most recent click
      cy.on('tap', 'node', function(e){
        var curr_node = e.cyTarget; 
        var prev_foci = cy.elements('node.focused');

        prev_foci.not(curr_node).addClass('less-focused'); //middleground all focused nodes except current

        if (curr_node.hasClass('less-focused')){ //if it's been middlegrounded, foreground
          curr_node.removeClass('less-focused');
        } 
        else { //otherwise, swap between foreground and background
          curr_node.toggleClass('focused');
        }
      });

      //resets the nodes when background is clicked
      cy.on('tap', function(e){
        if( e.cyTarget === cy ){
          cy.elements().removeClass('focused');
          cy.elements().removeClass('less-focused');
        }
      });

      cy.on('load', function(e) {
        cy.elements().addClass("starting");
      });

    }
  };
  $('#cy').cytoscape(options);
});
//THIS IS THE FORMATTING I USED IN THE VIEW
/* 
$('#cy').cytoscape({
  layout: {
    name: 'arbor',
    liveUpdate: false, // whether to show the layout as it's running
    ready: undefined, // callback on layoutready 
    stop: undefined, // callback on layoutstop
    maxSimulationTime: 4000, // max length in ms to run the layout
    fit: true, // reset viewport to fit defaualt simulationBounds
    padding: [ 50, 50, 50, 50 ], // top, right, bottom, left
    simulationBounds: undefined, // [x1, y1, x2, y2]; [0, 0, width, height] by defaualt
    ungrabifyWhileSimulating: true, // so you can't drag nodes during layout

    // forces used by arbor (use arbor defaualt on undefined)
    repulsion: undefined,
    stiffness: undefined,
    friction: undefined,
    gravity: true,
    fps: undefined,
    precision: undefined,

    // static numbers or functions that dynamically return what these
    // values should be for each element
    nodeMass: undefined,
    edgeLength: undefined,

    stepSize: 1, // size of timestep in simulation

    // function that returns true if the system is stable to indicate
    // that the layout can be stopped
    stableEnergy: function( energy ){
        var e = energy;
        return (e.max <= 0.5) || (e.mean <= 0.3);
    }
  },

  style: cytoscape.stylesheet()
    .selector('node')
      .css({
        'content': 'data(title)',
        'text-valign': 'center',
        'color': 'white',
        'text-outline-width': 2,
        'text-outline-color': '//888'
      })
    .selector('edge')
      .css({
        'target-arrow-shape': 'triangle'
      })
    .selector(':selected')
      .css({
        'background-color': 'black',
        'line-color': 'black',
        'target-arrow-color': 'black',
        'source-arrow-color': 'black'

      })

    .selector('.faded')
      .css({
        'opacity': 0.25,
        'text-opacity': 0
      })

    .selector('.largeNode')
      .css({
        'width' : '100px',
        'height' : '100px'
      }),

  elements: {
    nodes: [
      { data: { id: 'j', title: 'Jerry' } },
      { data: { id: 'e', title: 'Elaine' } },
      { data: { id: 'k', title: 'Kramer' } },
      { data: { id: 'g', title: 'George' } }
    ],
    edges: [
      { data: { source: 'j', target: 'e' } },
      { data: { source: 'j', target: 'k' } },
      { data: { source: 'j', target: 'g' } },
      { data: { source: 'e', target: 'j' } },
      { data: { source: 'e', target: 'k' } },
      { data: { source: 'k', target: 'j' } },
      { data: { source: 'k', target: 'e' } },
      { data: { source: 'k', target: 'g' } },
      { data: { source: 'g', target: 'j' } }
    ]
  },
  
    ready: function(){
      window.cy = this;
      
      cy.elements().unselectify();
      
      cy.on('tap', 'node', function(e){
        var node = e.cyTarget;
        var neighborhood = node.neighborhood().add(node);
        
        cy.nodes().addClass('faded');
        cy.nodes().removeClass('faded');
        node.toggleClass('largeNode');
      });
      
      cy.on('tap', function(e){
        if( e.cyTarget === cy ){
          cy.nodes().removeClass('faded');
          cy.nodes().removeClass('largeNode');
        }
      });

  }

}); */