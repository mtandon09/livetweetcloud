var fill = d3.scale.category20();

var cityData = [], 
    width = 800, 
    height = 600;
    
var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

var background = svg.append("g"),
    vis = svg.append("g")
    .attr("transform", "translate(" + [width >> 1, height >> 1] + ")");
    
var myfile = "us-cities.csv"
    refreshTime = 1500;
    
var mycloud = d3.layout.cloud()
            .size([width, height])
            .timeInterval(10)
            .words(cityData)
            .rotate(function() { return ~~(Math.random() * 2) * 90; })
            .font("Impact")
            .fontSize(function(d) { return d.size; })
            .on("end", draw);
            //.start();
            

//var interval = setInterval(function() {
//    var value = Math.random() * 100;
//    data.push({time: ++t, value: value});
//    redraw();
//}, 1000);
var interval = setInterval(function() {
    console.log("Loading csv...");
    readCloud(myfile);
}, refreshTime);

//function readCloud(filename,refreshTime) {
function readCloud(filename) {
    if ((cityData) && (cityData.length > 50)) {
        console.log("Resetting Cities...");
        cityData = [];
    }
    d3.csv(filename, function(data) {
        // build the list of city names
        for (i = 0; i < 3; i++) {
            var currInd = Math.floor(Math.random()*data.length);
            cityData.push(data[currInd].place);
        }
        //data.forEach( function (d) {
        //    cityData.push(d.place);
        //});
        
        var worddata = cityData.map(function(d) {
            return {text: d, size: 10 + Math.random() * 90};
        })
        console.log(worddata);
        mycloud.words(worddata)
        .start();
        
        //setInterval(function() {
        //  worddata = randomizeSize(worddata);
        //  mycloud.words(worddata)
        //         .start();
        //}, refreshTime);
        
    });
}

//function randomizeSize(clouddata) {
//  console.log("Randomizing...");
//  clouddata.forEach( function(entry) {
//    entry.size = 10 + Math.random() * 90;
//    })
//  return(clouddata);
//}


function draw(words,bounds) {
//d3.select("body").append("svg")
  //statusText.style("display", "none");
  scale = bounds ? Math.min(
      width / Math.abs(bounds[1].x - width / 2),
      width / Math.abs(bounds[0].x - width / 2),
      height / Math.abs(bounds[1].y - height / 2),
      height / Math.abs(bounds[0].y - height / 2)) / 2 : 1;
  //words = data;
  var text = vis.selectAll("text")
      .data(words, function(d) { return d.text.toLowerCase(); });
  text.transition()
      .duration(1000)
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
      .duration(1000)
      .style("opacity", 1);
  text.style("font-family", function(d) { return d.font; })
      .style("fill", function(d) { return fill(d.text.toLowerCase()); })
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
      .delay(1000)
      .duration(750)
      .attr("transform", "translate(" + [width >> 1, height >> 1] + ")scale(" + scale + ")");
      //.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
}