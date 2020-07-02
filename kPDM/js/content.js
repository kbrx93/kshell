videojs.options.flash.swf = "video-js.swf"
const video_support_format = ['.mp4', '.webm', '.ogv']
const log_support_format = ['.zip', 'rar']
let count = 1
let logcount = 1
let file_path = 'K://log/'
let bugNum = 'BBB'
// 查找所有视频及Log
$("a[href][target='_blank']").each(function () {
  let $this = $(this)
  let file_name = $this.text()
  let index = file_name.lastIndexOf('.')
  if (index < 0) {
    console.log('can not find link')
    return
  }
  let suffix = file_name.substring(index, file_name.length).toLowerCase()
  if (video_support_format.indexOf(suffix) >= 0) {
    // 匹配对应的视频
    let url = $this.attr('href')
    if (!url.startsWith('http')) {
      let port = location.port
      port = port ? (':' + port) : ''
      url = location.protocol + '//' + location.hostname + port + url
    }
    // add link
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
        area: '1000px',
        title: '正在播放【' + file_name + '】',
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
  } else if (log_support_format.indexOf(suffix) >= 0) {
    // 匹配对应的 Log
    let $btn = $('<button id="btn">点我复制LOG路径</button>')
    $this.after($btn)
    $btn.click(function() {
      // 后面改成可配置的
      let fileurl = file_path + bugNum + '_' + logcount + "/"
      logcount ++
      const input = document.createElement('input');
      document.body.appendChild(input);
      input.setAttribute('value', fileurl);
      input.select();
      if (document.execCommand('copy')) {
        document.execCommand('copy');
        console.log('复制成功');
      }
      document.body.removeChild(input);
    })
  } else {
    console.log('can not find support suffix log and video')
  }
})