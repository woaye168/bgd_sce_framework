---@meta

-- ============================================================================
-- SCE UI 声音（ui_sound）类型声明
-- ----------------------------------------------------------------------------
-- 覆盖范围：客户端 UI 声音 API
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/客户端Lua API/音效/UI声音
-- ============================================================================

---播放UI声音。【客户端】
---@param sound_id string SoundData.ini 表中的声音名字，即写在中括号中的部分
---@param volume? number 音量，默认为1
function ui_sound.play_ui_sound(sound_id, volume) end

---播放UI声音（高级版接口）。【客户端】
---@param sound_path string 声音的路径，从 Res 开始算
---@param volume? number 音量，默认为1
---@param sound_type? string 默认为 'Effect'，另一个可能的值为 'BackgroundMusic'。
---同类型的声音同一时间只能播一个，同类型声音里后者打断前者
function ui_sound.play_ui_sound_ex(sound_path, volume, sound_type) end

---停止播放所有UI声音。【客户端】
function ui_sound.stop_all_sound() end
