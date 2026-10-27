# DashKey for Windows

[DashKey](https://github.com/linghuoya/Dashkey) 的 Windows 版：一个任务栏应用快捷键切换器。读取任务栏固定项，给每个应用分配 `Alt + 键` 全局快捷键，按住 `Alt` 或按 `Alt + 反引号` 弹出图标面板快速切换。

**实现方式：C# / .NET 8 + WPF，零第三方依赖**，系统能力全部走 Win32 P/Invoke（不引入任何 NuGet 包）。

## 下载

前往 [Releases](https://github.com/linghuoya/Dashkey-win/releases) 下载。

| 架构 | 适用机器 |
| --- | --- |
| `win-x64` | 绝大多数 Intel / AMD 电脑 |
| `win-arm64` | 骁龙等 Windows on ARM 设备 |

解压后直接运行 `DashKey.exe`，无安装程序。首次运行可能被 SmartScreen 拦（未签名），点「更多信息」→「仍要运行」。

> 未发布 Release 时，可从 [Actions](https://github.com/linghuoya/Dashkey-win/actions) 的运行记录底部 `Artifacts` 下载刚构建的 exe（需登录 GitHub）。

## 特性

- **快捷键切换应用**：按任务栏物理顺序自动分配 `Alt` 组合键
  `1 2 3 4 5 6 7 8 9 0` → `Q W E R T Y U I O P` → `A S D F G H J K L` → `Z X C V B N M`，共 36 个
- **两种呼出方式**，可在设置里分别开关：
  - 长按 `Alt`（轮询 `GetAsyncKeyState`，不装键盘钩子）
  - `Alt + 反引号键` 开/关面板（`Alt + Space` 被系统占用）
- **图标面板**：透明背景、迷你图标、单行居中，角标叠在图标右下角
- **系统托盘**：双击开关面板，右键出菜单
- **单实例**：同一时间只允许运行一个 DashKey
- **图标清晰度可调**：省内存 / 标准 / 高清
- **开机启动**：写 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`

## 构建

需要 [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)，不需要 Visual Studio。

```powershell
.\build.ps1                  # 单文件，依赖目标机器已装 .NET 8 桌面运行时
.\build.ps1 -SelfContained   # 自带运行时，体积大但免装 .NET
.\build.ps1 -Runtime win-arm64   # 指定架构，默认 win-x64
```

产物在 `Build\DashKey-<runtime>\DashKey.exe`。

也可以直接调用 dotnet：

```powershell
dotnet publish .\DashKey.Windows.csproj -c Release -r win-x64 -p:PublishSingleFile=true
```

> macOS / Linux 上无法构建（WPF 仅支持 Windows）。用仓库自带的 GitHub Actions 工作流（`.github/workflows/build-windows.yml`）在 GitHub 托管的 Windows 机器上构建，或在 Windows 物理机 / 虚拟机里构建。

## 使用

1. 运行 `DashKey.exe`，托盘出现键盘图标（无主窗口，单实例）；
2. 按住 `Alt` 约 2 秒，鼠标所在屏幕中央浮出图标面板，松开收起；
3. 面板显示时按 `Alt + 1` … `Alt + M` 切到对应应用，或直接用鼠标点图标；
4. 托盘图标双击开关面板，右键出菜单（设置 / 重新读取 / 退出）。

## 设置项

| 项目 | 说明 |
| --- | --- |
| 长按触发时长 | 0.5 – 3.0 秒 |
| 调出面板 | 分别开关「长按 Alt」与快捷键 |
| 快捷键前缀 | `Alt` 或 `Ctrl + Alt` |
| 图标清晰度 | 省内存 / 标准 / 高清 |
| 开机启动 | 写 `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` |

配置存在 `HKCU\Software\DashKey`，日志在 `%AppData%\DashKey\dashkey.log`。

## 与 macOS 版的对应关系

| macOS | Windows |
| --- | --- |
| 菜单栏图标 | 系统托盘图标 |
| 读 Dock（`persistent-apps`） | 读任务栏固定项（`…\User Pinned\TaskBar\*.lnk`） |
| `Option + 键` | `Alt + 键`（设置里可改为 `Ctrl + Alt + 键`） |
| `⌥Space` 开关面板 | `Alt + 反引号键` 开关面板 |
| 长按 `Option` 呼出 | 长按 `Alt` 呼出 |
| 隐藏应用 | 最小化窗口 |

## 已知差异与限制

- **`Alt + 字母` 会抢掉其他程序的菜单快捷键**。Windows 上前台程序的 `Alt+F` 之类靠键盘消息处理，`RegisterHotKey` 优先级更高。介意的话把前缀切成 `Ctrl + Alt`。
- **内存占用做不到 macOS 版的 30 MB**。WPF 运行时基线本身就在 80 MB 量级，这是框架成本；图标仍按清晰度降采样到 48 / 64 / 96 px，且只加载前 36 个。
- **任务栏固定项顺序靠解析 `Taskband\Favorites` 的二进制值**，解析失败时退化为按名称排序，编号可能和任务栏视觉顺序不一致。
- 只认 `.lnk` 固定项；UWP / Store 应用固定项若没有对应 `.lnk` 则不会出现。

## License

Apache License 2.0，见 [LICENSE](LICENSE)。
