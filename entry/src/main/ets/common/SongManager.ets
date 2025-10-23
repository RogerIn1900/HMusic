// 定义统一的歌曲接口
import { arrMusic, Music } from "../components/data";

// 歌曲管理类
export class SongManager {
  private static instance: SongManager;
  private songs: Music[] = arrMusic;

  // 获取单例实例
  public static getInstance(): SongManager {
    if (!SongManager.instance) {
      SongManager.instance = new SongManager();
    }
    return SongManager.instance;
  }

  // 获取所有歌曲
  public getAllSongs(): Music[] {
    return this.songs;
  }

  // 根据ID获取歌曲
  public getSongById(id: number): Music | undefined {
    return this.songs.find(song => song.id === id);
  }

  // 搜索歌曲
  public searchSongs(query: string): Music[] {
    if (!query.trim()) {
      return this.songs;
    }
    return this.songs.filter(song =>
    song.title.toLowerCase().includes(query.toLowerCase()) ||
    song.author.toLowerCase().includes(query.toLowerCase())
    );
  }

  // 添加新歌曲
  public addSong(song: Music): void {
    this.songs.push(song);
  }

  // 删除歌曲
  public removeSong(id: number): void {
    this.songs = this.songs.filter(song => song.id !== id);
  }

  // 更新歌曲信息
  public updateSong(updatedSong: Music): void {
    const index = this.songs.findIndex(song => song.id === updatedSong.id);
    if (index !== -1) {
      this.songs[index] = updatedSong;
    }
  }
}