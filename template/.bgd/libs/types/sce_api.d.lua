-- SCE 引擎全局声明补充
-- 引擎本体 API（base / log / json / ui / common 等）由 .emmyrc.json 的
-- library 路径（script/195）提供完整定义，本文件只声明其未覆盖的全局。

---按文件夹批量加载模块（引擎预加载环境提供）
---@param folder string 模块文件夹路径（点分隔，如 'src.server.const'）
require_folder = function(folder) end

---引擎主地图标识字符串
__MAIN_MAP__ = '__MAIN_MAP__'
