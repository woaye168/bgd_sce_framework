---复制文件
---@param srcFile string 源文件路径
---@param dstFile string 目标文件路径
---@return boolean 复制成功返回true，失败返回false
local function copy(srcFile, dstFile)
    local result = io.copy(srcFile, dstFile)
    if result == true then
        log.info('文件<' .. srcFile .. '>: 拷贝成功。副本文件：' .. dstFile)
        return true
    else
        log.error('文件<' .. srcFile .. '>: 拷贝失败。请检查 文件是否存在 或 路径是否正确')
        return false
    end
end

---创建目录
---@param dirPath string 目录路径
---@return boolean 创建成功返回true，失败返回false
local function create_dir(dirPath)
    local result = io.create_dir(dirPath)
    if result == true then
        log.info('目录<' .. dirPath .. '>: 创建成功。')
        return true
    else
        log.error('目录<' .. dirPath .. '>: 创建失败。')
        return false
    end
end

---检查目录是否存在
---@param dirPath string 目录路径
---@return boolean 目录存在返回true，不存在返回false
local function exist_dir(dirPath)
    local result = io.exist_dir(dirPath)
    if result == true then
        log.info('检查结果：目录<' .. dirPath .. '>存在。')
        return true
    else
        log.error('检查结果：目录<' .. dirPath .. '>不存在。')
        return false
    end
end

---检查文件是否存在
---@param FilePath string 文件路径
---@return boolean 文件存在返回true，不存在返回false
local function exist_file(FilePath)
    local result = io.exist_file(FilePath)
    if result == true then
        log.info('检查结果：文件<' .. FilePath .. '>存在。')
        return true
    else
        log.error('检查结果：文件<' .. FilePath .. '>不存在。')
        return false
    end
end

---读取文件内容
---@param path string 文件路径
---@return string|nil 文件内容，读取失败返回nil
local function read(path)
    local _, content = io.read(path)
    return content
end

---删除文件
---@param filePath string 文件路径
---@return boolean 删除成功返回true，失败返回false
local function remove(filePath)
    local result = io.remove(filePath)
    if result == 0 then
        log.info('文件<' .. filePath .. '>: 删除成功。')
        return true
    else
        log.error(nil, '文件<' .. filePath .. '>: 删除失败。请检查 文件是否存在 或 路径是否正确')
        return false
    end
end

---重命名文件
---@param oldFilePath string 原文件路径
---@param newFilePath string 新文件路径
---@return boolean 重命名成功返回true，失败返回false
local function rename(oldFilePath, newFilePath)
    local result = io.rename(oldFilePath, newFilePath)
    if result == true then
        log.info('文件<' .. oldFilePath .. '>: 重命名成功。新的文件：' .. newFilePath)
        return true
    else
        log.error('文件<' .. oldFilePath .. '>: 重命名失败。请检查 文件是否存在 或 路径是否正确')
        return false
    end
end

---写入文件内容
---@param name string 文件路径
---@param content string 要写入的内容
---@return boolean 写入成功返回true，失败返回false
local function write(name, content)
    local result = io.write(name, content)
    if result == 0 then
        log.info('文件<' .. name .. '>: 写入成功')
        return true
    else
        log.error('文件<' .. name .. '>: 写入失败')
        return false
    end
end

---IO模块
---@class ClientIo
local module = {
    copy = copy,
    create_dir = create_dir,
    exist_dir = exist_dir,
    exist_file = exist_file,
    read = read,
    remove = remove,
    rename = rename,
    write = write,
}

return module
