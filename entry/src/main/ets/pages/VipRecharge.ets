import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

// 页面入口函数
@Builder
export function VipRechargeBuilder() {
  VipRecharge()
}

// VIP套餐类型定义
class VipPlan {
  id: number = 0
  name: string = ''
  price: string = ''
  originalPrice: string = ''
  unit: string = ''
  desc: string = ''
  badge: string = ''
}

// VIP权益类型定义
class VipRight {
  icon: string = ''
  title: string = ''
  desc: string = ''
}

@Entry
@Component
struct VipRecharge {
  @State selectedPlan: number = 1 // 默认选中连续包月
  
  // VIP套餐数据
  private vipPlans: VipPlan[] = [
    { 
      id: 0, 
      name: '连续包月', 
      price: '12', 
      originalPrice: '15',
      unit: '元/月',
      desc: '自动续费，随时取消',
      badge: '首月特惠'
    },
    { 
      id: 1, 
      name: '连续包年', 
      price: '108', 
      originalPrice: '180',
      unit: '元/年',
      desc: '平均仅需9元/月',
      badge: '超值推荐'
    },
    { 
      id: 2, 
      name: '单月卡', 
      price: '15', 
      originalPrice: '',
      unit: '元/月',
      desc: '一次性购买，无需续费',
      badge: ''
    }
  ]
  
  // VIP权益列表
  private vipRights: VipRight[] = [
    { icon: '🎵', title: '海量曲库', desc: '畅听千万正版音乐' },
    { icon: '📱', title: '多端同步', desc: '手机、平板、电脑同步' },
    { icon: '🎧', title: '超清音质', desc: '无损音质，享受极致体验' },
    { icon: '📥', title: '无限下载', desc: '离线畅听，随时随地' },
    { icon: '🎁', title: '专属特权', desc: 'VIP专属歌单和活动' },
    { icon: '🚫', title: '去广告', desc: '畅享无打扰音乐体验' }
  ]
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back()
          })
        
        Text('开通黑胶VIP')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位，保持标题居中
        Row().width(24).height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 0.5 }, color: '#E0E0E0' })
      
      Scroll() {
        Column() {
          // VIP会员卡展示
          Column() {
            // 金色渐变背景
            Column() {
              // VIP标题
              Row() {
                Text('黑胶VIP')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                
                Text('会员')
                  .fontSize(16)
                  .fontColor('rgba(255, 255, 255, 0.8)')
                  .margin({ left: 8, top: 8 })
              }
              .margin({ top: 30 })
              
              Text('尊享音乐生活')
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.9)')
                .margin({ top: 8, bottom: 30 })
            }
            .width('100%')
            .linearGradient({
              angle: 135,
              colors: [['#FFD700', 0.0], ['#FFA500', 1.0]]
            })
            .borderRadius(20)
            .shadow({ radius: 20, color: 'rgba(255, 215, 0, 0.3)', offsetX: 0, offsetY: 10 })
          }
          .width('90%')
          .margin({ top: 20, bottom: 30 })
          
          // 套餐选择标题
          Text('选择套餐')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('90%')
            .margin({ bottom: 16 })
          
          // VIP套餐列表
          Column({ space: 12 }) {
            ForEach(this.vipPlans, (plan: VipPlan) => {
              this.createPlanCard(plan)
            })
          }
          .width('90%')
          .margin({ bottom: 30 })
          
          // VIP权益标题
          Text('VIP权益')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .width('90%')
            .margin({ bottom: 16 })
          
          // VIP权益列表
          Column({ space: 16 }) {
            ForEach(this.vipRights, (right: VipRight) => {
              this.createRightItem(right)
            })
          }
          .width('90%')
          .margin({ bottom: 100 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      
      // 底部购买按钮
      Column() {
        // 价格信息
        Row() {
          Text('¥')
            .fontSize(18)
            .fontColor('#FF6B6B')
            .fontWeight(FontWeight.Bold)
          
          Text(this.vipPlans[this.selectedPlan].price)
            .fontSize(32)
            .fontColor('#FF6B6B')
            .fontWeight(FontWeight.Bold)
          
          if (this.vipPlans[this.selectedPlan].originalPrice) {
            Text('¥' + this.vipPlans[this.selectedPlan].originalPrice)
              .fontSize(14)
              .fontColor('#999999')
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 8 })
          }
        }
        .margin({ bottom: 12 })
        
        // 立即开通按钮
        Button('立即开通')
          .width('90%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#FFD700')
          .borderRadius(25)
          .onClick(() => {
            // 模拟支付流程
            promptAction.showToast({ 
              message: '正在跳转支付...',
              duration: 2000
            })
            
            setTimeout(() => {
              promptAction.showToast({ 
                message: '开通成功！感谢您的支持',
                duration: 2000
              })
              setTimeout(() => {
                router.back()
              }, 2000)
            }, 1500)
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { top: 0.5 }, color: '#E0E0E0' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  // 创建套餐卡片
  @Builder
  createPlanCard(plan: VipPlan) {
    Stack() {
      // 推荐标签
      if (plan.badge) {
        Text(plan.badge)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF6B6B')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .borderRadius({ topLeft: 20, bottomRight: 20 })
          .position({ x: 0, y: 0 })
          .zIndex(1)
      }
      
      Row() {
        // 左侧信息
        Column() {
          Text(plan.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.selectedPlan === plan.id ? '#FFD700' : '#333333')
          
          Text(plan.desc)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 中间价格
        Column() {
          Row() {
            Text('¥')
              .fontSize(14)
              .fontColor(this.selectedPlan === plan.id ? '#FFD700' : '#333333')
              .fontWeight(FontWeight.Bold)
            
            Text(plan.price)
              .fontSize(24)
              .fontColor(this.selectedPlan === plan.id ? '#FFD700' : '#333333')
              .fontWeight(FontWeight.Bold)
          }
          
          if (plan.originalPrice) {
            Text('¥' + plan.originalPrice)
              .fontSize(12)
              .fontColor('#999999')
              .decoration({ type: TextDecorationType.LineThrough })
          }
        }
        .margin({ right: 16 })
        
        // 右侧选择框
        Stack() {
          Circle()
            .width(24)
            .height(24)
            .border({ 
              width: 2, 
              color: this.selectedPlan === plan.id ? '#FFD700' : '#CCCCCC' 
            })
            .backgroundColor(this.selectedPlan === plan.id ? '#FFD700' : '#FFFFFF')
          
          if (this.selectedPlan === plan.id) {
            Text('✓')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(this.selectedPlan === plan.id ? 'rgba(255, 215, 0, 0.1)' : '#FFFFFF')
    .borderRadius(20)
    .border({ 
      width: 2, 
      color: this.selectedPlan === plan.id ? '#FFD700' : '#E0E0E0' 
    })
    .onClick(() => {
      this.selectedPlan = plan.id
    })
  }
  
  // 创建权益项
  @Builder
  createRightItem(right: VipRight) {
    Row() {
      Text(right.icon)
        .fontSize(32)
        .width(50)
        .textAlign(TextAlign.Center)
      
      Column() {
        Text(right.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Text(right.desc)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}

