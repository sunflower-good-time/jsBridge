# jsBridge
鸿蒙版本的jsbridge

相信大多数小伙伴的项目都已经有了线上稳定运行的 JsBridge 方案，那么对于鸿蒙来说，最好的方案肯定是不需要前端同学的改动，就可以直接运行，这个兼容任务就得我们自己来做了。

关于 JsBridge 的通信原理，在 这篇文章 中已经介绍过了，现在主流的技术方案有 拦截 URL 和 对象注入 两种，我们分别看一下如何在鸿蒙上实现。

拦截 URL
在安卓上，拦截 URL 这个技术方案的代表作一定是 https://github.com/lzyzsd/JsBridge ，相信有不少小伙伴都使用了这个开源库。

我这里就以该开源库为例，介绍一下如何在鸿蒙上无缝迁移。

![image](https://github.com/sunflower-good-time/jsBridge/assets/42331894/0fe146d1-a629-4283-abe9-6f56603fbc48)

使用方法


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
