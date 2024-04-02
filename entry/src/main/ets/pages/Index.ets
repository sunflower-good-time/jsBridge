// xxx.ets
import webview from '@ohos.web.webview'
import { TestBean } from '../bean/TestBean';
import { CallBackFunction } from '../jsbridge/CallBackFunction';
import { JsBridge } from '../jsbridge/JsBridge';
import { WebView } from '../webview/WebView';
import { HashMap } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  @State webViewController: webview.WebviewController = new webview.WebviewController()
  @State jsBridge: JsBridge = new JsBridge(this.webViewController)
  @State hiddenScrollBar: Boolean = false
  private TAG: String = "WebComponent"
  @State txt:string = ''

  aboutToAppear() {
    this.jsBridge.registerHandler("test_call", {
      handler: (data: string, fun: CallBackFunction) => {
        let textBean = new TestBean()
        textBean.map = new HashMap()
        textBean.map.set("test", "22222")
        fun.onCallBack("native 返回" + JSON.stringify(textBean))
      }
    })
  }

  private getJsContent(){

    this.jsBridge.callHandler("getJsContent","test",{onCallBack:(data:string)=>{
      this.txt = data
    }})
  }

  build() {
    Column() {

      Button("获取js网页信息").onClick(event=>{
        this.getJsContent()
      })
      Text(this.txt)
      WebView({
        webViewController: this.webViewController,
        url: $rawfile('demo.html'),
        hiddenScrollBar: true,
        jsBridge: this.jsBridge
      }).width('100%').height('100%')
    }
  }
}