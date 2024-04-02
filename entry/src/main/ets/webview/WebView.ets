// xxx.ets
import Logger from '../util/Logger';
import { webview } from '@kit.ArkWeb';
import { BridgeUtil } from '../jsbridge/BridgeUtil';
import { JsBridge } from '../jsbridge/JsBridge';
import promptAction from '@ohos.promptAction';
const TAG = '[WebView_WebComp]';

@Component
export struct WebView {
  @Link webViewController: webview.WebviewController
  url: ResourceStr = ''
  hiddenScrollBar?: boolean = false
  @Link jsBridge: JsBridge

  build() {
    Web({ src: this.url, controller: this.webViewController })
      .darkMode(WebDarkMode.Auto)
      .domStorageAccess(true)
      .zoomAccess(true)
      .fileAccess(true)
      .mixedMode(MixedMode.All)
      .cacheMode(CacheMode.None)
      .verticalScrollBarAccess(!this.hiddenScrollBar)
      .javaScriptAccess(true)
      .onLoadIntercept((event) =>{
        let url: string = event.data.getRequestUrl()

        if (url.startsWith("fltrporganteacher://")) {
          promptAction.showToast({
            message:url
          })
          return true
        }
        return false
      })
      .onInterceptRequest((event) => {
        if (event) {
          let url = event.request.getRequestUrl()
          url = url.replace("%(?![0-9a-fA-F]{2})", "%25");
          url = decodeURIComponent(url);

          if (url.startsWith(BridgeUtil.YY_RETURN_DATA)) {
            this.jsBridge.handlerReturnData(url)
          } else if (url.startsWith(BridgeUtil.YY_OVERRIDE_SCHEMA)) {
            this.jsBridge.flushMessageQueue()
          } else {
            return null
          }
        }
        return null
      })
      .onTitleReceive((event) =>{


        // if (event) {
        //   let title =  event?.title
        //   promptAction.showToast({
        //     message:title
        //   })
        //
        // }

      })
      .onProgressChange((event) => {
        Logger.info(TAG, "progress = " + event?.newProgress)
      })
      .onPageBegin(() => {
        Logger.info(TAG, ' onPageBegin start loading');
        Logger.info(TAG, 'onPageBegin weburl: ' + this.webViewController.getUrl());
      })
      .onErrorReceive(() => {
        Logger.info(TAG, ' onErrorReceive');
      })
      .onPageEnd((event) => {
        Logger.info(TAG, 'onPageEnd loading completed url: ' + event?.url);
        Logger.info(TAG, 'onPageEnd weburl: ' + this.webViewController.getUrl());
        BridgeUtil.webViewLoadLocalJs(getContext(), this.webViewController, BridgeUtil.toLoadJs)

        let startupMessages = this.jsBridge.getStartupMessage()

        if (startupMessages != null) {
          for (let i = 0; i < startupMessages.length; i++) {
            this.jsBridge.dispatchMessage(startupMessages[i]);
          }
          this.jsBridge.setStartupMessage(null);
        }
      })
  }
}