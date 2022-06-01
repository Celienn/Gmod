const height = window.innerHeight
const width = window.innerWidth
var inc = 0.001

function setup(){
    createCanvas(window.innerWidth,window.innerHeight)
    //createCanvas(width,height)
}

var woff = 0
function draw(){
    background(50)
    loadPixels();
    stroke(255);
    noFill();
    var yoff = 0
    for (var y = 0; y < height; y++){
        var xoff = 0
        for (var x = 0; x < width; x++){
            var index = (x + y * width) * 4
            var random =  noise(xoff,yoff,woff)
            if ( random > 0.5 ) {
                pixels[index+0] = (random / 0.5) * (random * 10)
                pixels[index+1] = (random / 0.5) * (random * 10)
                pixels[index+2] = (random / 0.5) * (random * 70)
                pixels[index+3] = 255
            }else if ( random > 0.25 ) {
                pixels[index+0] = (random * 10) * (random / 0.5) 
                pixels[index+1] = (random * 10) * (random / 0.5)
                pixels[index+2] = (random * 70) * (random / 0.5) 
                pixels[index+3] = 255
            }else {
                pixels[index+0] = random 
                pixels[index+1] = random
                pixels[index+2] = random * 100
                pixels[index+3] = 255
            }
            xoff+=inc
        } 
        yoff-=inc
    }
    woff+=0.01
    updatePixels();
}

