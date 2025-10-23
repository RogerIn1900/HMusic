import { router } from '@kit.ArkUI'
import { AppStorageV2 } from '@kit.ArkUI'
import { GlobalMusic } from '../models/index'
import { playerManager } from '../utils/index'

@Component
export struct GlobalMusicPlayer {
  // 共享的音乐数据
  currentSong: GlobalMusic = AppStorageV2.connect(GlobalMusic, 'SONG_KEY', () => new GlobalMusic())!

  build() {
    Row({ space: 10 }) {
      // 歌曲封面
      Image(this.currentSong.img || $r('app.media.ic_cd'))
        .width(50)
        .height(50)
        .borderRadius(8)
        .margin({ left: 16 })

      // 歌曲信息
      Column({ space: 4 }) {
        Text(this.currentSong.name || '暂无播放')
          .fontSize(16)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.currentSong.author || '未知歌手')
          .fontSize(12)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ right: 10 })

      // 播放/暂停按钮
      Image(this.currentSong.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
        .width(32)
        .height(32)
        .margin({ right: 10 })
        .onClick(() => {
          if (this.currentSong.isPlay) {
            playerManager.paused()
          } else {
            playerManager.singPlay(this.currentSong.playList[this.currentSong.playIndex])
          }
        })

      // 播放列表按钮
      Image($r('app.media.ic_list'))
        .width(28)
        .height(28)
        .margin({ right: 16 })
        .onClick(() => {
          // 打开播放列表
        })
    }
    .width('100%')
    .height(70)
    .backgroundColor('#FFFFFF')
    .borderRadius({ topLeft: 16, topRight: 16 })
    .shadow({
      radius: 8,
      color: '#1F000000',
      offsetY: -2
    })
    .onClick(() => {
      // 跳转到播放页面
      if (this.currentSong.url) {
        router.pushUrl({
          url: 'pages/Play'
        })
      }
    })
  }
}

