export interface TabItemConfig {
  name: string;
  selectedIcon: ResourceStr;
  unselectedIcon: ResourceStr;
}

export class TabConfig {
  static readonly HOME: TabItemConfig = {
    name: '首页',
    selectedIcon: $r("app.media.ic_contacts"),
    unselectedIcon: $r("app.media.ic_contacts1")
  }

  static readonly FIND: TabItemConfig = {
    name: '发现',
    selectedIcon: $r("app.media.ic_search"),
    unselectedIcon: $r("app.media.ic_search1")
  }

  static readonly PLAYLIST: TabItemConfig = {
    name: '歌单',
    selectedIcon: $r("app.media.menu3"),
    unselectedIcon: $r("app.media.menu1")
  }

  static readonly MESSAGE: TabItemConfig = {
    name: '消息',
    selectedIcon: $r("app.media.ic_message4"),
    unselectedIcon: $r("app.media.ic_message5")
  }

  static readonly MINE: TabItemConfig = {
    name: '我',
    selectedIcon: $r("app.media.ic_me"),
    unselectedIcon: $r("app.media.ic_me1")
  }
}

export class LayoutConfig {
  static readonly PLAYER_HEIGHT = 120;
  static readonly TAB_BAR_HEIGHT = 50;
  static readonly ICON_SIZE = 25;
}