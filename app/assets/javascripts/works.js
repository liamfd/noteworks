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
    minZoom: 0.5,
    maxZoom: 2,

    style: cytoscape.stylesheet()
      .selector('node')
        .css({
          'node_title': 'data(title)',
          'font-family': 'helvetica',
          'font-size': 14,
          'text-outline-width': 3,
          'text-outline-color': '#888',
          'text-valign': 'center',
          'color': '#fff',
          'width': 'mapData(weight, 30, 80, 20, 50)',
          'height': 'mapData(height, 0, 200, 10, 45)',
          'border-color': '#fff'
        })
      .selector('.largeNode')
       .css({
          'node_title' : 'data(title)',
          'content': 'data(notes)',
          'width' : '300px',
          'height' : '300px',
          'shape' : 'roundrectangle',
          'text-valign' : "top",
          'border-width' : "3px",
          'border-color' : "#999",
          'background-color' : '#fff'
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
          'width': 2,
          'target-arrow-shape': 'none'
        })
      .selector('.faded')
        .css({
          'opacity': 0.25,
          'text-opacity': 0
       }),

    
    elements:gon.elements,

    ready: function(){
      window.cy = this;
  
      cy.elements().unselectify();
    
      cy.on('tap', 'node', function(e){
        var node = e.cyTarget;
        var neighborhood = node.neighborhood().add(node);
        node.toggleClass('largeNode');
      });
      
      cy.on('tap', function(e){
        if( e.cyTarget === cy ){
          cy.nodes().removeClass('faded');
          cy.nodes().removeClass('largeNode');
        }
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