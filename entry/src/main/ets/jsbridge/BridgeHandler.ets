import { CallBackFunction } from './CallBackFunction'

export interface BridgeHandler {
  handler:(data: string, fun: CallBackFunction)=>void
}