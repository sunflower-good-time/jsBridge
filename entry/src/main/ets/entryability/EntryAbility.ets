import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Message } from '../jsbridge/Message';
import { HashMap } from '@kit.ArkTS';
import { CallBackFunction } from '../jsbridge/CallBackFunction';
import Logger from '../util/Logger';

export default class EntryAbility extends UIAbility {
  private responseCallbacks = new HashMap<String, CallBackFunction>()

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {

    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate + list');
    this.responseCallbacks.set("11", {
      onCallBack: (data: string) => {


      }
    })

    let callBack:CallBackFunction | null = this.responseCallbacks.get("11");

    Logger.debug("tagger","call back = " + callBack)
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
