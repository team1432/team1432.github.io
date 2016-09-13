nav = document.querySelectorAll('header.page-header')[0]
window.onscroll = ->
  if window.pageYOffset > 150
    nav.classList.add 'start'
  else
    nav.classList.remove 'start'
  return
