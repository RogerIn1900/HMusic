import http from '@ohos.net.http'
import promptAction from '@ohos.promptAction'
import media from '@ohos.multimedia.media'
import { AppStorageV2 } from '@kit.ArkUI'

import { playerManager } from '../utils/index'
import { GlobalMusic } from '../models/index'
import { SongItemType} from '../interfaces/index'
import { dailyRecommend, recommendList, RecommendDailyType, RecommendListType} from "../interfaces/index"


// 定义播放器需要的歌曲数据接口
interface PlayableSong {
  img: string
  name: string
  author: string
  url: string
  id: string
}

/** 搜索返回的单条歌曲结构 */
class SearchMusicResult {
  author: string = ''
  link: string = ''
  pic: string = ''
  type: string = ''
  title: string = ''
  lrc: string = ''
  songid: number = 0
  url: string = ''
}

/** 搜索接口响应结构 */
class SearchMusicResponse {
  code: number = 0
  message: string = ''
  result: SearchMusicResult[] = []
}

/** 随机音乐数据项结构 */
class RandomMusicData {
  name: string = ''
  alname: string = ''
  id: number = 0
  url: string = ''
  picurl: string = ''
  artistsname: string = ''
}

/** 随机音乐API响应结构 */
class RandomMusicResponse {
  code: number = 0
  name: string = ''
  coverImgUrl: string = ''
  tags: string = ''
  data: RandomMusicData = new RandomMusicData()
}

/** 前端显示的歌曲模型 */
class SongInfo {
  title: string = ''
  artist: string = ''
  cover: string = ''
  link: string = ''
  url: string = ''
}

/** Image 扩展样式 */
@Extend(Image)
function fancy() {
  .width(22)
  .aspectRatio(1)
  .fillColor('#666')
}

/** 主组件 */
@Component
export struct Recommend {
  @State inputText: string = ''
  @State isLoading: boolean = false
  @State isRandomLoading: boolean = false
  @State songs: SongInfo[] = []
  @State currentPlaying: string = ''

  /** 播放器对象 */
  mediaPlayer: media.AVPlayer | null = null
  // 页面跳转控制对象
  pathStack : NavPathStack = AppStorageV2.connect(NavPathStack, 'navStack', () => new NavPathStack())!
  // 当前播放的歌曲
  playState: GlobalMusic = AppStorageV2.connect(GlobalMusic, 'SONG_KEY', () => new GlobalMusic())!

  /** 搜索歌曲请求 */
  async fetchMusicData(keyword: string): Promise<void> {
    if (!keyword || keyword.trim() === '') {
      promptAction.showToast({ message: '请输入关键词', duration: 2000 })
      return
    }

    this.isLoading = true
    this.songs = []

    const httpRequest = http.createHttp()
    try {
      const url = `http://xiaoxun.my/api/v1/search_music/?song=${encodeURIComponent(keyword)}`
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,  // 增加到10秒
        readTimeout: 10000     // 增加到10秒
      })

      const jsonStr: string =
        typeof response.result === 'string' ? response.result : JSON.stringify(response.result)

      const res: SearchMusicResponse = JSON.parse(jsonStr) as SearchMusicResponse

      if (res.code === 200 && Array.isArray(res.result)) {
        this.songs = res.result.map((item: SearchMusicResult): SongInfo => {
          const s = new SongInfo()
          s.title = item.title
          s.artist = item.author || '未知歌手'
          s.cover = item.pic || ''
          s.link = item.link
          s.url = item.url

          return s

        })

      } else {
        promptAction.showToast({ message: '未找到相关歌曲', duration: 2000 })
      }
    } catch (err) {
      console.error('请求失败:', JSON.stringify(err))
      promptAction.showToast({ message: '请求失败，请检查网络', duration: 2000 })
    } finally {
      httpRequest.destroy()
      this.isLoading = false
    }
  }

  /** 获取随机音乐 */
  async fetchRandomMusic(): Promise<void> {
    this.isRandomLoading = true

    const httpRequest = http.createHttp()
    try {
      const url = 'https://free.wqwlkj.cn/wqwlapi/wyy_random.php?type=json'
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      })

      const jsonStr: string =
        typeof response.result === 'string' ? response.result : JSON.stringify(response.result)

      const res: RandomMusicResponse = JSON.parse(jsonStr) as RandomMusicResponse

      if (res.code === 1 && res.data && res.data.url) {
        // 转换为指定格式 - 使用明确的接口类型
        const convertedData: SongItemType = {
          img: res.data.picurl || res.coverImgUrl || '',
          name: res.data.name || '未知歌曲',
          author: res.data.artistsname || '未知歌手',
          url: res.data.url,
          id: res.data.id.toString() || '0000'
        }

        // 使用hmusic标志输出日志
        console.log('hmusic', '转换后的音乐数据:', JSON.stringify(convertedData, null, 2))

        // 使用指定格式传递给singPlay方法
        this.pathStack.pushPathByName('Play', null, false)
        playerManager.singPlay(
          convertedData
        )


        this.currentPlaying = convertedData.name
        promptAction.showToast({ message: `随机播放: ${convertedData.name}`, duration: 2000 })
      } else {
        promptAction.showToast({ message: '获取随机音乐失败', duration: 2000 })
      }
    } catch (err) {
      console.error('hmusic', '获取随机音乐失败:', JSON.stringify(err))
      promptAction.showToast({ message: '获取随机音乐失败，请检查网络', duration: 2000 })
    } finally {
      httpRequest.destroy()
      this.isRandomLoading = false
    }
  }

  /** 播放音乐 */
  async playMusic(song: SongInfo) {
    // 将SongInfo转换为指定格式并传递给singPlay方法
    const convertedData: SongItemType = {
      img: song.cover || '',
      name: song.title || '未知歌曲',
      author: song.artist || '未知歌手',
      url: song.url || '',
      id: 'random_' + Date.now().toString() // 生成一个随机ID
    }

    // 使用指定格式传递给singPlay方法
    this.pathStack.pushPathByName('Play', null, false)
    playerManager.singPlay(convertedData)

    this.currentPlaying = song.title
    promptAction.showToast({ message: `正在播放: ${song.title}`, duration: 2000 })
  }

  /** 标题构建器 */
  @Builder
  titleBuilder(title: string) {
    Row() {
      Text(title)
        .fontColor('#333')
        .fontWeight(700)
        .layoutWeight(1)

      Image($r('app.media.ic_more2'))
        .width(22)
        .fillColor('#333')
    }
    .width('100%')
    .height(40)
  }

  build() {
    Column({ space: 10 }) {
      // 搜索区域
      Row() {
        Image($r('app.media.ic_search')).fancy()

        TextInput({ placeholder: '请输入歌曲名称' })
          .placeholderColor('#999')
          .padding({ left: 5, right: 5 })
          .fontColor('#333')
          .layoutWeight(1)
          .onChange((value: string) => { this.inputText = value })
          .onSubmit(() => { void this.fetchMusicData(this.inputText) })

        Image($r('app.media.ic_code')).fancy()
      }
      .width('100%')
      .backgroundColor('#F5F5F5')
      .border({ radius: 20 })
      .padding({ left: 8, right: 8 })


      // 随机播放按钮
      Row() {
        Button('随机播放', { type: ButtonType.Normal })
          .width('100%')
          .height(40)
          .fontColor('#FFFFFF')
          .backgroundColor('#007DFF')
          .borderRadius(20)
          .onClick(() => {
            void this.fetchRandomMusic()
          })
      }
      .width('100%')
      .padding({ left: 10, right: 10 })

      // 加载动画 - 搜索
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#666')
          Text('搜索中...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ left: 10 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin(10)
      }

      // 加载动画 - 随机播放
      if (this.isRandomLoading) {
        Row() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#666')
          Text('获取随机音乐中...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ left: 10 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin(10)
      }

      // 当前播放
      if (this.currentPlaying) {
        Row() {
          Text('正在播放: ')
            .fontSize(14)
            .fontColor('#666')
          Text(this.currentPlaying)
            .fontSize(14)
            .fontColor('#007DFF')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 10, right: 10 })
        .margin({ bottom: 10 })
      }

      // 搜索结果
      if (this.songs.length > 0) {
        this.titleBuilder('搜索结果')
        List() {
          ForEach(this.songs, (song: SongInfo) => {
            ListItem() {
              Row({ space: 10 }) {
                if (song.cover !== '') {
                  Image(song.cover)
                    .width(60)
                    .height(60)
                    .borderRadius(8)
                } else {
                  Image($r('app.media.ic_music'))
                    .width(60)
                    .height(60)
                    .fillColor('#999')
                }

                Column() {
                  Text(song.title)
                    .fontWeight(600)
                    .fontSize(16)
                    .fontColor('#333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(song.artist)
                    .fontSize(14)
                    .fontColor('#666')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
              }
              .padding(8)
              .onClick(() => { void this.playMusic(song) })
            }
          })
        }
        .height(350)
        .scrollBar(BarState.Off)
      }

      this.titleBuilder('每日推荐')
      List() {
        // 循环渲染多个数据
        ForEach(dailyRecommend, (item: RecommendDailyType) => {
          // 每一个具体的列表项
          ListItem() {
            // 采用垂直布局
            Column() {
              // 推荐项的标题
              Text(item.type)
                .width('100%')
                .height(40)
                .backgroundColor(item.top)
                .padding({
                  left: 5
                })
                .fontSize(14)
                .fontColor('#333333')

              // 推荐项的图片素材
              Image(item.img)
                .width('100%')

              // 推荐项描述文字
              Text(item.title)
                .width('100%')
                .backgroundColor(item.bottom)
                .padding(5)
                .fontSize(14)
                .fontColor('#333333')
                .maxLines(2) // 文字显示的最大行数
                .textOverflow({ overflow: TextOverflow.Ellipsis }) // 当文本超出指定长度时的显示样式
            }
            .width('40%')
            // .height(200)
            // .backgroundColor(Color.Pink)
            .borderRadius(10)
            .margin({
              right: 10
            })
            .clip(true) // 裁剪，在谁身上就裁剪谁
          }
        })
      }
      .listDirection(Axis.Horizontal) // 调整list组件的布局方向
      .height(230)
      .scrollBar(BarState.Off) // 去除滑动条


      // 每日歌单区域
      this.titleBuilder('推荐歌单')
      List() {
        // 循环渲染多个数据
        ForEach(recommendList, (item: RecommendListType) => {
          // 具体数据项
          ListItem() {
            // 采用垂直布局
            Column() {
              // 采用层叠布局
              Stack({ alignContent: Alignment.TopStart }) {
                // 数据项的图片
                Image(item.img)
                  .width('100%')
                  .height(100)
                  .borderRadius(8)

                // 文播放量
                Text(item.count)
                  .fontColor('#333333')
                  .fontSize(12)
                  .fontWeight(700)
                  .margin(5)
              }

              // 数据项内容
              Text(item.title)
                .fontColor('#333333')
                .fontSize(14)
                .width('100%')
                .padding(5)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('30%')
            .margin({
              right: 10
            })
          }
        })
      }
      .listDirection(Axis.Horizontal)
      .height(230)
      .scrollBar(BarState.Off) // 去除滑动条
    }
    .width('100%')
    .height('100%')
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
  }
}