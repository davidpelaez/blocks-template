#alert "Je sui app.coffee"

$(document).ready ->

  $(".scroll-indicator > .icon").click (e)->
    e.preventDefault()
    targetId = $(e.target).attr('data-target')
    $target = $("##{targetId}")
    $('html, body').animate
      scrollTop: $target.offset().top
    , 1000

  scaleDivs = -> $('.viewport-height').css('height', window.innerHeight)
  $(window).resize scaleDivs
  scaleDivs()
  

  $pricingBox = jQuery('.box .copy')
  #$pricingBox.bigtext()
  #console.log "binding!"
  $('#open-menu-button').click (e)->
    e.preventDefault()
    $('#main-nav').addClass 'open'
  
  $('#close-menu-button').click (e)->
    e.preventDefault()
    $('#main-nav').removeClass 'open'

  console.log "---"