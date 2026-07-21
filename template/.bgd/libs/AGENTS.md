# AGENTS.md — 游戏项目（BGD 框架）

> 本文件面向在这个星火编辑器（SCE）游戏项目里工作的 AI 编程代理。遵循 [agents.md](https://agents.md/) 规范。
> 本项目使用 BGD 框架 + bgd_sce_tools 构建工具，请先理解下面的结构与规则再动手。

## 项目结构速览

```
.bgd/
  libs/     # 框架代码（工具管理，**禁止修改/新增**，框架更新只碰这里）
  src/      # ===== 你的工作区：游戏业务代码都写在这里 =====
            #   common/（双端共享） server/（仅服务端） client/（仅客户端）
            #   每个端下有 api/（自动注册） const/ config.lua init.lua
            #   entrance/（入口） asset/（资源）
  bgd.json  # 项目配置（覆盖项 + 框架版本）
script/ ui/script/  # 构建产物（**禁止手改**，由工具生成）
src/main.lua ui/src/main.lua  # 引擎入口（标记之前是编辑器原文，之后是构建产物）
```

**铁律：你的所有业务代码都写在 `.bgd/src/` 下，绝不碰 `.bgd/libs/` 和构建产物目录。**

## 引擎与框架 API 速查（写代码前必看）

- `.bgd/libs/types/` 是引擎与框架 API 的 EmmyLua 声明文件（.d.lua），
  **不参与构建**，但包含全部可用 API 的类型签名与注释
- 写代码前先在 `libs/types/` 里搜索你要用的功能（`log`、`base`、`sce_*`、`class_*`），
  确认函数签名、参数、返回值，**不要臆造 API**
- 常用全局：`log.info/warn/error`、`require_folder`、引擎 `base.*`、`json.*`
- 框架命名空间：
  - `bgd_api.<端>.<模块>` —— 查 `libs/<端>/api/` 与 `src/<端>/api/` 已有模块
  - `bgd_const.<名称>` —— 查 `libs/<端>/const/`
  - `bgd_config.<端>.<名称>` —— 查 `libs/<端>/config.lua`

## 硬性规则

1. **require 写真实路径的静态形式**：`require('src.server.PlayerManager')`、`require('libs.common.api.json')`
   ——构建时自动改写为运行时根名。**禁止**字符串拼接构造 require 路径（EmmyLua 会失明）
2. **模块写法统一**：
   ```lua
   ---@class MyModule
   local M = {}
   function M.DoSomething() end
   return M
   ```
   消费方 `local MyModule = require('src.xxx.MyModule')`
3. **新增全局 API 模块**：丢进 `src/{common,server,client}/api/` 目录即自动注册为
   `bgd_api.<端>.<文件名>`（聚合 init.lua 由工具生成，**勿手改**）
4. **覆盖框架行为**：在 `src/<端>/api/` 放与框架同名模块（bgd_api 软覆盖）
5. **禁止手改**：`.bgd/libs/`、`script/`、`ui/script/`、`src/main.lua` 标记之后的内容、
   项目根 `.emmyrc.json` / `.gitignore`（要改就改 `.bgd/src/` 下的同名片段）

## 常用任务指引

| 任务 | 去哪里 |
| --- | --- |
| 加服务端业务逻辑 | `.bgd/src/server/`（入口在 `server/init.lua`） |
| 加客户端业务逻辑 | `.bgd/src/client/` |
| 加双端共享逻辑 | `.bgd/src/common/` |
| 加全局 API 模块 | `.bgd/src/<端>/api/<文件名>.lua` |
| 加常量 | `.bgd/src/<端>/const/`（文件末尾 `bgd_const.xxx = 表`） |
| 加配置 | `.bgd/src/<端>/config.lua`（`bgd_config.<端>.xxx = 表`） |
| 改启动入口 | `.bgd/src/entrance/{server,client}.lua` |

## 修改后如何生效（先判断监听状态）

用 CLI 判断监听状态（不要盲目手动构建）：

```bash
bgd_sce_tools check-watch --project <项目根路径>
```

- **输出"监听中"**：保存文件即自动增量构建，**无需任何手动构建**
- **输出"未监听"**：提醒开发者到工具的「构建」页执行「全量构建」；
  或你直接执行（并把日志落盘便于确认结果）：
  ```bash
  bgd_sce_tools build --project <项目根路径> --log .bgd/log/build.log
  ```
  然后读 `.bgd/log/build.log` 确认构建结果

> CLI 全路径（若未配 PATH）：
> `"%LOCALAPPDATA%\Programs\bgd_sce_tools\bgd_sce_tools.exe" <子命令>`

## 验证清单（改完代码后）

1. require 路径是否为静态真实路径（无拼接）
2. 新模块是否 `return M` + `---@class` 注解
3. 服务端/客户端代码是否放对了端（common 会双端各复制一份）
4. 构建后产物里对应文件已更新（开监听则保存即构建）
