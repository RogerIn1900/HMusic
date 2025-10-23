import { router } from "@kit.ArkUI";
import promptAction from '@ohos.promptAction';

// 定义消息项接口
interface MessageItem {
  id: number;
  name: string;
  content: string;
  category: string;
  color: string;
  time: string;
  unread: number;
  avatar: Resource;
}

@Component
export struct Message {
  @State activeTab: number = 0;
  @State searchText: string = '';
  @State filteredMessages: MessageItem[] = [];
  @State showSearchSuggestions: boolean = false;
  @State searchHistory: string[] = [];
  @State messages: MessageItem[] = [
    {
      id: 1,
      name: "界面达人",
      content: "你好，请问你对最新的数据有什么建议吗？我觉得你的动作编辑软件业务是能帮你多交流学习一下，我想还在排练一个新的界面作品。关于现代弹与传统玩游戏结合的主题。",
      category: "设计",
      color: "#0A59F7",
      time: "10:30",
      unread: 0,
      avatar: $r('app.media.album1')
    },
    {
      id: 2,
      name: "音乐制作人",
      content: "那边上传了新的音乐，希望你能听听，给您建议！这是我的创作的电子招风格作品。融合了一些风格乐器的元素，比如古筝和二胡，想做一些跨界的尝试。",
      category: "音乐",
      color: "#F70A4A",
      time: "09:15",
      unread: 0,
      avatar: $r('app.media.album2')
    },
    {
      id: 3,
      name: "旅行达人",
      content: "你分享的那个地方太美了，下次我也想去！能告诉我具体在哪个城市吗？交通便利吗？需要提前多久预订住宿比较合适？听说那边的美食也非常出名，有什么特别推荐的当地小吃吗？",
      category: "旅行",
      color: "#0FBA83",
      time: "昨天",
      unread: 0,
      avatar: $r('app.media.album3')
    },
    {
      id: 4,
      name: "美食博主",
      content: "谢谢关注！我会继续分享更多美食制作教程的。下周我们算唯一期火锅店到自助专程。",
      category: "美食",
      color: "#F7930A",
      time: "昨天",
      unread: 0,
      avatar: $r('app.media.album1')
    },
    {
      id: 5,
      name: "摄影师小王",
      content: "最近有新闻报道了吗？我想开晚一下器材，预制大碟一万左右，主要把风扇和人像。",
      category: "摄影",
      color: "#800AF7",
      time: "周一",
      unread: 0,
      avatar: $r('app.media.album2')
    },
    {
      id: 6,
      name: "健身教练",
      content: "下面视频来自我的排行榜，用户主要是1秒为首，用的是摄影，两人都有相同的体验力。",
      category: "健身",
      color: "#0ABDF7",
      time: "周一",
      unread: 0,
      avatar: $r('app.media.album3')
    }
  ];

  aboutToAppear() {
    // 初始化时显示所有消息
    this.filteredMessages = this.messages.slice();
  }

  // 搜索过滤方法
  filterMessages(searchText: string) {
    if (!this.searchText || this.searchText.trim() === '') {
      // 如果搜索文本为空，显示所有消息
      this.filteredMessages = this.messages.slice();
    } else {
      // 只根据用户名进行精确搜索
      this.filteredMessages = this.messages.filter(message => {
        const searchLower = this.searchText.toLowerCase();
        return message.name.toLowerCase().includes(searchLower);
      });
    }
  }

  // 高亮搜索关键词
  highlightText(text: string, searchText: string): string {
    if (!searchText || searchText.trim() === '') {
      return text;
    }

    const regex = new RegExp(`(${searchText})`, 'gi');
    return text.replace(regex, '<mark>$1</mark>');
  }

  // 获取搜索建议
  getSearchSuggestions(searchText: string): string[] {
    if (!searchText || searchText.trim() === '') {
      return [];
    }

    const suggestions: string[] = [];
    const searchLower = searchText.toLowerCase();

    // 只从用户名中提取建议
    this.messages.forEach(message => {
      if (message.name.toLowerCase().includes(searchLower)) {
        suggestions.push(message.name);
      }
    });

    // 去重并限制数量
    const uniqueSuggestions = Array.from(new Set(suggestions));
    return uniqueSuggestions.slice(0, 5);
  }

  // 添加搜索历史
  addToSearchHistory(searchText: string) {
    if (searchText && searchText.trim() !== '') {
      const trimmedText = searchText.trim();
      // 移除重复项
      this.searchHistory = this.searchHistory.filter(item => item !== trimmedText);
      // 添加到开头
      this.searchHistory.unshift(trimmedText);
      // 限制历史记录数量
      this.searchHistory = this.searchHistory.slice(0, 10);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {

        Row() {
          Image($r('app.media.ic_more2'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .onClick(() => {
              promptAction.showToast({ message: '更多选项' });
            })

          Text('消息')
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Image($r('app.media.ic_add'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .margin({ right: 20 })
            .onClick(() => {
              promptAction.showToast({ message: '新建消息' });
            })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#ffffffff')


      // 搜索区域
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .fillColor('#999999')
          .margin({ left: 15, right: 10 })
          .onClick(() => {
            if (this.searchText) {
              // 如果有搜索内容，清除搜索
              this.searchText = '';
              this.filterMessages('');
            }
          })

        TextInput({
          placeholder: '搜索联系人',
          text: this.searchText
        })
          .fontSize(16)
          .placeholderFont({ size: 16, weight: FontWeight.Normal })
          .placeholderColor('#AAAAAA')
          .height(40)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value;
            this.filterMessages(value);
            this.showSearchSuggestions = value.length > 0;
          })
          .onFocus(() => {
            this.showSearchSuggestions = this.searchText.length > 0;
          })
          .onBlur(() => {
            // 延迟隐藏建议，让用户有时间点击
            setTimeout(() => {
              this.showSearchSuggestions = false;
            }, 200);
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .padding({ right: 15 })
      .margin({ top: 8 })

      // 搜索建议下拉列表
      if (this.showSearchSuggestions) {
        Column() {
          // 搜索建议
          if (this.getSearchSuggestions(this.searchText).length > 0) {
            Column() {
              Text('搜索建议')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 16, top: 8, bottom: 4 })
                .alignSelf(ItemAlign.Start)

              ForEach(this.getSearchSuggestions(this.searchText), (suggestion: string) => {
                Row() {
                  Image($r('app.media.ic_search'))
                    .width(16)
                    .height(16)
                    .fillColor('#999999')
                    .margin({ right: 8 })

                  Text(suggestion)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => {
                  this.searchText = suggestion;
                  this.filterMessages(suggestion);
                  this.showSearchSuggestions = false;
                  this.addToSearchHistory(suggestion);
                })
              })
            }
          }

          // 搜索历史
          if (this.searchHistory.length > 0) {
            Column() {
              Text('搜索历史')
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 16, top: 8, bottom: 4 })
                .alignSelf(ItemAlign.Start)

              ForEach(this.searchHistory.slice(0, 5), (historyItem: string) => {
                Row() {
                  Image($r('app.media.ic_search'))
                    .width(16)
                    .height(16)
                    .fillColor('#999999')
                    .margin({ right: 8 })

                  Text(historyItem)
                    .fontSize(14)
                    .fontColor('#666666')
                    .layoutWeight(1)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .onClick(() => {
                  this.searchText = historyItem;
                  this.filterMessages(historyItem);
                  this.showSearchSuggestions = false;
                })
              })
            }
          }
        }
        .width('100%')
        .backgroundColor(Color.White)
        .border({ width: { bottom: 1 }, color: '#E5E5E5' })
        .margin({ top: 1 })
      }

      // 搜索结果统计
      if (this.searchText) {
        Row() {
          Text(`找到 ${this.filteredMessages.length} 个相关联系人`)
            .fontSize(14)
            .fontColor('#666666')

          Blank()

          Text('清除搜索')
            .fontSize(14)
            .fontColor('#007AFF')
            .onClick(() => {
              this.searchText = '';
              this.filterMessages('');
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('#F8F9FA')
        .margin({ top: 8 })
      }

      // 搜索结果提示
      if (this.searchText && this.filteredMessages.length === 0) {
        Column() {
          Image($r('app.media.ic_search'))
            .width(48)
            .height(48)
            .fillColor('#CCCCCC')
            .margin({ bottom: 16 })

          Text('未找到相关联系人')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 8 })

          Text(`没有找到包含"${this.searchText}"的联系人`)
            .fontSize(14)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(Color.White)
        .margin({ top: 8 })
      }

      // 消息列表
      List() {
        ForEach(this.filteredMessages, (message: MessageItem) => {
          ListItem() {
            Row() {
              // 头像
              Stack() {
                Image(message.avatar)
                  .width(56)
                  .height(56)
                  .borderRadius(28)
                  .objectFit(ImageFit.Cover)

                if (message.unread > 0) {
                  Text(message.unread.toString())
                    .fontSize(12)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Bold)
                    .backgroundColor('#FF3B30')
                    .borderRadius(10)
                    .width(20)
                    .height(20)
                    .textAlign(TextAlign.Center)
                    .position({ x: 40, y: 0 })
                }
              }
              .margin({ right: 15 })

              // 消息内容
              Column() {
                Row() {
                  Text(message.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#222222')
                    .layoutWeight(1)

                  Text(message.time)
                    .fontSize(13)
                    .fontColor('#999999')
                }

                Text(message.content)
                  .fontSize(15)
                  .fontColor('#666666')
                  .margin({ top: 5, bottom: 5 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                // 类别标签
                Text(message.category)
                  .fontSize(12)
                  .fontColor(message.color)
                  .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                  .backgroundColor(`${message.color}33`)
                  .borderRadius(4)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(15)
            .backgroundColor(Color.White)
            .onClick(() => {
              router.pushUrl({
                url: "pages/ChatPage",
                params: {
                  userName: message.name,
                  userAvatar: message.avatar,
                  initialMessage: message.content
                }
              })
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#f0f2f5', startMargin: 80, endMargin: 0 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f7fa')
  }
}

