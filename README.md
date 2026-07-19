# bgd_sce_framework

BGD 工作室 · 星火编辑器（SCE）Lua 开发框架模板仓库。

本仓库是 **框架代码模板**，配合构建工具仓库 **[bgd_sce_tools](https://github.com/woaye168/bgd_sce_tools)** 一起使用：

| 仓库 | 作用 |
| --- | --- |
| **bgd_sce_framework**（本仓库） | 框架代码模板（`.bgd` 目录内容），游戏项目从这里下载/更新框架 |
| [bgd_sce_tools](https://github.com/woaye168/bgd_sce_tools) | Tauri 桌面构建工具：初始化项目、全量构建、监听更新、框架更新 |

> 两个仓库需要一起看：框架定义"代码怎么写"，工具负责"代码怎么构建"。

---

## 框架解决了什么问题

在星火编辑器里写 Lua，原生体验有几个痛点：

1. **模块路径与运行时路径不一致**：引擎加载的模块名是 `bgd_game_server.xxx`，而源码目录叫 `src`，直接写 require 会导致编辑器（EmmyLua）无法解析。
2. **没有类型提示**：动态拼接的 require（如 `require(root .. '.server.xxx')`）让语言服务器完全失明。
3. **服务端/客户端/公共代码需要拆分部署**：同一份源码要分别输出到 `script/`（服务端）和 `ui/script/`（客户端）。

本框架的约定：

- 源码中**直接写真实路径的静态 require**：`require('src.server.PlayerManager')`、`require('libs.common.api.json')`——EmmyLua 原生可解析，有跳转、补全、跨文件错误检查。
- 构建时由 bgd_sce_tools 把引号内的前缀改写为运行时根名（`src.` → `bgd_game_server.`，`libs.` → `bgd_libs_server.`），**引擎运行时零感知**。
- 在 `api/` 目录丢一个模块文件，**自动注册到 `bgd_api` 并自动获得 EmmyLua 类型提示**，无需手改任何注册代码。

## 全局命名空间约定

框架初始化时（`templates/init_tp_libs.lua`）注入三个全局命名空间：

| 命名空间 | 用途 | 例子 |
| --- | --- | --- |
| `bgd_api` | 全局 API 模块（任何项目可复用的独立功能模块） | `bgd_api.common.json.encode_x(data)` |
| `bgd_const` | 全局常量 | `bgd_const.keyboard.y` |
| `bgd_config` | 全局配置 | `bgd_config.server.game_info.version` |

## 目录结构（template/.bgd）

```
template/
  .emmyrc.json          # EmmyLua 语言服务器配置（初始化时覆盖到项目根）
  .gitignore            # 游戏项目默认 gitignore（初始化时写入项目根）
  .bgd/
    bgd.json            # 项目构建配置（工具读写）
    templates/          # init 模板（构建时渲染到产物根目录）
      init_tp_libs.lua
      init_tp_game.lua
    libs/               # 框架代码（由工具管理和更新，游戏作者原则上不直接改）
      common/
        api/            # 全局 API 模块：每个文件自动注册为 bgd_api.common.<文件名>
        const/          # 全局常量：文件内自注册 bgd_const.<名称>
        config.lua      # bgd_config.common.libs_info
        init.lua
      server/{api/, const/, config.lua, init.lua}
      client/{api/, const/, config.lua, init.lua}
      entrance/         # 框架入口（与游戏入口合并后输出到引擎入口文件）
      types/            # 引擎 API 的 EmmyLua 类型声明（不参与构建）
    src/                # 游戏代码骨架（游戏作者在这里写业务）
      common/{api/, base/, const/, config.lua, init.lua}
      server/{api/, const/, config.lua, init.lua, GameServer.lua, PlayerManager.lua}
      client/{api/, const/, config.lua, init.lua}
      entrance/         # 游戏入口
    doc/api/            # 框架模块文档
```

### 构建产物布局（构建后自动生成）

| 源码 | 服务端产物 | 客户端产物 |
| --- | --- | --- |
| `libs/` | `script/bgd_libs_server/` | `ui/script/bgd_libs_client/` |
| `src/` | `script/bgd_game_server/` | `ui/script/bgd_game_client/` |
| `*/asset/` | `res/`（二进制原样复制） | 同左 |
| `*/entrance/` | 合并输出到 `src/main.lua`、`ui/src/main.lua`（框架在前、游戏在后） | 同左 |

拆分规则：`server/` 只进服务端产物，`client/` 只进客户端产物，`common/` **双端各复制一份**。

## 核心开发约定

### 1. 模块写法（统一 return M + EmmyLua 注解）

```lua
-- src/server/PlayerManager.lua

---@class PlayerData
---@field uid number
---@field name string

---@class PlayerManager
local M = {}

---@param userId number
---@return PlayerData
function M.CreatePlayerData(userId)
    return { uid = userId, name = "新手玩家" }
end

return M
```

消费方：

```lua
local PlayerManager = require('src.server.PlayerManager')
local data = PlayerManager.CreatePlayerData(uid)  -- data. 有字段补全
```

### 2. 全局 API 模块（丢文件即注册）

把模块文件放进 `api/` 目录即可，**不需要改任何注册代码**：

```
libs/common/api/json.lua   -> bgd_api.common.json
src/server/api/Mail.lua    -> bgd_api.server.Mail
```

构建/监听时工具会自动重新生成聚合文件 `api/init.lua`（标记 `AUTO-GENERATED`，请勿手改）。因为聚合文件生成在源码树内，EmmyLua 立即索引——**新模块放进去，`bgd_api.xxx.` 的补全马上就有**。

模块要求：`return` 一个表，并用 `---@class` 注解，即可获得完整类型提示。

### 3. 常量与配置

- 常量：`const/` 目录下的文件**自注册**——文件末尾写 `bgd_const.my_const = 常量表`，由 `require_folder('xxx.const')` 批量加载。
- 配置：`config.lua` 挂载到 `bgd_config.<端>.<名称>`。

### 4. require 路径规则（重要）

| 源码写法 | 服务端构建后 | 客户端构建后 |
| --- | --- | --- |
| `require('src.xxx')` | `require('bgd_game_server.xxx')` | `require('bgd_game_client.xxx')` |
| `require('libs.xxx')` | `require('bgd_libs_server.xxx')` | `require('bgd_libs_client.xxx')` |
| `require_folder('src.server.const')` | 同样被改写 | 同样被改写 |

只改写**引号内**的模块名字符串，不影响其他代码。**禁止**再用字符串拼接构造 require 路径（否则 EmmyLua 无法分析）。

### 5. 其他构建行为

- `.html/.css/.js` 文件会被包装为 `return [===[...]===]` 的 Lua 模块（扩展名改为 `.lua`）。
- `bgd.json` 中 `libs_excludes` / `game_excludes` 配置排除目录（如 `types` 目录不参与构建，仅供 EmmyLua 索引）。
- `entrance/` 文件不进入产物目录，由入口合并流程输出到引擎入口文件。

## bgd.json 配置项

| 字段 | 说明 |
| --- | --- |
| `libs_dir` / `game_dir` | 框架/游戏源码目录（相对 `.bgd`） |
| `libs_server_target` 等四个 target | 四类构建产物输出目录 |
| `libs_excludes` / `game_excludes` | 排除目录（目录边界匹配） |
| `asset_target` + `*_asset_output_name` | 资源输出位置与子目录名 |
| `server_entrance` / `client_entrance` | 引擎入口文件位置 |
| `templates_dir` | init 模板目录 |
| `framework_version` | 当前框架版本（工具写入，用于更新检查） |
| `framework_repo` | 框架来源仓库（如 `woaye168/bgd_sce_framework`） |

## EmmyLua 支持

`template/.emmyrc.json` 在项目初始化时覆盖到项目根：

- `workspaceRoots: ["./.bgd"]` —— 只索引源码，产物目录（`script`、`src`、`ui`）全部排除，不会重复索引
- `requirePattern: ["?.lua", "?/init.lua"]` —— 支持 `api/init.lua` 形式的目录模块
- `library` —— 引擎 API 库路径（星火编辑器的 script/195、gameui），`base`、`log`、`json` 等引擎全局的提示来自这里
- `libs/types/` 补充声明引擎预加载全局（`require_folder` 等）和框架命名空间（`bgd_api`/`bgd_config`/`bgd_const`）

推荐使用 [EmmyLua](https://github.com/EmmyLuaLs/emmylua-analyzer-rust) 插件（VS Code / Trae）。

## 如何更新框架到游戏项目

bgd_sce_tools 的【设置】页提供"检查框架更新"：对比项目 `bgd.json` 的 `framework_version` 与本仓库**最新 Release 的 tag**，可一键更新。

更新只覆盖 `.bgd/libs`、`.bgd/templates` 和 `.emmyrc.json`，**不会动你的游戏代码 `.bgd/src`**。

## Fork 后二次开发

### 修改框架代码

1. Fork 本仓库后 clone 到本地。
2. 直接在 `template/.bgd/libs/` 下修改/新增模块（遵守上面的模块约定）。
3. 提交推送后，**打一个 Release tag**（如 `v0.1.1`）：

```bash
git tag -a v0.1.1 -m "新增 xxx 模块"
git push origin v0.1.1
```

4. 游戏项目里用 bgd_sce_tools 的"检查框架更新"即可拉取（注意：工具的 `framework_repo` 要指向你的 fork，见下）。

### 与 fork 的工具仓库联动

如果你同时 fork 了 [bgd_sce_tools](https://github.com/woaye168/bgd_sce_tools)，需要把工具里的框架地址改成你的 fork：

1. 修改工具仓库 `src-tauri/src/project.rs` 中的 `DEFAULT_FRAMEWORK_REPO`，改为 `你的用户名/bgd_sce_framework`。
2. 游戏项目 `.bgd/bgd.json` 的 `framework_repo` 字段同样改为你的 fork（已初始化的旧项目需要手动改一次）。

### 版本号机制说明

- 工具通过 GitHub API `repos/<repo>/releases/latest` 读取最新 Release 的 `tag_name` 作为框架最新版本。
- 框架 zip 包通过 codeload 下载 **main 分支**快照，因此日常改动推到 main 即可被新项目初始化拉取；**Release tag 只用于版本号对比**，发框架更新时记得打 Release。
- 建议 tag 语义化：`v主.次.修`（如 `v0.1.1`）。

## 运行环境

- 目标引擎：星火编辑器（SCE），Lua 5.4
- 构建工具：见 [bgd_sce_tools](https://github.com/woaye168/bgd_sce_tools)
- 最终游戏项目无需任何额外依赖（构建产物是纯 Lua）

## 许可证

尚未指定，后续补充。二次开发前请先与作者确认。
