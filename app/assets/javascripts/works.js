// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
var i = 0;
var lineText = "";
var prevLine = 0;
var num_lines = 0;
var test_data;
var changes_made;
var num_lines_selected = 1; //default is one, when no selection count the cursor


$( document ).ready(function() {
  num_lines = getNumLines();
  changes_made = false;
  test_data = {};

//  $ ('#work_markup').get(0).onkeypress= pressFunction;
  $ ('#work_markup').get(0).onkeyup= upFunction;
  $ ('#work_markup').get(0).onclick= clickFunction;
  $ ('#work_markup').get(0).onselect= selectFunction;

  var ele = gon.elements;
  ele = JSON.stringify(ele);
  $( ".test" ).text(ele);
});


//function called on keyup. Should fix it. Mostly just determine between deletes and insertions.
function upFunction(e){
  var code = e.code || e.which;
  //alert(code);

  var el = this;
  if (el == undefined)
    return;

  var curr_num_lines = getNumLines();
  var num_lines_changed = curr_num_lines - num_lines;
/*  console.log("curr_num_lines" + curr_num_lines);
  console.log("num_lines" + num_lines);
  console.log("num_lines_changed" + num_lines_changed);
*/
  var text;
  currLine = getCurrentLine(el);
  curr_line = currLine;
  prev_line = prevLine;
  text = getLineText(prevLine);

  /*console.log("currLine:" + currLine);
  console.log("prevLine:" + prevLine);
  console.log("text:" + text);
*/
//  alert(code);

  if ((code < 37) || (code > 40)){ //if it's not an arrow key, assume something has been changed
    changes_made = true;
  }

  console.log("num_lines_changed:" + num_lines_changed);
  console.log("num_lines_selected:" + num_lines_selected);

  if (num_lines_changed !== 0 || num_lines_selected !== 1){ //if the current number of lines has changed, or we selected some
    
    //if adding or only modifying
    if (num_lines_changed >= 0){ // if some have been added
      num_lines_changed = curr_line - prev_line+1; //only works b/c you always add down, use the +1 to account for last line
      num_lines_modified = num_lines_selected;
    //  console.log("modified"+num_lines_modified);

      total_changes = getChanges(num_lines_changed, num_lines_modified);
    //  console.log("added_lines" + total_changes.change_line_nums);
    // console.log("mod_lines" + total_changes.mod_line_nums);
    }

    //if deleting
    else if (num_lines_changed < 0){ //if some have been deleted
      num_lines_deleted = Math.abs(num_lines_changed);
      //always at least modify the first line, perhaps more
      num_lines_modified = Math.max(1, num_lines_selected-num_lines_deleted); //modifying all selected lines not being deleted
      num_lines_changed = num_lines_deleted + num_lines_modified;// + Math.abs(curr_line-prev_line);
      //the first line will always be modified, and it always goes up to this
      //so if deleting one line, you always modify the first and delete the second. otherwise, modify the first, deal with rest
      //because when you delete, you wind up on the first line being deleted, so always mod that, don't delete it

    //  console.log("deleted" + num_lines_deleted);
    //  console.log("modified"+ num_lines_modified);
    //  console.log("changed" + num_lines_changed);
    
      total_changes = getChanges(num_lines_changed, num_lines_modified);
    //  console.log("deleted_lines" + total_changes.change_line_nums);
    //  console.log("mod_lines" + total_changes.mod_line_nums);
    }

   // console.log("switched from " + prevLine + "to " + currLine);
  }

  else if (checkLineChanged(currLine)){ //otherwise, if I've just changed lines
    if (changes_made){ //if he's not just arrowing around
      text = getLineText(prevLine);
      //updateElement(prevLine, text);
      console.log("doing shit!");
      changes_made = false;
    }

    prevLine = currLine;
  }

  prevLine = currLine;
  num_lines = curr_num_lines;
  num_lines_selected = 1;

  console.log("--------------");

  return;
}

//returns a collection of the changed lines, those modified and those added or deleted ("changed")
function getChanges(change_length, mod_point){
  mod_line_nums = [];
  mod_line_text = [];
  change_line_nums = [];
  change_line_text = [];

  var starting_ind = Math.min(prev_line, curr_line);

  //runs from the prev_line up past curr_line to all ones being changed (added or deleted)
  for (i=0; i < change_length; i++){
    line_ind = starting_ind+i;
    console.log("i:" + i + " line_ind:" + line_ind);
    if (i < mod_point){ //before the threshold where you start adding
      mod_line_nums.push(line_ind);
      mod_line_text.push(getLineText(line_ind));
      console.log("mod");
    }
    else{
      change_line_nums.push(line_ind);
      change_line_text.push(getLineText(line_ind));
      console.log("change");
    }
  }
  return{
    mod_line_nums: mod_line_nums,
    mod_line_text: mod_line_text,
    change_line_nums: change_line_nums,
    change_line_text: change_line_text
  };
}

//function called on click. Gets the current line and sends it to checkChanged
function clickFunction(e){
  var currLine = getCurrentLine(this);
//  checkLineChanged(currLine);
//  if (this == undefined)
//    return;
  num_lines_selected = 1; //returns to default, in case just clicking, if it is selected that's taken care of in subsequent onselect
  prevLine = currLine;
}

//returns the number of lines being selected
function selectFunction(e){

  console.log(e);
  var range = getInputSelection(e.srcElement);
  console.log("Range: " + range.start + "," + range.end);
  var start_line = getLineNumber(range.start, e.srcElement);
  var end_line = getLineNumber(range.end, e.srcElement);

  console.log(start_line +"  " + end_line);
  num_lines_selected = Math.abs(end_line - start_line) + 1;
  return (num_lines_selected); //returns the number of lines highlighted, +1 so counts the first line
}


//ajax call that takes in a line number and its text, and sends them to the modelements function in the works controller
function updateElement(line_num, text){
  console.log("update" + line_num + text);
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


  //delete the edges
  for (i = 0; i < data.remove_edges.length; i++){
    rem_edge = data.remove_edges[i];
    if ((rem_edge != null) && (rem_edge != undefined)){
      edge_id_string = "#" + rem_edge.id;
      cy.remove(edge_id_string);
    }
  }

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
      console.log(mod_node);
      cy.add({
        group: "nodes",
        data: mod_node,
        position:{ x: pos_x, y: pos_y}
      }).addClass("starting");
    
    }
  }

  

  pos_y = 50; //these two will be random
  pos_x = 60;

  //delete the nodes
  var rem_node;
  for (i = 0, len = data.remove_nodes.length; i < len; ++i){
    rem_node = data.remove_nodes[i];
    if ((rem_node != null) && (rem_node != undefined) && rem_node.id !== null){
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

  //add the edges being modified (WILL PROBABLY DROP THIS AS WELL)
  for (i = 0; i < data.modify_edges.length; i++){
    mod_edge = data.modify_edges[i];
    console.log(mod_edge);
    if ((mod_edge != null) && (mod_edge != undefined)){
      mod_edge.id = data.modify_edges[i].id.toString();
      mod_edge.source = data.modify_edges[i].source.toString();
      mod_edge.target = data.modify_edges[i].target.toString();
      console.log(mod_edge);
     
      //maybe have this check instead that both nodes exist in the graph, otherwise you get an error
       console.log("source:" + mod_edge.source + " target" + mod_edge.target + " id: " + mod_edge.id)
      if ( mod_edge.source !== "" && mod_edge.target !== "" && mod_edge.id !== "" ){ //ignore if edge goes nowhere
        cy.add({
          group: "edges",
          data: mod_edge
        });
      }
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
      console.log("source:" + add_edge.source + " target" + add_edge.target + " id: " + add_edge.id)
      if ( add_edge.source !== "" && add_edge.target !== "" && add_edge.id !== "" ){ //ignore if edge goes nowhere
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
  var caret_pos = $("#work_markup").getCursorPosition();
  return getLineNumber(caret_pos, el);



  /*if (caretPos == null)
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
  return currLine;*/
}


function getLineNumber(pos, el){
  if (pos == null)
    return -1;
  //console.log(caretPos);

  var curr_line = 0;
  var text = "";
  if (el != undefined){
    text = el.value;
  }

  //go through, checking for a newline, adding one for each
  for (var i = 0; i < pos; i++){
    if (text[i] == "\n"){
      curr_line++;
    }
  }
  return curr_line;
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

//GETTING THE SELECTION
function getInputSelection(el) {
    var start = 0, end = 0, normalizedValue, range,
        textInputRange, len, endRange;

    if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
        start = el.selectionStart;
        end = el.selectionEnd;
    } else {
        range = document.selection.createRange();

        if (range && range.parentElement() == el) {
            len = el.value.length;
            normalizedValue = el.value.replace(/\r\n/g, "\n");

            // Create a working TextRange that lives only in the input
            textInputRange = el.createTextRange();
            textInputRange.moveToBookmark(range.getBookmark());

            // Check if the start and end of the selection are at the very end
            // of the input, since moveStart/moveEnd doesn't return what we want
            // in those cases
            endRange = el.createTextRange();
            endRange.collapse(false);

            if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                start = end = len;
            } else {
                start = -textInputRange.moveStart("character", -len);
                start += normalizedValue.slice(0, start).split("\n").length - 1;

                if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
                    end = len;
                } else {
                    end = -textInputRange.moveEnd("character", -len);
                    end += normalizedValue.slice(0, end).split("\n").length - 1;
                }
            }
        }
    }

    return {
        start: start,
        end: end
    };
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