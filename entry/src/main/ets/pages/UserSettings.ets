import { router } from '@kit.ArkUI';
import { login } from '../components/loginCls';
import promptAction from '@ohos.promptAction';
import fs from '@ohos.file.fs';
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

// 页面入口函数
@Builder
export function UserSettingsBuilder() {
  UserSettings()
}

interface ErrorWithMessage {
  message?: string;
}

@Entry
@Component
struct UserSettings {
  @State currentNickname: string = '';
  @State selectedAvatar: string = 'default';
  @State isLoading: boolean = false;
  @State customAvatarUri: string = '';

  // 头像选项
  private avatarOptions: string[] = ['default'];
  private avatarNames: string[] = ['默认头像'];

  onPageShow() {
    this.loadUserInfo();
  }

  // 加载用户信息
  private loadUserInfo() {
    const currentUser = login.getCurrentUser();
    if (currentUser) {
      this.currentNickname = currentUser.nickname || currentUser.username;
      this.selectedAvatar = currentUser.avatar || 'default';
      // 如果有自定义头像，加载自定义头像URI
      if (currentUser.avatar && currentUser.avatar.startsWith('file://')) {
        this.customAvatarUri = currentUser.avatar;
      }
    }
  }

  // 选择头像
  private async selectAvatar(): Promise<void> {
    try {
      // 创建图片选择选项
      const photoSelectOptions: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      };

      // 创建图片选择器
      const photoViewPicker = new picker.PhotoViewPicker();

      // 选择图片
      const selectResult: picker.PhotoSelectResult = await photoViewPicker.select(photoSelectOptions);

      if (selectResult && selectResult.photoUris && selectResult.photoUris.length > 0) {
        const selectedUri: string = selectResult.photoUris[0];
        this.customAvatarUri = selectedUri;
        this.selectedAvatar = 'custom';

        // 复制图片到应用目录
        await this.copyImageToAppDir(selectedUri);

        promptAction.showToast({ message: '头像选择成功' });
      }
    } catch (error) {
      console.error('选择头像失败:', error);
      promptAction.showToast({ message: '选择头像失败' });
    }
  }

  // 复制图片到应用目录 - 修复类型问题
  private async copyImageToAppDir(sourceUri: string): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const filesDir: string = context.filesDir;
      const fileName = `avatar_${Date.now()}.jpg`;
      const destPath = `${filesDir}/${fileName}`;

      // 创建目标文件
      const destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);

      // 读取源文件
      const sourceFile = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY);

      // 复制文件内容
      const buffer = new ArrayBuffer(1024 * 1024); // 1MB buffer
      let bytesRead = 0;

      while ((bytesRead = fs.readSync(sourceFile.fd, buffer)) > 0) {
        const chunk: ArrayBuffer = buffer.slice(0, bytesRead);
        fs.writeSync(destFile.fd, chunk);
      }

      // 关闭文件
      fs.closeSync(sourceFile);
      fs.closeSync(destFile);

      // 更新自定义头像URI
      this.customAvatarUri = `file://${destPath}`;
    } catch (e) {
      const msgFromObj: string | undefined = (e as ErrorWithMessage).message;
      const message: string = msgFromObj !== undefined ? String(msgFromObj) : String(e);
      console.error('复制头像失败:', message);
      throw new Error(message);
    }
  }

  // 保存用户信息
  private async saveUserInfo(): Promise<void> {
    if (!this.currentNickname.trim()) {
      promptAction.showToast({ message: '请输入昵称' });
      return;
    }

    this.isLoading = true;

    try {
      // 确定头像类型
      const avatarToSave = this.selectedAvatar === 'custom' ? this.customAvatarUri : this.selectedAvatar;
      const success = await login.updateUserInfo(this.currentNickname.trim(), avatarToSave);
      
      if (success) {
        promptAction.showToast({ message: '保存成功' });
        // 强制触发用户信息更新回调
        login.triggerUserInfoUpdate();
        // 延迟返回，让用户看到成功提示
        setTimeout(() => {
          router.back();
        }, 1000);
      } else {
        promptAction.showToast({ message: '保存失败，请重试' });
      }
    } catch (error) {
      console.error('保存用户信息失败:', error);
      promptAction.showToast({ message: '保存失败，请重试' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })

        Text('我的设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ top: 16, bottom: 16 })

      // 主要内容
      Scroll() {
        Column() {
          // 当前头像显示
          Column() {
            Text('当前头像')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            // 当前选择的头像
            Stack() {
              Circle()
                .width(100)
                .height(100)
                .backgroundColor('#667eea')
                .border({ width: 3, color: '#FFFFFF' })
                .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.2)', offsetX: 0, offsetY: 5 })

              if (this.selectedAvatar === 'default') {
                Image($r('app.media.ic_me'))
                  .width(60)
                  .height(60)
                  .fillColor('#FFFFFF')
              } else if (this.selectedAvatar === 'custom' && this.customAvatarUri) {
                Image(this.customAvatarUri)
                  .width(94)
                  .height(94)
                  .borderRadius(47)
                  .objectFit(ImageFit.Cover)
              } else {
                Text(this.selectedAvatar.charAt(0).toUpperCase())
                  .fontSize(40)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
            }
            .margin({ bottom: 20 })
            .onClick(() => {
              this.selectAvatar();
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16, left: 16, right: 16 })

          // 昵称设置
          Column() {
            Text('昵称设置')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            TextInput({ placeholder: '请输入昵称', text: this.currentNickname })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .onChange((value: string) => {
                this.currentNickname = value;
              })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16, left: 16, right: 16 })

          // 头像选择
          Column() {
            Text('选择头像')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 16 })

            Row() {
              // 默认头像选项
              Column() {
                Stack() {
                  Circle()
                    .width(60)
                    .height(60)
                    .backgroundColor(this.selectedAvatar === 'default' ? '#667eea' : '#E0E0E0')
                    .border({ width: 2, color: this.selectedAvatar === 'default' ? '#667eea' : '#CCCCCC' })

                  Image($r('app.media.ic_me'))
                    .width(30)
                    .height(30)
                    .fillColor('#FFFFFF')
                }
                .onClick(() => {
                  this.selectedAvatar = 'default';
                })

                Text('默认头像')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .alignItems(HorizontalAlign.Center)
              .margin({ right: 40 })

              // 自定义头像选项
              Column() {
                Stack() {
                  Circle()
                    .width(60)
                    .height(60)
                    .backgroundColor(this.selectedAvatar === 'custom' ? '#667eea' : '#E0E0E0')
                    .border({ width: 2, color: this.selectedAvatar === 'custom' ? '#667eea' : '#CCCCCC' })

                  if (this.customAvatarUri) {
                    Image(this.customAvatarUri)
                      .width(56)
                      .height(56)
                      .borderRadius(28)
                      .objectFit(ImageFit.Cover)
                  } else {
                    Image($r('app.media.ic_add'))
                      .width(30)
                      .height(30)
                      .fillColor('#FFFFFF')
                  }
                }
                .onClick(() => {
                  this.selectAvatar();
                })

                Text('自定义头像')
                  .fontSize(12)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .alignItems(HorizontalAlign.Center)
            }
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ top: 16, left: 16, right: 16 })

          // 保存按钮
          Button('保存设置')
            .width('90%')
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#667eea')
            .borderRadius(24)
            .margin({ top: 32, bottom: 32 })
            .enabled(!this.isLoading)
            .onClick(() => {
              this.saveUserInfo();
            })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}