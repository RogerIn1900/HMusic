import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { login } from './loginCls';
import { preferences } from '@kit.ArkData';

// 社交平台接口
interface SocialPlatform {
  name: string;
  icon: Resource;
}

@Entry
@Component
export struct Login {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State strButtonText:string="登录"
  onPageShow(): void {
    this.isLoading = false;
    this.strButtonText="登录";
  }
  @Builder
  loginItem(
  placeholder:string,
  type:InputType,
  fn:(value:string)=>void){
  Row() {
    TextInput({ placeholder: placeholder })
      .type(type)
      .borderRadius(0)
      .backgroundColor('#fff')
      .onChange(value => {
        fn(value)
      })
  }.borderWidth({ bottom: 1 }).borderColor('#eee')
}
  // 定义社交登录平台数据
  private socialPlatforms: SocialPlatform[] = [
    { name: '微信', icon: $r('app.media.wechat') },
    { name: 'QQ', icon: $r('app.media.QQ') },
    { name: '微博', icon: $r('app.media.welog') }
  ];

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
          .margin({ right: 10 });
        Text('登录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 登录表单
      Column({ space:10 }) {
        // Logo
        Image($r('app.media.ic_me'))
          .width(80)
          .height(80)
          .margin({ top: 40, bottom: 40 })
        //   调用公用组件
        this.loginItem( "请输入手机号", InputType.PhoneNumber, (value) => {
          this.username = value;
          this.isLoading = login.checkNameAndPass(this.username,this.password)
        })
        //   调用公用组件
        this.loginItem( "请输入密码", InputType.Password, (value) => {
          this.password = value;
          this.isLoading = login.checkNameAndPass(this.username,this.password)
        })


        // 登录按钮
        Button(this.strButtonText)
          .width('90%')
          .height(50)
          .backgroundColor(!this.isLoading?"#ccc":'')
          .borderRadius(8)
          .fontSize(16)
          .fontColor(Color.White)
          .onClick(() => {
            if(this.isLoading) {
              this.strButtonText = "正在登录中...";
              this.isLoading = false;
              login.userLogin(this.username, this.password, () => {
                promptAction.showToast({
                  message: "登录成功"
                })
                // 初始化用户信息
                login.initUserInfo()
                router.pushUrl({
                  url: "pages/Index"
                })
              }, () => {
                setTimeout(() => {
                  this.isLoading = true;
                  this.strButtonText = "登录";
                }, 2000)
              })
            }
          })

        // 注册链接
        Text('还没有账号？去注册')
          .fontSize(14)
          .fontColor('#007AFF')
          .margin({ top: 20 })
          .onClick(() => {
            router.pushUrl({ url: 'components/register' });
          })

        // 其他登录方式
        Row() {
          Text('其他登录方式')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 40, bottom: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 社交登录图标
        Row() {
          ForEach(this.socialPlatforms, (platform: SocialPlatform) => {
            Column() {
              Image(platform.icon)
                .width(40)
                .height(40)
                .margin({ bottom: 8 })
              Text(platform.name)
                .fontSize(12)
                .fontColor('#666666')
            }
            .margin({ left: 30, right: 30 })
            .onClick(() => {
              promptAction.showToast({ message: `使用${platform.name}登录` });
            })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        Stack() {
          Text() {
          }
          .width('80%')
          .borderWidth({ bottom: 1 })
          .borderColor('#ccc')

          Text('©2025 WeGo')
            .backgroundColor('#fff')
            .fontColor('#ccc')
            .padding({ left: 10, right: 10 })
        }
        .margin({top:140})
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')

    }
    .width('100%')
    .height('100%')
  }
} 