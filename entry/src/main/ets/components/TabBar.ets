import { tabData, TabClass } from '../interfaces/iTabs'
import { Find, Mine, Message, Recommend } from './index'

@Component
export struct TabBar {
  @Link selectedIndex: number
  @Prop currentIndex: number

  // 自定义的导航栏的结构
  @Builder tabBuilder(item: TabClass, index: number) {
    // 采用垂直布局
    Column({ space: 8 }) {
      // 导航图标
      Image(item.icon)
        .width(24)
        .aspectRatio(1)
        .margin({
          top: 2,
          bottom: 2
        })
        .fillColor(this.selectedIndex === index ? '#e85a88' : '#999999')

      // 导航文本
      Text(item.text)
        .fontSize(14)
        .fontColor(this.selectedIndex === index ? '#e85a88' : '#999999')
    }
  }

  build() {
    // 使用tab组件设计布局
    Tabs({ barPosition: BarPosition.End }) {
      // 使用循环渲染的方式加载导航栏信息
      ForEach(tabData, (item: TabClass, index: number) => {
        // 导航栏内容
        TabContent() {
          // 使用条件渲染的方式来加载不同的组件内容
          if (this.selectedIndex === 0) {
            Recommend()
          } else if (this.selectedIndex === 1) {
            Find()
          } else if (this.selectedIndex === 2) {
            Message()
          } else {
            Mine()
          }
        }
        .tabBar(this.tabBuilder(item, index)) // 我们将自定义导航栏的样式和结构
        .backgroundColor('#FFFFFF')
      }, (item: TabClass) => item.text)
    }
    .backgroundColor('#F5F5F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onChange((index: number) => {
      this.selectedIndex = index
    })
  }
}

