// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
var i = 0;
var lineText = "";
var prevLine = 0;
var num_lines = 0;
var test_data;
var changes_made;


$( document ).ready(function() {
  num_lines = getNumLines();
  changes_made = false;
  test_data = {};

//  $ ('#work_markup').get(0).onkeypress= pressFunction;
  $ ('#work_markup').get(0).onkeyup= upFunction;
  $ ('#work_markup').get(0).onclick= clickFunction;

  var ele = gon.elements;
  ele = JSON.stringify(ele);
  $( ".test" ).text(ele);
});


//function called on keyup. Should fix it. Mostly just determine between deletes and insertions.
function upFunction(e){
  var code = e.code || e.which;
  //alert(code);
  //I believe these two are equivalent
  //var el = $("#editable")[0];
  var el = this;
  if (el == undefined)
    return;

  var curr_num_lines = getNumLines();
  var num_lines_changed = num_lines - curr_num_lines;
  console.log("curr_num_lines" + curr_num_lines);
  console.log("num_lines" + num_lines);
  console.log("num_lines_changed" + num_lines_changed);

  var text;
  currLine = getCurrentLine(el);
  text = getLineText(prevLine);

  console.log("currLine:" + currLine);
  console.log("prevLine:" + prevLine);
  console.log("text:" + text);

  if ((code < 37) || (code > 40)){ //if it's not an arrow key
    changes_made = true;
  }


  if (code == 13){ //if it's an enter, update old line, add new (can hit enter anywhere in line)
    //the new line is always the current line. even if entering at the beginning, your generating a new line, 
    //and moving shit to it

    curr_text = getLineText(currLine);
    //addElement(currLine, curr_text);
    
    console.log("ENTER");

    prev_text = getLineText(prevLine); //in case a change is made on the previous line, before/after linebreak
   // updateElement(prevLine, prev_text);

    num_lines = curr_num_lines;
    prevLine = currLine; //The this doesn't get updated auto on enter
  }

  else if ((code == 8) && (curr_num_lines < num_lines)){ //if it's backspace and a whole line gone
   // delElement(prevLine);
    num_lines--;
    prevLine = currLine;
    
    //console.log("backspaced line" + prevLine);
  }

  else if ((code == 46) && (curr_num_lines < num_lines)){ //if it's a del and a whole line gone
    /* FOR NOW, DELETE DISABLED, UNTIL I SOLVE THE END OF LINE VS BEGINNING OF LINE ISSUE */
    //delElement(currLine); //the server still thinks an extra thing is there
    num_lines--;
    prevLine = currLine; //probably unnecessary
   // console.log("deleted line" + currLine);
  }

  else if (checkLineChanged(currLine)){ //otherwise, if I've just changed lines
    if (changes_made){ //if he's not just arrowing around
      text = getLineText(prevLine);
    //  updateElement(prevLine, text);
      console.log("doing shit!");
      changes_made = false;
    }


    //starting at the line after the original spot, until the current spot (insertion ends)
//    for (var i = prevLine+1; i <= currLine; i++){
 //     curr_text = getLineText(i);
     // addElement(i, curr_text);
  //    console.log("Changing " , i);
  //  }

    prevLine = currLine;
   // console.log("switched from " + prevLine + "to " + currLine);
  }


  console.log("--------------");

  return;
}

//function called on click. Gets the current line and sends it to checkChanged
function clickFunction(e){
  var currLine = getCurrentLine(this);
//  checkLineChanged(currLine);
//  if (this == undefined)
//    return;
  prevLine = currLine;
}

//ajax call that takes in a line number and its text, and sends them to the modelements function in the works controller
function updateElement(line_num, text){
  console.log("update");
  $.ajax({
    type:"GET",
    url:"mod_element",
    data: {line_number: line_num, line_content: text},
    dataType:"json",
    success: function(data){
      modInGraph(data);
    }
  });
}

//ajax call that takes in a line number and its text, and sends them to the addelement function in the works controller
function addElement(line_num, text){
  console.log("add");
  $.ajax({
    type:"GET",
    url:"add_element",
    data: {line_number: line_num, line_content: text},
    dataType:"json",
    success: function(data){
      modInGraph(data);
    }
  });
}

//ajax call that takes in a line number and sends it to the delelement function in the works controller
function delElement(line_num){
  console.log("del");
  $.ajax({
    type:"GET",
    url:"del_element",
    data: {line_number: line_num},
    dataType:"json",
    success: function(data){
      modInGraph(data);
    }
  });
}


//function that runs if the ajax is successful, will eventually update the graph
function modInGraph(data){
  $("#test_box").text(JSON.stringify(data));
  
  //console.log("data=" + data);
  test_data = data;
  var pos_y; //these two will be random
  var pos_x;
  var edge_id_string;


  //delete the edges bieng modified (WILL PROBABLY DROP THIS)
  for (i = 0; i < data.modify_edges.length; i++){
    mod_edge = data.modify_edges[i];
    if ((mod_edge != null) && (mod_edge != undefined)){
      edge_id_string = "#" + mod_edge.id;
      cy.remove(edge_id_string);
    }
  }

  //modify the mod notes. Saves position, removes, adds back in with new data
  var mod_node;
  for (i = 0, len = data.modify_nodes.length; i < len; ++i){
    mod_node = data.modify_nodes[i];
    if ((mod_node != null) && (mod_node != undefined)){
      //save the position, so the replacement can be set at it
      var mod_graph_node = cy.$("#" + mod_node.id);
      pos_x = mod_graph_node.position().x;
      pos_y = mod_graph_node.position().y;
    
      cy.remove(mod_graph_node);
      mod_node.id = mod_node.id.toString();
      cy.add({
        group: "nodes",
        data: mod_node,
        position:{ x: pos_x, y: pos_y}
      }).addClass("starting");
    
    }
  }

  //add the edges being modified (WILL PROBABLY DROP THIS AS WELL)
  for (i = 0; i < data.modify_edges.length; i++){
    mod_edge = data.modify_edges[i];
    console.log(add_edge);
    if ((mod_edge != null) && (mod_edge != undefined)){
      mod_edge.id = data.mod_edges[i].id.toString();
      mod_edge.source = data.mod_edges[i].source.toString();
      mod_edge.target = data.mod_edges[i].target.toString();
      console.log(mod_edge);
     
      //maybe have this check instead that both nodes exist in the graph, otherwise you get an error
      if ((mod_edge.source != undefined) && (mod_edge.target != undefined) && (mod_edge.id != undefined)){ //ignore if edge goes nowhere
        cy.add({
          group: "edges",
          data: mod_edge
        });
      }
    }
  }

  pos_y = 50; //these two will be random
  pos_x = 60;

  //delete the edges
  for (i = 0; i < data.remove_edges.length; i++){
    rem_edge = data.remove_edges[i];
    if ((rem_edge != null) && (rem_edge != undefined)){
      edge_id_string = "#" + rem_edge.id;
      cy.remove(edge_id_string);
    }
  }

  //delete the nodes
  var rem_node;
  for (i = 0, len = data.remove_nodes.length; i < len; ++i){
    rem_node = data.remove_nodes[i];
    if ((rem_node != null) && (rem_node != undefined)){
      //save the position, so the replacement can be set at it
      var rem_graph_node = cy.$("#" + rem_node.id);
      //pos_x = rem_graph_node.position().x;
      //pos_y = rem_graph_node.position().y;
    
      cy.remove(rem_graph_node);
    }
  }
 
  //var add_node = data.add.node;
  //add the edges
  for (i = 0, len = data.add_nodes.length; i < len; ++i){
    add_node = data.add_nodes[i];
    if ((add_node != null) && (add_node != undefined)) {
      //add the new node
      add_node.id = add_node.id.toString();
    //  data.add.node.id = data.add.node.id.toString(); //convert the id to a string
      cy.add({
        group: "nodes",
        data: add_node,
        position:{ x: pos_x, y: pos_y}
      }).addClass("starting");
    }
  }

  //add the new edges, first converting their values to strings
  for (i = 0; i < data.add_edges.length; i++){
    add_edge = data.add_edges[i];
    console.log(add_edge);
    if ((add_edge != null) && (add_edge != undefined)){
      add_edge.id = data.add_edges[i].id.toString();
      add_edge.source = data.add_edges[i].source.toString();
      add_edge.target = data.add_edges[i].target.toString();
      console.log(add_edge);
     
      //maybe have this check instead that both nodes exist in the graph, otherwise you get an error
      if ((add_edge.source != undefined) && (add_edge.target != undefined) && (add_edge.id != undefined)){ //ignore if edge goes nowhere
        cy.add({
          group: "edges",
          data: add_edge
        });
      }
    }
  }

  

}


//gets the caret pos this is for text areas
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
    };
  })(jQuery);

//using the text and the caret position, gets the line number
function getCurrentLine(el){
  //var caretPos = getCaretCharacterOffsetWithin(el);
  var caretPos = $("#work_markup").getCursorPosition();
  if (caretPos == null)
    return -1;
  //console.log(caretPos);

  var currLine = 0;
  var text = "";
  if (el != undefined){
    text = el.value;
  }
  //var text = "soup"
  for (var i = 0; i < caretPos; i++){
    if (text[i] == "\n"){
      currLine++;
    }
  }
  //if it's a newline...
  //console.log("currLine: " + currLine);
  return currLine;
}

//returns the text at the given line, by breaking it into an array of strings (one each line) returning the one at lineNum
function getLineText(lineNum){
  var lines = $("#work_markup").val().split(/\r\n|\r|\n/);
//  console.log("888" + lines[lineNum]);
  return lines[lineNum];

}

//figure out what you want this to do
function checkLineChanged(currLine){
  if (currLine != prevLine){
    return true;
  }
  return false;
}

//returns the number of lines in work_markup's text, by splitting with a regexp and taking length
function getNumLines(){
  var num_lines = $("#work_markup").val().split(/\r\n|\r|\n/).length;
  return num_lines;
}







/* CYTOSCAPE STUFF */
$(loadCy = function(){
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


function EDgetLineText(currLine){
  var text = $('#editable').get(0).innerText;
  //console.log("currLine: " + currLine);
  if (currLine != 0){
    var lines = $("#editable > *");
    if (lines[currLine-1] != null)
      return lines[currLine-1].innerText;
    else //if the line number is not a real one
      return "";
  }

  else{ //if it's line 0, there is no jquery object
    //returns as soon as there's a newline. if it never hits one, just returns the entire thing
    var i;
    for (i = 0; i < text.length; i++){
      if (text[i] == "\n")
        return text.substring(0, i);
    }
    return text;
  }
}

function EDgetCurrentLine(el, caretPos){
  //var caretPos = getCaretCharacterOffsetWithin(el);
  if (caretPos == null){
    alert("wat");
    return 0;
  }
  var currLine = 0;

  var text = el.innerText;
  var text_html = el.innerHTML;
  var i;

  for (i = 0; i <= caretPos; i++){
    if (text[i] == "\n"){
      currLine++;
      caretPos++;
    }
    else{
    }
  }

  //for text input, fixes the issue with the extra newline at the end
  if (currLine >= 0 && text[caretPos-1] == "\n"){
    currLine--;
  }
  //solves issue with end of line moving cursor via arrows
  if (text[caretPos] == "\n"){
    currLine--;
  }
  //if it's a newline...
  return currLine;

}


function EDpressFunction(e){
  var code = e.keyCode || e.which;

  var el = $("#editable")[0];
  var caretPos = getCaretCharacterOffsetWithin(el);

  var currLine = getCurrentLine(el, caretPos);
  
  if (code == 13){
    currLine++;
  }

  checkChangedLine(currLine);
  //so, whenever I make changes to a line that's not a backspace, send its complete self to the parser, to do its best with
    //on the parser side, I don't want to just endlessly create shit... don't change to new element unless ordered to?
  //keep track of previous line number, so if backspace is hit, I can know whether or not a whole line is gone. 
}

function EDupFunction(e){
  code = e.code || e.which;
  
  //I believe these two are equivalent
  //var el = $("#editable")[0];
  var el = this;
  var caretPos = getCaretCharacterOffsetWithin(el);
  var currLine = 0;

  var sel = rangy.getSelection();
  var cursorOffset = sel.focusOffset;
  
  //delete never changes the LINE
  //if the key pressed wasn't an arrow or a del/backsp.
  if ((code==8) || (code==46) || ((code >= 37) && (code <= 40))){
    currLine = getCurrentLine(el, caretPos);

    //if the line by line count is 0, it's the border case, just bump it up, don't count if at first line
    if (cursorOffset == 0 && caretPos != 0){
     currLine++;
    }
    checkChangedLine(currLine);
  }
  //else if (code == 13){
  //  currLine = getCurrentLine(el, caretPos);
  //  currLine++; //since it's an enter
  //  checkChangedLine(currLine);
  //}

  return;
}

function EDclickFunction(e){
  var caretPos = getCaretCharacterOffsetWithin(this);
  var currLine = getCurrentLine(this, caretPos);

  var sel = rangy.getSelection();
  var cursorOffset = sel.focusOffset;

  //if the line by line count is 0, it's the border case, just bump it up, don't count if at first line
  if (cursorOffset == 0 && caretPos != 0){
   currLine++;
  }
  checkChangedLine(currLine);
}


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

//$(#editable).keypress(function(){
 // alert("shoo");
//});

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