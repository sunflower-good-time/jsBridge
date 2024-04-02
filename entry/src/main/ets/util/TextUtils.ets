

export class TextUtils {
  public static isEmpty(str: string | null): boolean {
    return str == null || str.length == 0 || str == undefined;
  }
}