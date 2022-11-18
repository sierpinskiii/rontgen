window.onload = function () {
    var slideimg = document.getElementById("slideimg");

    function updateImage() {
        slideimg.src = "/present/slides/current?" + Math.random();
        // console.log("update");
    }

    setInterval(updateImage, 1000);
}

var slidesize = 100;

function smallerSlide() {
    var element = document.getElementById("slideimg");
    slidesize -= 5;
    element.style.width = slidesize + "%";
}
    
function largerSlide() {
    var element = document.getElementById("slideimg");
    slidesize += 5;
    element.style.width = slidesize + "%";
}
