# 注意：本目录由 bgd_sce_tools 管理

**请勿修改本目录（libs）内的任何文件，也不要在此新增文件。**

本目录是 BGD 框架代码，通过 bgd_sce_tools 的「框架更新」从
[bgd_sce_framework](https://github.com/woaye168/bgd_sce_framework) 下发更新。
你在这里的修改不会丢失（增量更新会保留并提示冲突），但框架升级后维护成本很高。

---

## 三大全局命名空间

框架初始化时（产物根 init.lua）注入三个全局命名空间，游戏代码直接使用：

| 命名空间 | 用途 | 示例 |
| --- | --- | --- |
| `bgd_api` | 全局 API 模块（独立可复用功能） | `bgd_api.common.json.encode_x(data)` |
| `bgd_const` | 全局常量 | `bgd_const.keyboard.y` |
| `bgd_config` | 全局配置 | `bgd_config.server.game_info.version` |

## 正确的扩展方式

- **游戏业务代码**：写到 `../src/` 目录
- **新增全局 API 模块**：放到 `../src/{common,server,client}/api/` 目录，
  自动注册为 `bgd_api.<端>.<文件名>`，与框架模块同级可用
- **覆盖框架 API 行为**：在 `../src/<端>/api/` 放一个**同名**模块，
  游戏侧后加载，会覆盖框架侧的同名注册（bgd_api 软覆盖）——这是扩展框架的推荐方式
- **自定义配置/常量**：放到 `../src/<端>/config.lua` / `../src/<端>/const/`

## require 路径规则

源码写**真实路径的静态 require**，构建时自动改写为运行时根名：

| 源码写法 | 服务端构建后 | 客户端构建后 |
| --- | --- | --- |
| `require('src.xxx')` | `require('bgd_game_server.xxx')` | `require('bgd_game_client.xxx')` |
| `require('libs.xxx')` | `require('bgd_libs_server.xxx')` | `require('bgd_libs_client.xxx')` |

**禁止**用字符串拼接构造 require 路径（EmmyLua 无法分析，会失去跳转/补全）。

## 构建产物布局

| 源码 | 服务端产物 | 客户端产物 |
| --- | --- | --- |
| `libs/` | `script/bgd_libs_server/` | `ui/script/bgd_libs_client/` |
| `src/` | `script/bgd_game_server/` | `ui/script/bgd_game_client/` |
| `*/asset/` | `res/`（二进制原样复制） | 同左 |

拆分规则：`server/` 只进服务端产物，`client/` 只进客户端产物，`common/` 双端各一份。

## 引擎与框架 API 速查

- `types/` 目录是引擎与框架 API 的 EmmyLua 声明文件（.d.lua），不参与构建，
  包含全部可用 API 的类型签名与注释（`log`、`base`、`sce_*` 等）
- 写代码前在 `types/` 里搜索要用的功能，确认函数签名再调用

## 常用操作（bgd_sce_tools）

| 需求 | 操作 |
| --- | --- |
| 改了代码要生效 | 开「监听」自动增量构建；或「构建」页全量构建 |
| 清理产物 | 「构建」页「清除构建」（入口 main.lua 还原为编辑器原文） |
| 更新框架 | 「设置」页「检查框架更新」→「更新框架」（只碰 libs，冲突保留本地） |
| 命令行操作 | `bgd_sce_tools build/check-watch/update-framework --project <路径>` |

## 冲突处理

框架更新时若你改过某文件且上游也改了（冲突）：本地文件保留，
上游新版另存为 `xxx.framework-new`，工具报告里会列出清单。
对比合并后删除 `.framework-new` 即可。

详见框架仓库 README。
