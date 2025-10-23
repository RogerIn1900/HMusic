import dataPreferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';

// 用户接口
export interface User {
  username: string;
  password: string;
  nickname?: string;
  avatar?: string;
}

export class ClsLogin {
  private preferences: dataPreferences.Preferences | null = null;
  private user: User | null = null;
  private userInfoUpdateCallbacks: (() => void)[] = [];

  constructor() {
    this.initPreferences();
  }

  private async initPreferences() {
    try {
      this.preferences = await dataPreferences.getPreferences(getContext(), 'userInfo');
      // 检查是否存在默认用户
      const existingUsers: string = await this.preferences.get('users', '[]') as string;
      const users: User[] = JSON.parse(existingUsers);
      // 如果用户列表为空，添加默认用户
      if (users.length === 0) {
        const defaultUser: User = {
          username: '13800138000',
          password: 'Music123'
        };
        users.push(defaultUser);
        await this.preferences.put('users', JSON.stringify(users));
        await this.preferences.flush();
      }
    } catch (error) {
      console.error(`初始化首选项失败: ${error}`);
    }
  }

  async userLogin(username: string, password: string, onSuccess: () => void, onFail: () => void) {
    try {
      // 检查是否是默认账号
      if (username === '13800138000' && password === 'Music123') {
        this.user = { username, password };
        if (this.preferences) {
          await this.preferences.put('currentUser', JSON.stringify(this.user));
          await this.preferences.flush();
        }
        onSuccess();
        return;
      }

      if (!this.preferences) {
        await this.initPreferences();
        if (!this.preferences) {
          promptAction.showToast({ message: '系统错误，请稍后重试' });
          onFail();
          return;
        }
      }

      const existingUsers: string = await this.preferences.get('users', '[]') as string;
      const users: User[] = JSON.parse(existingUsers);
      const user: User | undefined = users.find((u: User) => u.username === username && u.password === password);

      //读取验证，查看所有账号及密码
      const jsonStr = await this.preferences.get('users','');

      if (user) {
        this.user = user;
        await this.preferences.put('currentUser', JSON.stringify(user));
        await this.preferences.flush();
        onSuccess();
      } else {
        promptAction.showToast({ message: '用户名或密码错误' });


        onFail();
      }
    } catch (error) {
      console.error(`登录失败: ${error}`);
      promptAction.showToast({ message: '登录失败，请稍后重试' });
      onFail();
    }
  }

  async logout() {
    try {
      if (this.preferences) {
        await this.preferences.delete('currentUser');
        await this.preferences.flush();
      }
      this.user = null;
    } catch (error) {
      console.error(`登出失败: ${error}`);
    }
  }

  isLoggedIn(): boolean {
    return this.user !== null;
  }

  getCurrentUser(): User | null {
    return this.user;
  }

  userFlag(): boolean {
    return this.isLoggedIn();
  }


  checkNameAndPass(username: string, password: string): boolean {
    // 验证手机号格式（11位数字）
    const phoneRegex = /^1[3-9]\d{9}$/;
    // 验证密码格式（至少6位，包含字母和数字）
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/;
    return phoneRegex.test(username) && passwordRegex.test(password);
  }

  // 获取用户显示名称
  getUserDisplayName(): string {
    const currentUser = this.getCurrentUser();
    if (currentUser) {
      return currentUser.nickname || currentUser.username;
    }
    return '未登录';
  }

  // 获取用户头像
  getUserAvatar(): string {
    const currentUser = this.getCurrentUser();
    if (currentUser && currentUser.avatar) {
      return currentUser.avatar;
    }
    // 默认头像
    return 'default';
  }

  // 更新用户信息
  async updateUserInfo(nickname: string, avatar: string): Promise<boolean> {
    try {
      if (!this.preferences) {
        await this.initPreferences();
      }
      
      const currentUser = this.getCurrentUser();
      if (currentUser && this.preferences) {
        const updatedUser: User = {
          username: currentUser.username,
          password: currentUser.password,
          nickname: nickname,
          avatar: avatar
        };
        
        // 更新当前用户信息
        await this.preferences.put('currentUser', JSON.stringify(updatedUser));
        
        // 更新用户列表中的信息
        const existingUsers: string = await this.preferences.get('users', '[]') as string;
        const users: User[] = JSON.parse(existingUsers);
        const userIndex = users.findIndex((u: User) => u.username === currentUser.username);
        if (userIndex !== -1) {
          users[userIndex] = updatedUser;
          await this.preferences.put('users', JSON.stringify(users));
        }
        
        await this.preferences.flush();
        this.user = updatedUser;
        // 触发用户信息更新回调
        this.triggerUserInfoUpdate();
        return true;
      }
      return false;
    } catch (error) {
      console.error(`更新用户信息失败: ${error}`);
      return false;
    }
  }

  // 初始化用户信息（设置默认昵称）
  async initUserInfo(): Promise<void> {
    try {
      const currentUser = this.getCurrentUser();
      if (currentUser && !currentUser.nickname) {
        await this.updateUserInfo(currentUser.username, 'default');
      }
    } catch (error) {
      console.error(`初始化用户信息失败: ${error}`);
    }
  }

  // 注册用户信息更新回调
  onUserInfoUpdate(callback: () => void): void {
    this.userInfoUpdateCallbacks.push(callback);
  }

  // 移除用户信息更新回调
  offUserInfoUpdate(callback: () => void): void {
    const index = this.userInfoUpdateCallbacks.indexOf(callback);
    if (index > -1) {
      this.userInfoUpdateCallbacks.splice(index, 1);
    }
  }

  // 触发用户信息更新回调
  triggerUserInfoUpdate(): void {
    this.userInfoUpdateCallbacks.forEach((callback) => {
      try {
        callback();
      } catch (error) {
        console.error('用户信息更新回调执行失败:', error);
      }
    });
  }
}

export const login = new ClsLogin();