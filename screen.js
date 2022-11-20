window.onload = function () {
    var slideimg = document.getElementById("slideimg"); 
    var slidequizz = document.getElementById("slidequizz");

    function updateScreen() {
        slideimg.src = "/present/slides/current?" + Math.random();
        console.log("update");
    }

    setInterval(updateScreen, 1000);
}
