controller = new ScrollMagic.Controller()

scene = new ScrollMagic.Scene (
  triggerHook: 0.8
  triggerElement: 'main .card'
  duration: 0
)
  .setClassToggle 'header.page-header', 'start'
  .addTo controller

scene.on("change update progress
 start end enter leave", console.log('hi'))
# scene.removeClassToggle(false)
