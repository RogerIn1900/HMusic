import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import dataPreferences from '@ohos.data.preferences';
import { login } from './loginCls';

// 用户信息接口
interface UserInfo {
  username: string;
  password: string;
}

@Entry
@Component
export struct Register {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State strButtonText: string = "注册";

  // 保存用户信息到本地数据库
  async saveUserInfo(): Promise<boolean> {
    try {
      // 获取首选项实例
      const preferences: dataPreferences.Preferences = await dataPreferences.getPreferences(getContext(), 'userInfo');
      
      // 检查用户名是否已存在
      const existingUsers: string = await preferences.get('users', '[]') as string;
      const users: UserInfo[] = JSON.parse(existingUsers);
      
      // 检查用户名是否已存在
      if (users.some((user: UserInfo) => user.username === this.username)) {
        promptAction.showToast({ message: '用户名已存在' });
        return false;
      }

      // 添加新用户
      const newUser: UserInfo = {
        username: this.username,
        password: this.password
      };
      users.push(newUser);

      // 保存更新后的用户列表
      await preferences.put('users', JSON.stringify(users));
      await preferences.flush();
      
      return true;
    } catch (error) {
      console.error(`保存用户信息失败: ${error}`);
      return false;
    }
  }

  @Builder
  inputItem(placeholder: string, type: InputType, value: string, onChange: (value: string) => void) {
    Row() {
      TextInput({ placeholder: placeholder })
        .type(type)
        .borderRadius(0)
        .backgroundColor('#fff')
        .onChange((value: string) => {
          onChange(value);
        })
    }
    .borderWidth({ bottom: 1 })
    .borderColor('#eee')
  }

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
        Text('注册')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 注册表单
      Column({ space: 10 }) {
        // Logo
        Image($r('app.media.ic_me'))
          .width(80)
          .height(80)
          .margin({ top: 40, bottom: 40 })

        // 用户名输入框
        this.inputItem("请输入手机号", InputType.PhoneNumber, this.username, (value: string) => {
          this.username = value;
          this.isLoading = true;
          //this.isLoading = login.checkNameAndPass(this.username, this.password) && this.password === this.confirmPassword;
        })

        // 密码输入框
        this.inputItem("请输入密码", InputType.Password, this.password, (value: string) => {
          this.password = value;
          this.isLoading = true;
          //this.isLoading = login.checkNameAndPass(this.username, this.password) && this.password === this.confirmPassword;
        })

        // 确认密码输入框
        this.inputItem("请确认密码", InputType.Password, this.confirmPassword, (value: string) => {
          this.confirmPassword = value;
          this.isLoading = true;
          //this.isLoading = login.checkNameAndPass(this.username, this.password) && this.password === this.confirmPassword;
        })

        // 注册按钮
        Button(this.strButtonText)
          .width('90%')
          .height(50)
          .backgroundColor(this.isLoading ? '#007AFF' : '#ccc')
          .borderRadius(8)
          .fontSize(16)
          .fontColor(Color.White)
          .margin({ top: 40 })
          .onClick(async () => {
            if (!this.isLoading) return;

            //验证输入
            if (!this.username || !this.password || !this.confirmPassword) {
              promptAction.showToast({ message: '请填写完整信息' });
              return;
            }

            if (this.password !== this.confirmPassword) {
              promptAction.showToast({ message: '两次输入的密码不一致' });
              return;
            }

            if (!login.checkNameAndPass(this.username, this.password)) {
              promptAction.showToast({ message: '手机号或密码格式不正确' });
              return;
            }

            this.strButtonText = "注册中...";
            this.isLoading = false;

            // 保存用户信息
            const success: boolean = await this.saveUserInfo();
            
            if (success) {
              promptAction.showToast({ message: '注册成功' });
              // 自动登录
              login.userLogin(this.username, this.password, () => {
                promptAction.showToast({ message: '登录成功' });
                router.pushUrl({ url: 'pages/Index' });
              }, () => {
                this.isLoading = true;
                this.strButtonText = "注册";
                promptAction.showToast({ message: '自动登录失败，请手动登录' });
              });
            } else {
              this.isLoading = true;
              this.strButtonText = "注册";
            }
          })

        // 登录链接
        Text('已有账号？去登录')
          .fontSize(14)
          .fontColor('#007AFF')
          .margin({ top: 20 })
          .onClick(() => {
            router.pushUrl({ url: 'components/Login' });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
} 