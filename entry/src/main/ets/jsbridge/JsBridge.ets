import { BridgeUtil } from './BridgeUtil';
import { CallBackFunction } from './CallBackFunction';
import { WebViewJavascriptBridge } from './WebViewJavascriptBridge';
import { ArrayList, HashMap, List } from '@kit.ArkTS';
import { BridgeHandler } from './BridgeHandler';
import { webview } from '@kit.ArkWeb';
import { Message } from './Message';
import { TextUtils } from '../util/TextUtils';
import { DefaultHandler } from './DefaultHandler';
import systemDateTime from '@ohos.systemDateTime';
import Logger from '../util/Logger';


/**
 * jsBridge
 */
export class JsBridge implements WebViewJavascriptBridge {
  webViewController: webview.WebviewController;

  constructor(webViewController: webview.WebviewController) {
    this.webViewController = webViewController
  }


  private responseCallbacks = new HashMap<String, CallBackFunction>()
  private messageHandlers = new HashMap<String, BridgeHandler>()
  private startupMessage:ArrayList<Message> | null = new ArrayList<Message>();

  public setStartupMessage(value:ArrayList<Message> | null) {
    this.startupMessage = value;
  }

  public getStartupMessage():ArrayList<Message> | null {
    return this.startupMessage;
  }
  private defaultHandler: BridgeHandler = new DefaultHandler();
  private uniqueId: number = 0;

  send(data: string, responseCallback: CallBackFunction): void {
    this.doSend(null, data, responseCallback);
  }


  doSend(handlerName: string | null, data: string, responseCallback: CallBackFunction) {
    let m = new Message();
    if (!TextUtils.isEmpty(data)) {
      m.data = data
    }

    if (responseCallback != null) {

      this.uniqueId++;

      let callbackStr = "JAVA_CB_" + this.uniqueId + BridgeUtil.UNDERLINE_STR + systemDateTime.getCurrentTime(false)

      this.responseCallbacks.set(callbackStr, responseCallback)
      m.callbackId = callbackStr
    }

    if (!TextUtils.isEmpty(handlerName)) {
      m.handlerName = handlerName;
    }
    this.queueMessage(m);

  }


  setDefaultHandler(handler: BridgeHandler) {
    this.defaultHandler = handler;
  }


  handlerReturnData(url: string): void {
    let functionName = BridgeUtil.getFunctionFromReturnUrl(url);
    Logger.debug("tagger","1 == " + this.responseCallbacks.length)
    let callBack:CallBackFunction | null  = this.responseCallbacks.get(functionName);
    Logger.debug("tagger","call == " + callBack)
    Logger.debug("tagger","2 == " + this.responseCallbacks.length)
    let data = BridgeUtil.getDataFromReturnUrl(url);
    Logger.debug("tagger","call2 == " + callBack)
    if (callBack != null) {
      Logger.debug("tagger","3 == " + this.responseCallbacks.length)
      callBack.onCallBack(data);
      Logger.debug("tagger","4 == " + this.responseCallbacks.length)
      this.responseCallbacks.remove(functionName);
    }
  }

  flushMessageQueue(): void {
    this.loadUrl(BridgeUtil.JS_FETCH_QUEUE_FROM_JAVA, {
      onCallBack: (data: string): void => {

        let list: ArrayList<Message> | null = null

        try {
          list = Message.toArrayList(data)
        } catch (ex) {
          return;
        }
        let le = list.length
        if (list == null && le == 0) return;


        for (let index = 0; index < list.length; index++) {
          let message:Message = list[index]
          let responseId = message.responseId

          if (!TextUtils.isEmpty(responseId)) {
            let fun = this.responseCallbacks.get(responseId)
            if (fun != null) {
              let respinseData = message.responseData
              fun.onCallBack(respinseData)
            }
            this.responseCallbacks.remove(responseId)
          } else {

            let responseFunction: CallBackFunction | null = null
            let callBackId = message.callbackId
            if (!TextUtils.isEmpty(callBackId)) {
              responseFunction = {
                onCallBack: (data: string) => {
                  let message = new Message();
                  message.responseId = callBackId
                  message.responseData = data
                  this.queueMessage(message);
                }
              }
            } else {
              responseFunction = {
                onCallBack: (data: string) => {

                }
              }
            }

            let handler: BridgeHandler | null = null
            if (!TextUtils.isEmpty(message.handlerName)) {
              handler = this.messageHandlers.get(message.handlerName);
            } else {
              handler = this.defaultHandler;
            }
            if (handler != null) {
              handler.handler(message.data, responseFunction);
            }
          }
        }
      }
    })
  }

  loadUrl(jsUrl: string, returnCallback: CallBackFunction): void {
    this.webViewController.runJavaScriptExt(jsUrl)
    this.responseCallbacks.set(BridgeUtil.parseFunctionName(jsUrl), returnCallback);
  }


  registerHandler(handlerName: string, handler: BridgeHandler) {

    if (handler != null) {
      this.messageHandlers.set(handlerName, handler)
    }

  }

  callHandler(handlerName:string,data:string,callBackFunction:CallBackFunction){
    this.doSend(handlerName,data,callBackFunction)
  }

  private queueMessage(m: Message) {
    if (this.startupMessage != null) {
      this.startupMessage.add(m);
    } else {
      this.dispatchMessage(m);
    }
  }

  public  dispatchMessage(m: Message) {
    let messageJson = JSON.stringify(m)

    messageJson = messageJson
      .replace(/\\/g, '\\\\')   // 替换反斜杠
      .replace(/"/g, '\\"')     // 替换双引号
      .replace(/\n/g, '\\n')    // 替换换行符
      .replace(/\r/g, '\\r')    // 替换回车符
      .replace(/\t/g, '\\t')    // 替换制表符
      .replace(/\f/g, '\\f');   // 替换进纸符
    let jsUrl = "javascript:WebViewJavascriptBridge._handleMessageFromNative('" + messageJson + "');"
    this.webViewController.runJavaScriptExt(jsUrl)
  }
}