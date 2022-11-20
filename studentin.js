window.onload = function () {
    var slideimg = document.getElementById("slideimg"); 
    var slidequizz = document.getElementById("slidequizz");
    var screen = document.getElementById("screen");

    function updateScreen() {
        fetch("/present/screen")
        .then((response) => response.text())
        .then((html) => {
            document.getElementById("screen").innerHTML = html;
        })
        .catch((error) => {
            console.log("failed to retrieve the screen data";
        });
        
        // document.getElementById("screen").innerHTML = "<object type='type/html' data='/present/screen?" + Math.random() + "' ></object>";
        // slideimg.src = "/present/slides/current?" + Math.random();
        // console.log("update");
    }

    setInterval(updateScreen, 1000);
}

var slidesize = 100;

function smallerSlide() {
    // var element = document.getElementById("slideimg");
    var element = document.getElementById("screen");
    slidesize -= 5;
    element.style.width = slidesize + "%";
}
    
function largerSlide() {
    // var element = document.getElementById("slideimg");
    var element = document.getElementById("screen");
    slidesize += 5;
    element.style.width = slidesize + "%";
}
