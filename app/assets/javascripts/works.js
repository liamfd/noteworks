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
  //page interactivity
  $("#toggle").click(function(){
    $("#panel").slideToggle("slow");
    });

  $("#guide-button").click(function(){
    $(document).foundation('joyride', 'start');
  });
  dragHeight();


  //observing
  num_lines = getNumLines();
  changes_made = false;
  test_data = {};
  if ($("#work_markup").length !== 0){
    $ ('#work_markup').get(0).onkeyup= upFunction;
    $ ('#work_markup').get(0).onclick= clickFunction;
    $ ('#work_markup').get(0).onselect= selectFunction;
  }
});











/**
*  PAGE INTERACTIVITY
*/

//drag the terminal bar to adjust the form height (does the entire bottom)
function dragHeight(){
  $('#bar').on('mousedown', function(e){
    var $markup_text = $ ("#work_markup"),
        startConsoleHeight = $markup_text.height(),
        pY = e.pageY;
    
    $(document).on('mouseup', function(e){
        $(document).off('mouseup').off('mousemove');
    });
    $(document).on('mousemove', function(me){
      var my = (me.pageY - pY);
      var consoleHeight = startConsoleHeight-my;
   
      $markup_text.css({
        height: consoleHeight,
      });
    });
  });
}

function submitForm(){
  $(this).parents("form").submit();
}

function toggleSpinner(){
  $("#spinner").toggle();
}

//sets the stuff for works/:id/categories
$(function() {
  $('#myModal').bind('opened', function() {
    //this could also go in a ajaxComplete global call
    if ( $(".edit_form").length !== 0 ){
      $(".edit_form").find('#category_name').get(0).onblur= submitForm;
      $(".edit_form").find('#category_color').get(0).onblur= submitForm;
    }
    $("#spinner").hide();

    $.minicolors.defaults = $.extend($.minicolors.defaults, {
      changeDelay: 200,
      defaultValue: "#c0c0c0",
      position: "bottom left"
    });

    $('#category_color').minicolors();

    $("form").bind("ajax:beforeSend", function(){
      $("#spinner").show();
      $("#response").hide();
    });
    $("form").bind("ajax:success", function(evt, data, status, xhr){
      $("#response").html("Saved!").show().fadeOut("slow");
      test_data = data;
    });
    $("form").bind("ajax:complete", function(){
      $("#spinner").hide();
      //$('#myModal').foundation('reveal', 'close');
    });

    $(".new_form form").bind("ajax:complete", function() {
      $('#myModal').foundation('reveal', 'close');
    });

    $("form").bind("ajax:error", function(xhr, ajaxOptions, thrownError){
      //find a way to get the actual error being returned by the rails controller
      $("#response").html("Error: Repeated name.").show().fadeOut("slow");
      $("#spinner").hide();
    });
    $(document).foundation();
  });
});










/**
* LIVE UPDATING WATCH AND RESPONSE
*/

/**
* Function called on keyup. This function now uses the changes in length and the selections made to determine whether changes
* have been made, and calls the appropriate functions. An improvement over the original, which used specific buttons presses
* to determine changes.
*/
function upFunction(e){
  var code = e.code || e.which;
  //alert(code);
  var el = this;
  if (el == undefined)
    return;

  var curr_num_lines = getNumLines();
  var num_lines_changed = curr_num_lines - num_lines;

  var text;
  currLine = getCurrentLine(el);
  curr_line = currLine;
  prev_line = prevLine;
  text = getLineText(prevLine);

  if ((code < 37) || (code > 40)){ //if it's not an arrow key, assume something has been changed
    changes_made = true;
  }

  if (changes_made){ //if things have changed
    if (num_lines_changed !== 0 || num_lines_selected !== 1){ //if the current number of lines has changed, or we selected some
      if (num_lines_changed > 0){ // if some have been added
        num_lines_changed = curr_line - prev_line+1; //only works b/c you always add down, use the +1 to account for last line
        num_lines_modified = num_lines_selected;

        total_changes = getChanges(num_lines_changed, num_lines_modified);
        modElement(total_changes.mod_line_nums, total_changes.mod_line_text);
        addElement(total_changes.change_line_nums, total_changes.change_line_text);
      }

      //if deleting
      else if (num_lines_changed < 0){ //if some have been deleted
        num_lines_deleted = Math.abs(num_lines_changed);
        // if deleting one line, you always modify the first and delete the second. otherwise, modify the first, deal with rest
        num_lines_modified = Math.max(1, num_lines_selected-num_lines_deleted); //modifying all selected lines not being deleted
        num_lines_changed = num_lines_deleted + num_lines_modified;// + Math.abs(curr_line-prev_line);
        total_changes = getChanges(num_lines_changed, num_lines_modified);
        
        modElement(total_changes.mod_line_nums, total_changes.mod_line_text);
        delElement(total_changes.change_line_nums, total_changes.change_line_text);
      }
      else{
        num_lines_changed = curr_line - prev_line+1; //use the +1 to account for last line
        num_lines_modified = num_lines_selected;
        total_changes = getChanges(num_lines_changed, num_lines_modified);
        
        modElement(total_changes.mod_line_nums, total_changes.mod_line_text);
      }
      changes_made = false;
    }

    else if (checkLineChanged(currLine)){ //otherwise, if he's just changed lines
      text = getLineText(prevLine);
      modElement(prevLine, text);
      changes_made = false;
    }
  }
  prevLine = currLine;
  num_lines = curr_num_lines;
  num_lines_selected = 1;
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
    if (i < mod_point){ //before the threshold where you start adding
      mod_line_nums.push(line_ind);
      mod_line_text.push(getLineText(line_ind));
    }
    else{
      change_line_nums.push(line_ind);
      change_line_text.push(getLineText(line_ind));
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
  num_lines_selected = 1; //returns to default, in case just clicking, if it is selected that's taken care of in subsequent onselect
  prevLine = currLine;
}

//returns the number of lines being selected
function selectFunction(e){
  var range = getInputSelection(e.srcElement);
  var start_line = getLineNumber(range.start, e.srcElement);
  var end_line = getLineNumber(range.end-1, e.srcElement); //end is inclusive, make it exclusive with -1

  num_lines_selected = Math.abs(end_line - start_line) + 1;
  return (num_lines_selected); //returns the number of lines highlighted, +1 so counts the first line
}





/*CHANGE WATCHING UTILS */

//using the text and the caret position, gets the line number
function getCurrentLine(el){
  var caret_pos = $("#work_markup").getCursorPosition();
  return getLineNumber(caret_pos, el);
}

//gets the line number given a position and the DOM element
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
    if (text[i] === "\n"){
      curr_line++;
    }
  }
  return curr_line;
}

//returns the text at the given line, by breaking it into an array of strings (one each line) returning the one at lineNum
function getLineText(lineNum){
  var lines = $("#work_markup").val().split(/\r\n|\r|\n/);
  return lines[lineNum];

}

//compares the line numbers, see if it's changed
function checkLineChanged(currLine){
  if (currLine != prevLine){
    return true;
  }
  return false;
}

//returns the number of lines in work_markup's text, by splitting with a regexp and taking length
function getNumLines(){
  if ($("#work_markup").length !== 0){
    var num_lines = $("#work_markup").val().split(/\r\n|\r|\n/).length;
    return num_lines;
  }
  return 0;
}

//GETTING THE SELECTION, SRC: SO
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

//gets the caret pos for text areas, SRC: SO
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






/* AJAX CALLS */

//ajax call that takes in a line number and its text, and sends them to the modelements function in the works controller
function modElement(line_num, text){
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





/* UPDATE GRAPH */

//function that runs if the ajax is successful, will update the graph
function modInGraph(data){
//  console.log(JSON.stringify(data));
//  test_data = data;
  var pos_y;
  var pos_x;
  var edge_id_string;
  var cont = $('#cy')[0];

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
      //save the position, so the replacement can be set at it. Only one modified at a time
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
 
  //add the edges
  for (i = 0, len = data.add_nodes.length; i < len; ++i){
    add_node = data.add_nodes[i];
    if ((add_node != null) && (add_node != undefined)) {
      //add the new node
      add_node.id = add_node.id.toString();
      pos_x = Math.floor(Math.random() * (cont.offsetWidth+ 1));
      pos_y = Math.floor(Math.random() * (cont.offsetHeight+ 1));
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
    if ((mod_edge != null) && (mod_edge != undefined)){
      mod_edge.id = data.modify_edges[i].id.toString();
      mod_edge.source = data.modify_edges[i].source.toString();
      mod_edge.target = data.modify_edges[i].target.toString();
     
      //maybe have this check instead that both nodes exist in the graph, otherwise you get an error
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
    if ((add_edge != null) && (add_edge != undefined)){
      add_edge.id = data.add_edges[i].id.toString();
      add_edge.source = data.add_edges[i].source.toString();
      add_edge.target = data.add_edges[i].target.toString();
     
      //maybe have this check instead that both nodes exist in the graph, otherwise you get an error
      if ( add_edge.source !== "" && add_edge.target !== "" && add_edge.id !== "" ){ //ignore if edge goes nowhere
        cy.add({
          group: "edges",
          data: add_edge
        });
      }
    }
  }
  setTextSize(); //fix the text sizing when it's coming in
}











/** 
* CYTOSCAPE GRAPHING INIT
*/
$(loadCy = function(){
  options = {
    
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
          
          'width': 'mapData(weight, 0, 200, 10, 80)',
          'height': 'mapData(height, 0, 200, 10, 80)',
          //'width': 'mapData(weight, 30000, 0, 30, 100)',
          //'height': 'mapData(height, 30000, 0, 30, 100)',
          'background-color': "#fff",
          'z-index' : 1
        })
    
      .selector(':selected')
        .css({
          'background-color': '#fff',
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

      .selector('.big-text')
        .css({
          'font-size':30
        })

      .selector('.little-text')
        .css({
          'font-size':16

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

      cy.on('zoom', function(e){
        setTextSize();
      });

      // use when the spinner loader is showing, in conjunction with on layout stop
      cy.on('tapdrag', function(e){
        setTextSize();
      });

      /* USE THESE WHEN THE GRAPH IS SHOWN DRAWING
      //works during the layout drawing
      cy.on('position', 'node', function(e){
        setTextSize();
      });

      //when manipulating background. Not drag, that would be working double for node dragging
      cy.on('pan', function(e){
        setTextSize();
      });

       */

      //add the class, hide the graph and show the spinner when loading
      cy.on('load',function(){
        cy.elements().addClass("starting");
        cy.elements().hide();
        $("#work_load_spinner").show();
      });

      //take out the spinner and show graph when ready
      cy.on('layoutstop', function(){
        $("#work_load_spinner").fadeOut("300");
        setTextSize();
        cy.elements().show();
      });

    }
  };
  $('#cy').cytoscape(options);
});

//to be called within the cytoscape declaration. changes the size of the text as necessary
function setTextSize(){
  var nodes = cy.elements('node');
  var cont = $('#cy')[0];

  var cent_x = (cont.offsetWidth)/2;
  var cent_y = (cont.offsetHeight)/2;

  for (var i = 0; i < nodes.length; i++){
    var node = nodes[i];
    var pos = nodes[i].renderedPosition();
    
    //x and y of the two nodes
    var pos_x = node.renderedPosition("x");
    var pos_y = node.renderedPosition("y");
 
    //distance function, sans sqrt
    var cent_dist = (cent_x - pos_x) * (cent_x - pos_x) + (cent_y - pos_y) * (cent_y - pos_y);
    if (cent_dist < 50000){
      node.addClass('big-text');
      node.removeClass('little-text');
    }
    else{
      node.addClass('little-text');
      node.removeClass('big-text');
    }
  }
}