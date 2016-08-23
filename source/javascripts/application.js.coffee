nav = document.querySelectorAll('header.page-header')[0]
window.onscroll = ->
  if window.pageYOffset > 400
    nav.classList.add 'start'
  else
    nav.classList.remove 'start'
  return
