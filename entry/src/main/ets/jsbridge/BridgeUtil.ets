import { util } from '@kit.ArkTS'
import { webview } from '@kit.ArkWeb';
import Logger from '../util/Logger';

export class BridgeUtil {
  public static toLoadJs: string = "WebViewJavascriptBridge.js"
  public static JAVASCRIPT_STR: String = "javascript:";
  public static YY_OVERRIDE_SCHEMA = "yy://";
  public static YY_RETURN_DATA = BridgeUtil.YY_OVERRIDE_SCHEMA + "return/"; //格式为   yy://return/{function}/returncontent
  public static YY_FETCH_QUEUE = BridgeUtil.YY_RETURN_DATA + "_fetchQueue/";
  public static EMPTY_STR = "";
  public static UNDERLINE_STR = "_";
  public static SPLIT_MARK = "/";
  public static CALLBACK_ID_FORMAT = "JAVA_CB_%s";
  public static JS_HANDLE_MESSAGE_FROM_JAVA = "javascript:WebViewJavascriptBridge._handleMessageFromNative('%s');";
  public static JS_FETCH_QUEUE_FROM_JAVA = "javascript:WebViewJavascriptBridge._fetchQueue();";

  public static webViewLoadLocalJs(context: Context, controller: webview.WebviewController, jsName: string) {
    let jsContent = BridgeUtil.rawFile2Str(context, jsName)
    controller?.runJavaScriptExt(BridgeUtil.JAVASCRIPT_STR + jsContent, (err, res) => {
      Logger.info("runJavaScriptExt", res.getString())
    })
  }

  private static rawFile2Str(context: Context, file: string): string {
    try {
      let data = context.resourceManager.getRawFileContentSync(file)
      let decoder = util.TextDecoder.create("utf-8")
      let str = decoder.decodeWithStream(data, { stream: false })
      return str
    } catch (e) {
      return ""
    }
  }

  public static getFunctionFromReturnUrl(url: string): string {
    let temp = url.replace(BridgeUtil.YY_RETURN_DATA, BridgeUtil.EMPTY_STR)
    let functionAndData = temp.split(BridgeUtil.SPLIT_MARK);

    if (functionAndData.length >= 1) {
      return functionAndData[0];
    }
    return ''
  }

  public static getDataFromReturnUrl(url: string): string {

    if (url.startsWith(BridgeUtil.YY_FETCH_QUEUE)) {
      return url.replace(BridgeUtil.YY_FETCH_QUEUE, BridgeUtil.EMPTY_STR);
    }
    let temp = url.replace(BridgeUtil.YY_RETURN_DATA, BridgeUtil.EMPTY_STR);
    let functionAndData = temp.split(BridgeUtil.SPLIT_MARK);
    if (functionAndData.length >= 2) {
      let str = ""
      for (let index = 0; index < functionAndData.length; index++) {
        const element = functionAndData[index];
        str += element
      }
      return str
    }
    return ''
  }

  public static parseFunctionName(jsUrl:string){

    let reg = new RegExp("\\(.*\\);", '');

    return jsUrl.replace("javascript:WebViewJavascriptBridge.", "").replace(reg, "");
  }
}