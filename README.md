# jsBridge
鸿蒙版本的jsbridge

相信大多数小伙伴的项目都已经有了线上稳定运行的 JsBridge 方案，那么对于鸿蒙来说，最好的方案肯定是不需要前端同学的改动，就可以直接运行，这个兼容任务就得我们自己来做了。

关于 JsBridge 的通信原理，在 这篇文章 中已经介绍过了，现在主流的技术方案有 拦截 URL 和 对象注入 两种，我们分别看一下如何在鸿蒙上实现。

拦截 URL
在安卓上，拦截 URL 这个技术方案的代表作一定是 https://github.com/lzyzsd/JsBridge ，相信有不少小伙伴都使用了这个开源库。

我这里就以该开源库为例，介绍一下如何在鸿蒙上无缝迁移。

![image](https://github.com/sunflower-good-time/jsBridge/assets/42331894/0fe146d1-a629-4283-abe9-6f56603fbc48)

使用方法：

 this.jsBridge.registerHandler("test_call", {
      handler: (data: string, fun: CallBackFunction) => {
        let textBean = new TestBean()
        textBean.map = new HashMap()
        textBean.map.set("test", "22222")
        fun.onCallBack("native 返回" + JSON.stringify(textBean))
      }
    })

this.jsBridge.callHandler("getJsContent","test",{onCallBack:(data:string)=>{
      this.txt = data
    }})


如果对大家有帮助，希望顺手帮忙点个starred




