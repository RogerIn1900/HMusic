/**
 * 应用常量配置
 */
export class LayoutConfig {
  // 播放器高度
  static readonly PLAYER_HEIGHT: string = '70vp'
  
  // 标签栏高度
  static readonly TAB_BAR_HEIGHT: string = '56vp'
  
  // 顶部安全区高度
  static readonly STATUS_BAR_HEIGHT: string = '24vp'
}

/**
 * 页面路由常量
 */
export class RouteConstants {
  static readonly INDEX_PAGE: string = 'pages/Index'
  static readonly LAYOUT_PAGE: string = 'pages/Layout'
  static readonly PLAY_PAGE: string = 'pages/Play'
  static readonly LOGIN_PAGE: string = 'pages/Login'
  static readonly START_PAGE: string = 'pages/Start'
  static readonly USER_SETTINGS_PAGE: string = 'pages/UserSettings'
  static readonly MY_FAVORITES_PAGE: string = 'pages/MyFavorites'
}

/**
 * 本地存储键名常量
 */
export class StorageConstants {
  static readonly USER_INFO: string = 'userInfo'
  static readonly PLAY_LIST: string = 'playList'
  static readonly FAVORITES: string = 'favorites'
}

/**
 * 播放模式常量
 */
export class PlayModeConstants {
  static readonly AUTO: string = 'auto'      // 列表循环
  static readonly RANDOM: string = 'random'   // 随机播放
  static readonly REPEAT: string = 'repeat'   // 单曲循环
}

