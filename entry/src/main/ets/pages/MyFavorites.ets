import { router } from '@kit.ArkUI';
import { SongItemType, songs } from '../interfaces/iSongs';

// 页面入口函数
@Builder
export function MyFavoritesBuilder() {
  MyFavorites()
}

// 格式化时间函数
function format2Time(seconds: number): string {
  const minutes = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

@Entry
@Component
struct MyFavorites {
  @State favoriteSongs: SongItemType[] = songs.slice(0, 5); // 示例：显示前5首歌作为收藏

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#000000')
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })

        Text('我喜欢的音乐')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .padding({ top: 16, bottom: 16 })

      // 歌曲列表
      List() {
        ForEach(this.favoriteSongs, (song: SongItemType, index: number) => {
          ListItem() {
            Row() {
              // 序号
              Text((index + 1).toString())
                .fontSize(16)
                .fontColor('#999999')
                .width(40)
                .textAlign(TextAlign.Center)

              // 歌曲封面
              Image(song.img)
                .width(48)
                .height(48)
                .borderRadius(4)
                .margin({ right: 12 })
                .objectFit(ImageFit.Cover)

              // 歌曲信息
              Column() {
                Text(song.name)
                  .fontSize(16)
                  .fontColor('#333333')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(song.author)
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 4 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)

              // 时长（显示占位符，因为 SongItemType 没有 duration 字段）
              Text('--:--')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ right: 16 })
            }
            .width('100%')
            .height(72)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .onClick(() => {
              // 点击播放歌曲
              router.pushUrl({
                url: 'pages/Play',
                params: {
                  songIndex: index
                }
              });
            })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#F5F5F5' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 