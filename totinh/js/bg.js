var image = new Array()
      image[0] = 'https://dominhhieu1405.github.io/code/totinh/img/bg1.jpg'
      image[1] = 'https://dominhhieu1405.github.io/code/totinh/img/bg2.jpg'
      image[2] = 'https://dominhhieu1405.github.io/code/totinh/img/bg3.jpg'
      image[3] = 'https://dominhhieu1405.github.io/code/totinh/img.bg4.jpg'
      image[4] = 'https://dominhhieu1405.github.io/code/totinh/img/bg5.jpg'
      image[5] = 'https://dominhhieu1405.github.io/code/totinh/img/bg6.jpg'
      image[6] = 'https://dominhhieu1405.github.io/code/totinh/img/bg7.jpg'
      image[7] = 'https://dominhhieu1405.github.io/code/totinh/img/bg8.jpg'
var p = image.length;

var chooseImage = Math.floor(Math.random() * image.length);
function ChangeBack() {
document.body.background = image[chooseImage];
document.body.style.backgroundRepeat = "repeat";
document.body.style.backgroundPosition = "top left";
}
