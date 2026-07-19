# 注意：本目录由 bgd_sce_tools 管理

**请勿修改本目录（libs）内的任何文件，也不要在此新增文件。**

本目录是 BGD 框架代码，通过 bgd_sce_tools 的「框架更新」从
[bgd_sce_framework](https://github.com/woaye168/bgd_sce_framework) 下发更新。
你在这里的修改不会丢失（增量更新会保留并提示冲突），但框架升级后维护成本很高。

## 正确的扩展方式

- **游戏业务代码**：写到 `../src/` 目录
- **新增全局 API 模块**：放到 `../src/{common,server,client}/api/` 目录，
  自动注册为 `bgd_api.<端>.<文件名>`，与框架模块同级可用
- **覆盖框架 API 行为**：在 `../src/<端>/api/` 放一个**同名**模块，
  游戏侧后加载，会覆盖框架侧的同名注册（bgd_api 软覆盖）
- **自定义配置/常量**：放到 `../src/<端>/config.lua` / `../src/<端>/const/`

详见框架仓库 README。
