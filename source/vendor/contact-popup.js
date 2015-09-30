$("#login, .footer-links:last-child").click(function() {

  $(".popup").fadeToggle("fast");

});

$(".inner img").click(function() {

  $(".popup").fadeOut("fast");

});

$("#popup-esc").keydown(function() {
  if ( event.which == 27 ) {
   $(".popup").fadeOut("fast");
  }
});
