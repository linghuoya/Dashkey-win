// 显式声明全局命名空间，替代 SDK 的隐式 using（见 csproj 里 ImplicitUsings 关闭的说明）。
// 这里只放与 UI 框架无关的标准命名空间；System.Drawing / System.Windows.Forms
// 一律在需要的文件里用别名引入，避免与 WPF 同名类型冲突。
global using System;
global using System.Collections.Generic;
global using System.IO;
global using System.Linq;
global using System.Threading;
global using System.Threading.Tasks;
