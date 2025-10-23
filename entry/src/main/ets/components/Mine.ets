import { router } from '@kit.ArkUI';
import { login, User } from './loginCls';
import promptAction from '@ohos.promptAction';

@Component
export struct Mine {
  @State userName: string = login.getUserDisplayName()
  @State userPhone: string = ''
  @State avatar: Resource = $r('app.media.ic_boy')
  @State customAvatarUri: string = ''
  @State isVip: boolean = false
  @State waveOffset: number = 0
  @State isLoggedIn: boolean = login.userFlag()
  @State showLogoutDialog: boolean = false
  private userInfoUpdateCallback: (() => void) | null = null
  
  // 刷新用户状态
  private refreshUserStatus() {
    this.isLoggedIn = login.userFlag()
    this.userName = login.getUserDisplayName()
    this.updateUserPhone()
    this.updateAvatar()
  }
  
  // 更新用户电话号码
  private updateUserPhone() {
    const currentUser: User | null = login.getCurrentUser()
    if (currentUser) {
      this.userPhone = currentUser.username
    } else {
      this.userPhone = ''
    }
  }
  
  // 更新头像
  private updateAvatar() {
    const avatarType: string = login.getUserAvatar()
    if (avatarType === 'default') {
      this.avatar = $r('app.media.ic_boy')
      this.customAvatarUri = ''
    } else if (avatarType && avatarType.startsWith('file://')) {
      // 自定义头像
      this.customAvatarUri = avatarType
      this.avatar = $r('app.media.ic_boy')
    } else {
      // 其他头像
      this.avatar = $r('app.media.ic_boy')
      this.customAvatarUri = ''
    }
  }
  
  // 组件初始化时刷新用户状态
  aboutToAppear() {
    this.refreshUserStatus()
    this.startWaveAnimation()
    // 注册用户信息更新监听
    this.registerUserInfoUpdateListener()
  }

  // 组件销毁时取消监听
  aboutToDisappear() {
    this.unregisterUserInfoUpdateListener()
  }


  // 注册用户信息更新监听
  private registerUserInfoUpdateListener() {
    this.userInfoUpdateCallback = () => {
      this.refreshUserStatus()
    }
    login.onUserInfoUpdate(this.userInfoUpdateCallback)
  }

  // 取消用户信息更新监听
  private unregisterUserInfoUpdateListener() {
    if (this.userInfoUpdateCallback) {
      login.offUserInfoUpdate(this.userInfoUpdateCallback)
      this.userInfoUpdateCallback = null
    }
  }


  // 显示退出登录确认弹窗
  private showLogoutConfirmation() {
    this.showLogoutDialog = true
  }

  // 确认退出登录
  private confirmLogout() {
    login.logout()
    this.refreshUserStatus()
    this.showLogoutDialog = false
    promptAction.showToast({ message: '已退出登录' })
  }

  // 取消退出登录
  private cancelLogout() {
    this.showLogoutDialog = false
  }
  
  // 启动波浪动画
  private startWaveAnimation() {
    setInterval(() => {
      this.waveOffset += 0.1
    }, 50)
  }
  
  build() {
    Stack() {
      Column() {
      // 顶部用户信息
      Column() {
        // 边框头像
        Stack() {
          // 边框背景
          Circle()
            .width(100)
            .height(100)
            .backgroundColor('#667eea')
            .opacity(0.15)
            .animation({
              duration: 2000,
              curve: Curve.Linear,
              iterations: -1,
              playMode: PlayMode.Normal
            })
            .scale({ x: 1 + Math.sin(this.waveOffset) * 0.05, y: 1 + Math.sin(this.waveOffset) * 0.05 })
          
          // 头像
          if (this.customAvatarUri) {
            Image(this.customAvatarUri)
              .width(80)
              .height(80)
              .borderRadius(40)
              .border({ width: 3, color: '#E0E0E0' })
              .objectFit(ImageFit.Cover)
          } else {
            Image(this.avatar)
              .width(80)
              .height(80)
              .borderRadius(40)
              .border({ width: 3, color: '#E0E0E0' })
              .backgroundColor('#F0F0F0')
          }
        }
        .margin({ top: 20, bottom: 16 })
        
        // 用户信息区域
        Column() {
        // 用户名
        Text(this.userName)
          .fontSize(24)
          .fontWeight(FontWeight.Lighter)
          .fontColor('#333333')
          .shadow({ radius: 4, color: '#CCCCCC', offsetX: 0, offsetY: 2 })
          .margin({ bottom: 4 })
          .onClick(() => {
            // 点击用户名手动刷新昵称
            this.refreshUserStatus()
          })
          
          // 电话号码 - 当有昵称时显示电话号码作为副标题
          if (this.isLoggedIn && this.userPhone) {
            Text(this.userPhone)
              .fontSize(14)
              .fontWeight(FontWeight.Lighter)
              .fontColor('#666666')
              .shadow({ radius: 2, color: '#CCCCCC', offsetX: 0, offsetY: 1 })
              .margin({ bottom: 8 })
          }
          
          // VIP标签
          if (this.isVip) {
            Text('黑胶VIP')
              .fontSize(14)
              .fontWeight(FontWeight.Lighter)
              .fontColor('#FFD700')
              .backgroundColor('rgba(255, 215, 0, 0.2)')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .borderRadius(12)
              .border({ width: 1, color: '#FFD700' })
          }
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height(220)
      .backgroundColor('#FFFFFF')
      .padding({ top: 40 })
      .onClick(() => {
        if(!this.isLoggedIn) {
          router.pushUrl({ url: 'components/Login' });
        } else {
          // 已登录时点击进入设置页面
          router.pushUrl({ url: 'pages/UserSettings' });
        }
      })

      // 金色渐变VIP卡片
      Column() {
        Row() {
          // VIP图标
          Stack() {
            Circle()
              .width(40)
              .height(40)
              .backgroundColor('#FFD700')
              .shadow({ radius: 8, color: '#FFD700', offsetX: 0, offsetY: 4 })
            
            Image($r('app.media.ic_add'))
              .width(24)
              .height(24)
              .fillColor('#FFFFFF')
          }
          
          Column() {
            Text('开通黑胶VIP')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Text('立享超多权益')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
          .layoutWeight(1)
          
          Image($r('app.media.ic_next'))
            .width(20)
            .height(20)
            .fillColor('#666666')
        }
        .width('100%')
        .height(80)
        .padding({ left: 20, right: 20 })
      }
      .width('90%')
      .backgroundColor('rgba(255, 255, 255, 0.9)')
      .backdropBlur(10)
      .margin({ top: -20 })
      .borderRadius(20)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 10 })
      .onClick(() => {
        router.pushUrl({ url: 'pages/VipRecharge' });
      })

      // 用户喜欢的音乐
      this.createFunctionCard(
        '#FF6B6B',
        $r('app.media.like_on'),
        '我喜欢的音乐',
        '收藏的歌曲和歌单',
        () => { router.pushUrl({ url: 'pages/MyFavorites' }); }
      )

      // 我的设置
      this.createFunctionCard(
        '#4ECDC4',
        $r('app.media.menu'),
        '我的设置',
        '个人设置和账户管理',
        () => { 
          if (this.isLoggedIn) {
            router.pushUrl({ url: 'pages/UserSettings' });
          }
        }
      )


      // 根据登录状态显示不同的按钮
      if (this.isLoggedIn) {
        // 已登录时显示退出登录按钮
        this.createActionCard(
          '#FF6B6B',
          '退出登录',
          '安全退出当前账户',
          () => {
            this.showLogoutConfirmation()
          }
        )
      } else {
        // 未登录时显示登录按钮
        this.createActionCard(
          '#667eea',
          '立即登录',
          '登录享受更多功能',
          () => {
            router.pushUrl({ url: 'components/Login' });
          }
        )
      }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16, top: 0, bottom: 16 })

      // 退出登录确认弹窗
      if (this.showLogoutDialog) {
        this.createLogoutDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  createFunctionCard(gradientColor: string, icon: Resource, title: string, subtitle: string, onClick: () => void) {
    Column() {
      Row() {
        // 彩色背景
        Stack() {
          Circle()
            .width(48)
            .height(48)
            .backgroundColor(gradientColor)
            .shadow({ radius: 8, color: gradientColor, offsetX: 0, offsetY: 4 })
          
          Image(icon)
            .width(24)
            .height(24)
            .fillColor('#FFFFFF')
        }
        
        Column() {
          Text(title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Text(subtitle)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1)
        
        Image($r('app.media.ic_next'))
          .width(20)
          .height(20)
          .fillColor('#666666')
      }
      .width('100%')
      .height(80)
      .padding({ left: 20, right: 20 })
    }
    .width('90%')
    .backgroundColor('rgba(255, 255, 255, 0.9)')
    .backdropBlur(10)
    .margin({ top: 16 })
    .borderRadius(20)
    .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 10 })
    .onClick(onClick)
  }

  @Builder
  createActionCard(gradientColor: string, title: string, subtitle: string, onClick: () => void) {
    Column() {
      Row() {
        // 渐变背景圆形图标
        Stack() {
          Circle()
            .width(48)
            .height(48)
            .backgroundColor(gradientColor)
            .shadow({ radius: 12, color: gradientColor, offsetX: 0, offsetY: 6 })
          
          Text(title.charAt(0))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        
        Column() {
          Text(title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
          
          Text(subtitle)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
        .layoutWeight(1)
      }
      .width('100%')
      .height(80)
      .padding({ left: 20, right: 20 })
    }
    .width('90%')
    .backgroundColor('rgba(255, 255, 255, 0.9)')
    .backdropBlur(10)
    .margin({ top: 16 })
    .borderRadius(20)
    .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 10 })
    .onClick(onClick)
  }

  @Builder
  createLogoutDialog() {
    // 半透明背景遮罩
    Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.cancelLogout()
        })

      // 弹窗内容
      Column() {
        // 弹窗标题
        Text('确认退出登录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 16 })

        // 弹窗内容
        Text('确定要退出当前账户吗？')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 24 })

        // 按钮
        Row() {
          // 取消按钮
          Button('取消')
            .width(120)
            .height(44)
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(() => {
              this.cancelLogout()
            })

          // 确认按钮
          Button('确认退出')
            .width(120)
            .height(44)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF6B6B')
            .borderRadius(22)
            .margin({ left: 16 })
            .onClick(() => {
              this.confirmLogout()
            })
        }
        .justifyContent(FlexAlign.Center)
      }
      .width(280)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .padding(24)
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.3)', offsetX: 0, offsetY: 10 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(999)
  }
}