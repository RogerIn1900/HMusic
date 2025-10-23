// pages/ChatPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';

interface Message {
  text: string;
  isUser: boolean;
  time: string;
}

@Builder
export function ChatPageBuilder() {
  ChatPage()
}

@Entry
@Component
struct ChatPage {
  @State messages: Message[] = [];
  @State inputValue: string = '';
  @State userName: string = '';
  @State userAvatar: Resource = $r('app.media.album1');
  @State initialMessage: string = '';
  private context = getContext(this) as Context;
  private dataPreferences: preferences.Preferences | null = null;

  async aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      this.userName = params.userName as string || '聊天';
      this.userAvatar = params.userAvatar as Resource || $r('app.media.album1');
      this.initialMessage = params.initialMessage as string || '';
    }

    // 初始化preferences
    await this.initPreferences();

    // 加载历史对话记录
    await this.loadHistoryMessages();

    // 如果没有历史记录且有初始消息，添加到消息列表
    if (this.messages.length === 0 && this.initialMessage) {
      const now = new Date();
      const time = `${now.getHours()}:${now.getMinutes().toString().padStart(2, '0')}`;
      this.messages.push({
        text: this.initialMessage,
        isUser: false,
        time: time
      });
      // 保存初始消息
      await this.saveMessages();
    }
  }

  // 初始化preferences
  async initPreferences() {
    try {
      this.dataPreferences = await preferences.getPreferences(this.context, 'chat_history');
    } catch (err) {
      console.error('Failed to get preferences:', err);
    }
  }

  // 加载历史消息
  async loadHistoryMessages() {
    if (!this.dataPreferences) return;

    try {
      const historyKey = `chat_${this.userName}`;
      const historyData = await this.dataPreferences.get(historyKey, '[]') as string;
      const historyMessages = JSON.parse(historyData) as Message[];
      this.messages = historyMessages;
    } catch (err) {
      console.error('Failed to load history messages:', err);
      this.messages = [];
    }
  }

  // 保存消息到历史记录
  async saveMessages() {
    if (!this.dataPreferences) return;

    try {
      const historyKey = `chat_${this.userName}`;
      const messagesData = JSON.stringify(this.messages);
      await this.dataPreferences.put(historyKey, messagesData);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to save messages:', err);
    }
  }

  // 清除历史记录
  async clearHistory() {
    if (!this.dataPreferences) return;

    try {
      const historyKey = `chat_${this.userName}`;
      await this.dataPreferences.delete(historyKey);
      await this.dataPreferences.flush();
      this.messages = [];
      promptAction.showToast({ message: '历史记录已清除' });
    } catch (err) {
      console.error('Failed to clear history:', err);
    }
  }

  async sendMessage() {
    if (this.inputValue.trim() === '') return;

    // 获取当前时间
    const now = new Date();
    const time = `${now.getHours()}:${now.getMinutes().toString().padStart(2, '0')}`;

    // 添加用户消息
    this.messages.push({ text: this.inputValue, isUser: true, time: time });
    const userMessage = this.inputValue;
    this.inputValue = '';

    // 保存用户消息到历史记录
    await this.saveMessages();

    // 模拟回复
    setTimeout(async () => {
      const replyTime = `${now.getHours()}:${(now.getMinutes() + 1).toString().padStart(2, '0')}`;
      this.messages.push({
        text: '(自动回复)感谢你的消息！我将尽快回复你。',
        isUser: false,
        time: replyTime
      });
      // 保存回复消息到历史记录
      await this.saveMessages();
    }, 1000);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#000000')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })

        Text(this.userName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
          .layoutWeight(1)

        Image($r('app.media.ic_more2'))
          .width(24)
          .height(24)
          .fillColor('#000000')
          .margin({ right: 16 })
          .onClick(() => {
            this.clearHistory();
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ top: 16, bottom: 16 })

      // 消息列表
      List() {
        ForEach(this.messages, (message: Message) => {
          ListItem() {
            Column() {
              Row() {
                if (!message.isUser) {
                  // 对方消息靠左显示
                  Column() {
                    Text(message.text)
                      .fontSize(16)
                      .padding(12)
                      .backgroundColor('#F5F5F5')
                      .fontColor('#000000')
                      .borderRadius(16)
                    // .maxWidth('70%')
                  }
                  .alignItems(HorizontalAlign.Start)
                } else {
                  // 用户消息靠右显示
                  Column() {
                    Text(message.text)
                      .fontSize(16)
                      .padding(12)
                      .backgroundColor('#007AFF')
                      .fontColor('#FFFFFF')
                      .borderRadius(16)
                    //.maxWidth('70%')
                  }
                  .alignItems(HorizontalAlign.End)
                }
              }
              .width('100%')
              .justifyContent(message.isUser ? FlexAlign.End : FlexAlign.Start)
              .padding({ left: 16, right: 16 })

              Text(message.time)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4, bottom: 8 })
                .alignSelf(message.isUser ? ItemAlign.End : ItemAlign.Start)
                .padding({ left: 16, right: 16 })
            }
          }
          .padding({ top: 4, bottom: 4 })
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')

      // 输入区域
      Row() {
        TextInput({
          placeholder: '输入消息...',
          text: this.inputValue
        })
          .width('80%')
          .height(40)
          .margin({ left: 16 })
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputValue = value;
          })

        Button('发送')
          .width('15%')
          .height(40)
          .margin({ right: 16 })
          .backgroundColor('#007AFF')
          .borderRadius(20)
          .fontColor('#FFFFFF')
          .onClick(() => this.sendMessage())
      }
      .width('100%')
      .height(72)
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 1 }, color: '#E5E5E5' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}