var graph_elements = {"edges":[{"data":{"id":"1836","source":"2395","target":"2394"}},{"data":{"id":"1837","source":"2396","target":"2394"}},{"data":{"id":"1838","source":"2398","target":"2397"}},{"data":{"id":"1839","source":"2399","target":"2397"}},{"data":{"id":"1840","source":"2400","target":"2397"}},{"data":{"id":"1841","source":"2401","target":"2400"}},{"data":{"id":"1842","source":"2402","target":"2400"}},{"data":{"id":"1843","source":"2403","target":"2397"}},{"data":{"id":"1844","source":"2404","target":"2397"}},{"data":{"id":"1861","source":"2394","target":"2408"}}],"nodes":[{"data":{"id":"2394","title":"","notes":"","color":"#d56b79"}},{"data":{"id":"2395","title":"","notes":"","color":"#d56b79"}},{"data":{"id":"2396","title":"","notes":"","color":"#5b29f3"}},{"data":{"id":"2397","title":"","notes":"","color":"#990000"}},{"data":{"id":"2398","title":"","notes":"","color":"#505050"}},{"data":{"id":"2399","title":"","notes":"","color":"#505050"}},{"data":{"id":"2400","title":"","notes":"","color":"#505050"}},{"data":{"id":"2401","title":"","notes":"","color":"#d56b79"}},{"data":{"id":"2402","title":"","notes":"","color":"#b33ede"}},{"data":{"id":"2403","title":"","notes":" //- also Macbeth's flaw","color":"#7ab7d6"}},{"data":{"id":"2404","title":"","notes":"","color":"#d56b79"}},{"data":{"id":"2405","title":"","notes":"","color":"#d56b79"}},{"data":{"id":"2408","title":"","notes":" //- Legendary Men, Kids //- Written By Shakespeare //- Tragedies, His Best //- Title Character","color":"#1f0099"}},{"data":{"id":"2410","title":"","notes":"","color":"#d56b79"}}]};


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
          'border-color':'#fff',
          'border-width':3,
          'background-color': 'data(color)',
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
   
    elements:graph_elements,

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
  $('#home-cy').cytoscape(options);
});