videojs.options.flash.swf = "video-js.swf"
const support_format = ['.mp4', '.webm', '.ogv']
let count = 1
// 查找所有视频
$("a[href][target='_blank']").each(function () {
  let $this = $(this)
  let text = $this.text()
  let index = text.lastIndexOf('.')
  if (index >= 0) {
    let suffix = text.substring(index, text.length).toLowerCase()
    if (support_format.indexOf(suffix) >= 0) {
      // console.log(chrome.runtime)
      // console.log('格式：', suffix)
      // $this.webuiPopover({title:'Title', content: 'Content', trigger: 'hover'});
      let url = $this.attr('href')
      if (!url.startsWith('http')) {
        let port = location.port
        port = port ? (':' + port) : ''
        url = location.protocol + '//' + location.hostname + port + url
      }
      let $play = $('<a class="video-play-btn" href="javascript:;">播放</a>')
      $this.after($play)
      $play.click(function () {
        let id = 'video-player-' + (count++)
        playerHtml = '<video id="' + id + '" class="video-js vjs-default-skin vjs-big-play-centered vjs-fluid" controls preload="none" \
                        poster="http://pdm.vivo.xyz/rdms/images/logo.png"\>\
                        <source src="' + url + '" type="video/mp4" />\
                        <track kind="captions" src="demo.captions.vtt" srclang="en" label="English">\
                        <track kind="subtitles" src="demo.captions.vtt" srclang="en" label="English">\
                    </video>'
        let isLayerIframe = !!getLayerIframe(window)
        let layerIns = isLayerIframe ? layer : top.layer
        layerIns.open({
          type: 1,
          area: ['1000px', '800px'],
          title: '正在播放【' + text + '】',
          skin: 'video-player-layer',
          content: playerHtml,
          success: function (layero, index) {
            try {
              let dom = $('#' + id, layero)[0]
              let myPlayer = videojs(dom, {autoplay: true, controls: true, fluid: true, aspectRatio: '4:3'}, function(){
              });
            } catch (e) {
              console.error(e)
            }
          }
        })
      })
    }
  }
})