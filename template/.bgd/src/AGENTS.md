# AGENTS.md — 游戏项目

> 本项目是星火编辑器（SCE）Lua 游戏项目，基于 BGD 框架 + bgd_sce_tools 构建工具。

## 给 AI 代理的指引

在开始任何代码工作前，请先阅读框架提供的完整开发指南：

- **`.bgd/libs/AGENTS.md`** —— 项目结构、硬性规则、API 速查、任务指引、构建验证方式（必读）
- **`.bgd/libs/types/`** —— 引擎与框架 API 的 EmmyLua 声明（写代码前在这里查 API 签名）
- **`.bgd/src/`** —— 你的工作区，所有游戏业务代码都写在这里
- **`.bgd/libs/`** —— 框架代码，**禁止修改**（由 bgd_sce_tools 管理和更新）

简要规则（详见 `.bgd/libs/AGENTS.md`）：

1. require 写真实路径的静态形式（`require('src.xxx')`），禁止字符串拼接
2. 新模块统一 `local M = {} ... return M` + `---@class` 注解
3. 全局 API 模块丢进 `.bgd/src/<端>/api/` 即自动注册为 `bgd_api.<端>.<文件名>`
4. 不碰 `.bgd/libs/`、构建产物（`script/`、`ui/script/`）、`src/main.lua` 标记之后的内容

## 构建与生效

- 开 bgd_sce_tools 的「监听」：保存即自动增量构建
- 判断监听状态 / 手动构建（CLI）：
  ```bash
  bgd_sce_tools check-watch --project .
  bgd_sce_tools build --project . --log .bgd/log/build.log
  ```
