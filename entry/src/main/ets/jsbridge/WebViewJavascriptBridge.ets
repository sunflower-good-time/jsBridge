import { CallBackFunction } from './CallBackFunction'

export interface WebViewJavascriptBridge {
  send(data:string,responseCallback:CallBackFunction): void
}