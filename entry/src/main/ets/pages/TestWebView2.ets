// xxx.ets
import web_webview from '@ohos.web.webview';
import business_error from '@ohos.base';
import Logger from '../util/Logger';

const TAG = '[WebView_WebComp]';


class TestObj {
  constructor() {
  }

  test(): string {
    return "2232323232323";
  }

  toString(): void {
    Logger.info(TAG,'Web Component toString');
  }
}

@Entry
@Component
struct WebComponent {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController();


  @State hiddenScrollBar:Boolean = false
  @State testObjtest: TestObj = new TestObj();
  private TAG:String = "WebComponent"


  aboutToAppear() {

  }

  build() {
    Column() {
      Button('loadUrl')
        .onClick(() => {
          try {
            // 点击按钮时，通过loadUrl，跳转到www.example1.com
            this.webviewController.loadUrl($rawfile('demo2.html'));
          } catch (error) {
            let e: business_error.BusinessError = error as business_error.BusinessError;
            console.error(`ErrorCode: ${e.code},  Message: ${e.message}`);
          }

        })
      Button('to Js').onClick(()=>{
        this.webviewController.runJavaScript('htmlTest(333344444)');
      })
      // 组件创建时，加载www.example.com
      Web({ src: 'https://www.baidu.com/', controller: this.webviewController})
        .darkMode(WebDarkMode.Auto)
        .domStorageAccess(true)
        .zoomAccess(true)
        .fileAccess(true)
        .mixedMode(MixedMode.All)
        .cacheMode(CacheMode.None)
        .verticalScrollBarAccess(!this.hiddenScrollBar)
        .javaScriptAccess(true)
        .javaScriptProxy({
          object: this.testObjtest,
          name: "ObjName",
          methodList: ["test"],
          controller: this.webviewController
        })
        .onProgressChange((event) => {
          Logger.info(TAG,"progress = " + event?.newProgress)
        })
        .onPageBegin(() => {
          Logger.info(TAG, ' onPageBegin start loading');
          Logger.info(TAG, 'onPageBegin weburl: ' + this.webviewController.getUrl());
        })
        .onErrorReceive(() => {
          Logger.info(TAG, ' onErrorReceive');
        })
        .onPageEnd((event) => {
          Logger.info(TAG, 'onPageEnd loading completed url: ' + event?.url);
          Logger.info(TAG, 'onPageEnd weburl: ' + this.webviewController.getUrl());
        })

        .width('100%').height('100%')
    }
  }
}