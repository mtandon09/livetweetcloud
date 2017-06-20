// Mayank Tandon - July 2014
// This creates an output binding that Shiny uses to interact with
// the word cloud JS library
// A lot borrowed from: https://github.com/jcheng5/shiny-js-examples/blob/master/output/www/linechart-binding.js
// and from Jason Davies' word cloud example (http://www.jasondavies.com/wordcloud/cloud.js?201402)

// Put code in an Immediately Invoked Function Expression (IIFE).
// This isn't strictly necessary, but it's good JavaScript hygiene.
(function() {  
  // First create a generic output binding instance, then overwrite
  // specific methods whose behavior we want to change.
  var binding = new Shiny.OutputBinding();
  var mycloud = d3.layout.cloud(),
      fontSize;
  
  binding.find = function(scope) {
    // For the given scope, return the set of elements that belong to
    // this binding.
    return $(scope).find(".d3-wordcloud");
  };

  binding.renderValue = function(el, data) {
  // This function will be called every time we receive new output
  // values from Shiny. The "el" argument is the
  // div for this particular chart.
  
  var fill = d3.scale.category20();
  var textColor = d3.scale.linear()
    .domain([1,100])
    .range(["white", "blue"]);
    
  var width = 800, 
      height = 800;
  
   //var mycloud = d3.layout.cloud()
   mycloud
      .size([width, height])
      .timeInterval(10)
      .words(worddata)
      //.rotate(function() { return ~~(Math.random() * 2) * 90; })
      .rotate(0)
      .font("Impact")
      .fontSize(function(d) { return fontSize(+d.size); })
      //.fontSize(function(d) { return d.size; })
      .text(function(d) { return d.text; })
      //.on("word",draw);
      .on("end", draw);
      //.start();
            
  var svg = d3.select(el).insert("svg",":first-child")
      .attr("width", width)
      .attr("height", height);
  
  var background = svg.append("g"),
      vis = svg.append("g")
      .attr("transform", "translate(" + [width >> 1, height >> 1] + ")")
      .attr('cx', width)
      .attr('cy', height);
      
  var worddata = [],
      scaleFactor = 1;  
  
  var myfile = data;
      //refreshTime = 3000;  // in milliseconds
    
  //var interval = setInterval(function() {
      
      readCloud(myfile);
      
  //}, refreshTime);
  
  function readCloud(filename) {
      console.log("Loading csv...");
      console.log(filename);
      //console.log("Hello from R! (jk)");
      d3.csv(filename, function(data) {
        //console.log(data);
        console.log(data);
        worddata = data.map( function(d) {
          return { text: d.text, size: d.size};
        });
        console.log(worddata);
        fontSize = d3.scale.sqrt().range([10, 100]);
        //console.log(+worddata[0].size)
        if (worddata.length) fontSize.domain([+worddata[worddata.length - 1].size || 1, +worddata[0].size]);
        //console.log(worddata);
        mycloud
          .words(worddata)
          .start();
            
        });
  }        
  
  function draw(drawData,bounds) {
    //statusText.style("display", "none");
    scale = bounds ? Math.min(
        width / Math.abs(bounds[1].x - width / 2),
        width / Math.abs(bounds[0].x - width / 2),
        height / Math.abs(bounds[1].y - height / 2),
        height / Math.abs(bounds[0].y - height / 2)) / 2 : 1;
    words = drawData;
    //if (drawData[0].text==undefined) {
      //console.log("Skipping draw...");
      //return;
    //}
    //console.log(drawData);
    var text = vis.selectAll("text")
        .data(words, function(d) { return d.text.toLowerCase(); });
    text.transition()
        .duration(800)
        //.attr("transform", function(d) { return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")"; })
        .attr("transform", function(d) { return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")"; })
        .style("font-size", function(d) { return d.size + "px"; });
    text.enter().append("text")
        .attr("text-anchor", "middle")
        .attr("transform", function(d) { return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")"; })
        .style("font-size", function(d) { return d.size + "px"; })
        //.on("click", function(d) {
        //  load(d.text);
        //})
        .style("opacity", 1e-6)
      .transition()
        .duration(500)
        .style("opacity", 1);
    text.style("font-family", function(d) { return d.font; })
        //.style("fill", function(d) { return fill(d.text.toLowerCase()); })
        .style("fill", function(d) { return textColor(d.size); })
        .text(function(d) { return d.text; });
    var exitGroup = background.append("g")
        .attr("transform", vis.attr("transform"));
    var exitGroupNode = exitGroup.node();
    text.exit().each(function() {
      exitGroupNode.appendChild(this);
    });
    exitGroup.transition()
        .duration(1000)
        .style("opacity", 1e-6)
        .remove();
    vis.transition()
        .delay(750)
        .duration(500)
        .attr("transform", "translate(" + [width >> 1, height >> 1] + ")scale(" + scale + ")");
  }
};

// Tell Shiny about our new output binding
Shiny.outputBindings.register(binding, "mtandon.d3-wordcloud");

Shiny.addCustomMessageHandler("updateWordcloud", 
  function(inputdata){
    //console.log("hello");
    //var worddata = mycloud.words;
    //console.log(inputdata);
    var data = inputdata[0];
    var numtweets = inputdata[1];
    var worddata = [];
    for (i = 0; i < data.text.length; i++) {
        //console.log(data.text[i]);
        worddata.push({text: data.text[i], size: data.size[i]})
    }
    console.log(worddata);
    fontSize = d3.scale.linear().range([10, 100]);
    if (worddata.length) fontSize.domain([+worddata[worddata.length - 1].size || 1, +worddata[0].size]);
    
    mycloud.words(worddata).start();
    
    outputElement = d3.select("#tweetStatus").text(numtweets + " tweets parsed...");
    //var worddata = readData.map( function(d) {
    //    return { text: d.text, size: d.size};
    //});
    
    //var worddata = data.map( function(d) {
    //    return { text: d.text, size: d.size};
    //  });
    //console.log(worddata);
  }
);

Shiny.addCustomMessageHandler("statusMessage", 
  function(data){
    outputElement = d3.select("#status").text(data);
  }
);

})();
