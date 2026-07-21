# AGENTS.md — bgd_sce_framework

> 本文件面向在本仓库工作的 AI 编程代理。遵循 [agents.md](https://agents.md/) 规范。

## 项目简介

星火编辑器（SCE）Lua 开发框架模板仓库。本仓库**只包含模板代码**（`template/`），通过构建工具 [bgd_sce_tools](https://github.com/woaye168/bgd_sce_tools) 下发到游戏项目并完成构建。

两个仓库需要一起看：本仓库定义"代码怎么写"，工具仓库负责"代码怎么构建"。

## 仓库结构

```
template/
  .bgd/
    bgd.json              # 项目覆盖配置骨架 + 项目状态（framework_version/framework_repo）
    libs/                 # ===== 框架所有（工具的框架更新只碰这里）=====
      README.md           # 「本目录由工具管理，请勿修改/新增」
      bgd_default.json    # 框架默认配置（下发通道）
      doc/                # 框架文档
      .emmyrc.json        # 框架侧 EmmyLua 配置片段
      .gitignore          # 框架侧忽略规则
      init.lua            # 框架 init 模板（构建渲染 {{target}}/{{module}}）
      common/ server/ client/ entrance/ types/
    src/                  # ===== 游戏代码骨架（游戏作者写业务，永不被框架更新触碰）=====
      doc/  .emmyrc.json  .gitignore  init.lua
      common/ server/ client/ entrance/
README.md
LICENSE                 # GPLv3
.github/workflows/release.yml   # 推 v* tag 自动创建 Release
.github/release.yml             # Release notes 分组规则
```

## 核心约定（改代码前必读）

- **静态 require**：源码写真实路径（`require('src.xxx')` / `require('libs.xxx')`），构建时引号内前缀被工具改写为运行时根名。**禁止**用字符串拼接构造 require 路径（会让 EmmyLua 失明）。
- **模块写法**：统一 `local M = {} ... return M` + `---@class` 注解，消费方 `local Xxx = require('...')`。
- **全局 API 自动注册**：把模块丢进 `{libs,src}/{common,server,client}/api/` 即自动注册为 `bgd_api.<端>.<文件名>`，聚合 `init.lua` 由工具生成（标记 AUTO-GENERATED，勿手改）。
- **bgd_api 软覆盖**：游戏侧 `src/<端>/api/` 放与框架同名模块即可覆盖框架行为（游戏侧后加载），这是扩展框架的推荐方式，优于直接改 libs。
- **白名单构建**：code set 根下仅 `server/client/common/asset/entrance` 进产物；根级文件各有专门流程。
- **配置 overlay**：`libs/bgd_default.json` 是默认值下发通道，游戏项目 `.bgd/bgd.json` 只存覆盖项与项目状态。
- **types/ 目录**：仅供 EmmyLua 索引，不参与构建（在 `libs_excludes` 中）。

## 修改框架代码

1. 直接在 `template/.bgd/libs/` 下修改/新增模块（遵守上述约定）
2. 提交推送 main
3. 打 Release tag（**无需写注解**，Release notes 按 `.github/release.yml` 自动归纳）：

```bash
git tag -a vX.Y.Z
git push origin vX.Y.Z   # release.yml 自动创建 Release
```

游戏项目用 bgd_sce_tools 的「检查框架更新」即可三路哈希增量更新（只碰 libs，冲突保留本地）。

## 版本号机制

- 工具通过 `repos/<repo>/releases/latest` 读最新 Release 的 `tag_name` 作为框架最新版本
- 框架 zip 通过 codeload 下载 **main 分支**快照——日常改动推 main 即可被新项目初始化拉取；**Release tag 只用于版本号对比**，发框架更新时必须打 Release（推 tag 即自动创建）

## 验证方式

本仓库无独立构建/测试命令。验证方式为：在真实游戏项目（如 `D:\sce_online\Res\maps\bgd_glzy`）上用 bgd_sce_tools CLI 执行：

```bash
bgd_sce_tools update-framework --project <项目路径> --proxy http://127.0.0.1:7897
bgd_sce_tools build --project <项目路径>
```

确认增量更新结果正确（更新/新增/删除/保留/冲突符合预期）、构建产物正确后，才允许提交。

## 注意事项

- 框架更新冲突时：本地文件保留，上游新版另存 `xxx.framework-new`，需人工合并后删除 `.framework-new`
- 提交信息遵循 `feat: / fix: / ci: / docs:` 前缀（Release notes 分组依赖）
- 网络：拉依赖/推 GitHub 需代理，本机 `http://127.0.0.1:7897`
- 许可证：GPLv3（见 LICENSE）
