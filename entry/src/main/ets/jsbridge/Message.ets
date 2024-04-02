import { ArrayList, List } from '@kit.ArkTS';

export class Message {

  public callbackId:string = ''
  public responseId:string = ''
  public responseData:string = ''
  public data:string = ''
  public handlerName:string | null = ''

  public static toArrayList(data:string):ArrayList<Message> {
    let res: ArrayList<Message> = JSON.parse(data)
    return res
  }

}
