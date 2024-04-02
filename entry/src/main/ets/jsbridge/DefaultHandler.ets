import { expect } from '@ohos/hypium'
import { BridgeHandler } from './BridgeHandler'
import { CallBackFunction } from './CallBackFunction'

export class DefaultHandler implements BridgeHandler {
  handler(data: string, fun: CallBackFunction): void {

    if (fun != null) {
      fun.onCallBack("DefaultHandler response data");
    }

  }
}