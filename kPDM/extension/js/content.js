videojs.options.flash.swf = "video-js.swf"
const video_support_format = ['.mp4', '.webm', '.ogv']
const log_support_format = ['.zip', 'rar']
let count = 1
let logcount = 1
let file_path = 'K:\\log\\log_extract\\'
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
    let $play = $('<a class="video-play-btn" href="javascript:;">&nbsp播放&nbsp</a>')
	$this.parent().append($play)
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
		scrollbar: false,
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
	let local_logcount = logcount
    let $btn = $('<button id="btn_' + logcount + '">点我复制LOG路径</button>')
	$this.parent().append($btn)
    $btn.click(function() {
      // 后面改成可配置的
	  let $titleDom = $('#codeandtitle')
	  let bugNum = $titleDom.text().match(/\[(.+?)\]/g)[0]
	  bugNum = bugNum.substring(1, bugNum.length - 1)
	  let fileurl = file_path + bugNum + '_' + local_logcount + "\\"
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
	logcount ++
  } else {
    console.log('can not find support suffix log and video')
  }
})

	//判断当前窗口是否被layerIframe包含，如果是，则返回该layerIframe下的iframe
function getLayerIframe(win){
	if(top === win){
		return null;
	}
	var flag = false;
	for(var i = 0; i < win.parent.frames.length; i++){
		var frame = win.parent.frames[i];
		try{
			//解决某些浏览器插件往页面添加iframe导致跨域报错的问题
			var frameName = frame.name;
			if(frameName 
					&& frame === win 
					&& $("iframe[name='" + frameName + "']", win.parent.document).hasClass("layer-iframe-content")){
				flag = true;
				break;
			}
		}catch(e){
			console.error(e);
		}
	}
	if(!flag){
		//往父页面找，直到top
		return getLayerIframe(win.parent);
	}
	return win;
}
