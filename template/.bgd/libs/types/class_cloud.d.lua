---@meta

-- ============================================================================
-- SCE 云变量（score / sce.s）类型声明
-- ----------------------------------------------------------------------------
-- 覆盖范围：服务端云变量 API（score 模块 + 提交对象）、客户端云变量 API（sce.s 命名空间）
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/云变量/API_new
--   https://doc.sce.xd.com/技术文档/客户端Lua API/云变量/API
--
-- 通用说明（服务端）：
--   - 通用存储、列表、货币、名字统称为云变量（老文档也称“积分”）。
--   - 所有云变量接口都运行在协程内，调用者必须确保自己处于协程中；
--     每个和远程服务(RPC)交互的操作调用后都会等待直到处理结果返回。
--   - 几乎所有接口的参数都有且只有一个 table（少数接口没有任何参数）。
--   - 返回结果通常有三个值：error_code, data, err_msg。
--     error_code 为 0 代表成功；data 仅在 error_code == 0 时是本次操作的结果；
--     err_msg 在 error_code == 0 时为 nil，否则为描述错误信息的字符串。
--   - 限制：每局现实时间每分钟最多 300 次读操作和 300 次写操作；
--     单次读写不得超过 32M，每分钟写入总大小不得超过 48M；
--     写操作次数 = commit 次数 + message_send 次数 + message_modify_read 次数 + message_delete 次数。
--
-- 通用说明（客户端）：
--   - 接口待重构（官方文档原注）。
--   - 调用远程服务有 3 种结果：成功、失败与超时。通过注册 ok / error / timeout 事件获取请求结果。
--   - 所有超时时间如无特殊说明均为 5 秒。
--   - 一秒内不允许超过 65536 个查询或 commit 操作，否则回调会错乱。
--   - 所有写操作的 target_map 强制指定为 sce.s.readwrite_map；只读操作允许读取
--     sce.s.readwrite_map 和 sce.s.readonly_map 两个地图的数据。
--   - 需要特别注意：客户端是 32bit 应用程序，文档内所有 integer 都是 32bit 的，与服务端不同！
--
-- 注意：服务端文档页尾部“世界积分”部分在抓取时被截断，世界积分相关 API 以文档示例中
--       出现过的为准（world_data_get / world_data_set / world_list_add），
--       该部分其余 API（如世界列表的查询/修改/删除）未能获取，未收录。
-- ============================================================================

-- ############################ 服务端：score 模块 ############################

---云变量提交对象。【服务端】
---除了统计，所有的修改操作都必须在提交对象上进行。
---可以把有关联的、必须同时成功的修改操作放在同一个提交对象里。
---@class CloudCommitter
local CloudCommitter = {}

---结束提交对象，真正提交所有修改。【服务端】
---在 commit 函数返回之前，所有相关修改未必真正写入了数据库。
---参数：无。
---@return integer error_code 错误码，为0时代表操作成功
---@return table data 空 table（失败时可能是服务器方面的错误原因）
---@return string|nil err_msg 错误信息，成功时为 nil
function CloudCommitter:commit() end

---设置云变量。【服务端】
---参数表字段：
---  user_id (number|string) 用户ID，字符串需可合法转为 number
---  key     (string) 二级分类
---  value?  (table)  应遵守云变量的值规则
---  i_value? (number) 会四舍五入成整数
---  s_value? (string)
---可以每次设置 value/i_value/s_value 中的一个或多个；设置多个值时，
---会按照 i_value、s_value、value 的顺序依次执行。
---注意：如果 i_value 不是数字，会直接报错 attempt to add a 'string' with a 'number'，整条提交全部回滚。
---@param args table 参数表
function CloudCommitter:set(args) end

---累加数字到 i_value。【服务端】
---如果该行不存在，则视同 set 操作。
---参数表字段：user_id, key, i_value (number) 累加值。
---注意：文档示例中也使用过 c.addi {user_id, key, value = n} 的形式，两者并列收录。
---@param args table 参数表
function CloudCommitter:add(args) end

---累加数字到 i_value（文档示例中的另一种写法）。【服务端】
---参数表字段：user_id, key, value (number) 累加值。
---@param args table 参数表
function CloudCommitter:addi(args) end

---累加金钱。【服务端】
---与 add 类似，但是 value 必须为整数，否则会报错，且整条提交全部回滚。
---也可以用 money_add 把值扣为负数，一般是误发了游戏资源后手动扣掉。
---出于安全考虑，不能直接用 API 设置金钱。
---参数表字段：user_id, key, value (integer) 累加值。
---@param args table 参数表
function CloudCommitter:money_add(args) end

---扣除金钱。【服务端】
---与 money_add 类似，但是 value 必须为正值，否则会报错。
---特别注意：如果扣除后结果为负数，则会返回失败（用于购买物品等场景），整条提交全部回滚。
---参数表字段：user_id, key, value (integer) 扣除值（正值）。
---@param args table 参数表
function CloudCommitter:money_cost(args) end

---列表新增项。【服务端】
---会立即返回一个 uuid，可以在还没有 commit 时就自由存储于其他地方
---（但如果后来 commit 失败，这些 uuid 也就失效了）。
---参数表字段：user_id, key, value (table)。
---@param args table 参数表
---@return integer uuid 列表项唯一标识（64bit 数字）
function CloudCommitter:list_add(args) end

---列表修改项。【服务端】
---参数表字段：uuid (integer, 64bit 数字), value (table)。
---@param args table 参数表
function CloudCommitter:list_modify(args) end

---列表删除项。【服务端】
---参数表字段：uuid (integer, 64bit 数字)。
---@param args table 参数表
function CloudCommitter:list_delete(args) end

---名字服务：新增唯一名字。【服务端】
---支持每 key 范围唯一起名：不存在才允许插入键值对，否则本次 commit 失败，所有操作失效。
---参数表字段：key (string) 分割类型, name (string) key下的唯一名, value (string) 随便存些数据。
---@param args table 参数表
function CloudCommitter:name_new(args) end

---设置世界数据。【服务端】
---参数表字段：user_id, key, value (table), world_id (integer)。
---@param args table 参数表
function CloudCommitter:world_data_set(args) end

---世界列表新增项。【服务端】
---参数表字段：user_id, key, value (table), world_id (integer)。
---@param args table 参数表
function CloudCommitter:world_list_add(args) end

---服务端云变量模块。【服务端】
---通用存储、列表、货币、名字统称为云变量。所有接口须在协程中调用。
---@class score
score = {}

---获得一个提交对象（非RPC）。【服务端】
---@return CloudCommitter committer 提交对象
function score.get_commit() end

---检测该值是否可以存进云变量，并返回序列化后的字节数。【服务端】
---如果待检测的值合法，则打印序列化后的长度；否则报错提示非法原因。
---参数表字段：value (any) 待检测的值。
---@param args table 参数表
---@return integer error_code 为0表示可以存储，其他值为不可存储
---@return integer length 云变量序列化后的长度
---@return string|nil err_msg 错误信息
function score.test_cloud_value(args) end

---通用存储：查询数据。【服务端】
---参数表字段：
---  user_id (number|string|number[]) 可传入数组做批量查询
---  key     (string|string[]) 可传入数组做批量查询
---user_id 和 key 可以同时都是数组，实现复合查询。
---成功时 data 为数组，每项含 i_value / key / user_id / value 字段。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 查询结果
---@return string|nil err_msg 错误信息
function score.get(args) end

---金钱存储：查询金钱。【服务端】
---金钱存储内只有数字字段，且消费时不能使存额降为负值（会使 commit 操作失败）。
---参数表字段：user_id, key（均可传入数组）。
---成功时 data 为数组，每项含 key / user_id / value 字段。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 查询结果
---@return string|nil err_msg 错误信息
function score.money_get(args) end

---列表查询，返回的数据按创建最后一次修改时间倒序排序。【服务端】
---参数表字段：
---  user_id  (必填)
---  key      (必填)
---  timetype? (string) 传 'stamp' 则返回的 updateAt 是以秒为单位的时间戳，否则默认是类似 2020-04-22 11:01:24 的时间
---  limit?   (number) 返回指定数量的数据，不填则返回所有数据（没有条数限制）
---成功时 data 为数组，每项含 uuid / value / key / updatedAt / user_id 字段
---（注意文档原注：updatedAt 字段实际是创建时间，非更新时间）。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 查询结果
---@return string|nil err_msg 错误信息
function score.list_query(args) end

---根据 uuid 进行列表查询。【服务端】
---参数表字段：uuid (integer, 必填) 一个64bit的数字，是列表型云变量上传或修改返回的 uuid。
---成功时 data 为数组，每项含 user_id / uuid / key / updatedAt / value 字段。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 查询结果
---@return string|nil err_msg 错误信息
function score.list_query_by_uuid(args) end

---发消息。【服务端】
---发送的消息除了可以用 message_query 查到，更常用的还是用 subscribe_channel 来订阅。
---消息离线也可以收到。
---参数表字段：
---  src_user_id    (number|string) 消息发出者
---  key            (string) 二级类别分割
---  target_user_id (number|string) 消息接收者
---  read?          (integer) 初始化是否已读，不填默认 0（未读）
---  deleted?       (integer) 初始化是否已删除，不填默认 0（未删除）
---  value          (table) 与 committer.set 里的 value 相仿
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 结果
---@return string|nil err_msg 错误信息
function score.message_send(args) end

---查询相应 key 的消息，只会返回未读消息。【服务端】
---（官方文档注明：以后会加查询已读、未读和已读的参数）
---参数表字段：src_user_id, key, target_user_id,
---  read? (integer) 1=已读，2=未读，不填(nil)=未读和已读都查
---成功时 data 为数组，每项含 deleted / key / objectId(64bit) / read /
---src_user_id / target_user_id / createAt / value 字段。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 查询结果
---@return string|nil err_msg 错误信息
function score.message_query(args) end

---设置消息是否已读。【服务端】
---参数表字段：objectId (integer) message_query 查出的 objectId 字段,
---  new_read_value (integer) 1 代表已读。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 结果
---@return string|nil err_msg 错误信息
function score.message_modify_read(args) end

---设置消息是否已删除。【服务端】
---参数表字段：objectId (integer) message_query 查出的 objectId 字段。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 结果
---@return string|nil err_msg 错误信息
function score.message_delete(args) end

---名字服务：搜索开头包含指定字符串的所有名字（前缀匹配）。【服务端】
---暂不支持拼音首字母的搜索。
---参数表字段：key (string), name_prefix (string)。
---成功时 data 为数组，每项含 key / name / value 字段。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 查询结果
---@return string|nil err_msg 错误信息
function score.name_search(args) end

---消息订阅：订阅发给 player 的 key 类型的消息。【服务端】
---由c++实现的api。player 可以是一个虚拟的用户（确定不会真实存在的 uid，比如 1 2 3）。
---即使消息是订阅前发的，也能收到。收到消息后通常需要把消息标记为已读，
---否则下次调用 subscribe_channel 或 message_query 时还会再次收到该消息。
---同一局内，重复订阅特定用户的同一个频道的话，第二次的订阅是无效的。
---回调 ok 的参数 result 字段：src_user_id (integer), target_user_id (integer),
---  key (string), read (boolean), value (string|integer|table|nil), message_id (integer)。
---@param player Player|integer|nil 玩家
---@param key string 消息的key
---@param events table 响应事件，如 { ok = function (result) ... end }
---@return boolean ret_value 是否成功订阅，目前失败只发生在重复的订阅
function score.subscribe_channel(player, key, events) end

---取消订阅。【服务端】
---由c++实现的api。通常不用被显式调用：用户下线时会自动取消该用户相关的消息订阅；
---当前游戏局结束时会自动取消所有本局产生的订阅（包括关于虚拟用户的订阅）。
---@param player Player|integer|nil 玩家
---@param key string 消息的key
function score.unsubscribe_channel(player, key) end

---更底层的消息订阅，只支持在线消息。【服务端】
---由c++实现的api。如果 A 先往 channel 发了个消息，B 才订阅，B 是收不到消息的。
---只能通过回调收到消息，没有单独的查询方法。和 publish_message 组合使用。
---同一局内，重复订阅同一个频道的话，第二次的订阅是无效的。
---注意：subscribe_channel 相当于会订阅 userid .. '_' .. key 的 channel（下划线连接），
---不要使用相同的字符串拼装方式，以免重复。
---目前 ac 层一些需要和外部接口交互的机制也用了 subscribe_message 和 publish_message，
---如支付和实名认证。
---回调 ok 的参数 result 是一个 table，里面只有一个字段 message (table)。
---@param channel_name string 订阅或者监听的消息的频道
---@param events table 响应事件，如 { ok = function (result) print(result.message) end }
---@return boolean ret_value 是否成功订阅，目前失败只发生在重复的订阅
function score.subscribe_message(channel_name, events) end

---发布消息，与 subscribe_message 组合使用。【服务端】
---由c++实现的api。不走离线消息只走在线消息。
---@param channel_name string 频道名，需要发送的目的地
---@param value table 消息体
function score.publish_message(channel_name, value) end

---查询世界数据。【服务端】
---参数表字段：user_id, key, world_id (integer)。
---成功时 data 为数组，每项含 key / user_id / value 字段。
---@param args table 参数表
---@return integer error_code 错误码
---@return table|nil data 查询结果
---@return string|nil err_msg 错误信息
function score.world_data_get(args) end

-- ############################ 客户端：sce.s 命名空间 ############################

---@class sce
sce = {}

---客户端云变量命名空间。【客户端】
---积分、存档、道具、列表、货币、名字这几套有统一的 commit；
---统计没有 commit，操作了立即生效。
---@class sce.s
---@field readwrite_map string 读写地图（所有写操作强制作用于该地图）
---@field readonly_map string 只读地图（只读操作允许读取）
sce.s = {}

---客户端云变量提交对象。【客户端】
---除了统计，所有的修改操作都必须在提交对象上进行。
---@class ClientCloudCommitter
local ClientCloudCommitter = {}

---结束提交对象，真正提交所有修改。【客户端】
---这是一个异步接口：调用 commit 之后立刻去获取积分，很可能取不到正确的值；
---commit 的回调最快也要等当前语境的 lua 代码全部执行完才会被调用。
---所有操作会强制作用于地图 sce.s.readwrite_map。
---事件：ok () 提交成功 / error (code, reason) 提交失败 / timeout () 提交超时。
---注意：只要游戏结束前调用 commit 就算有效，但游戏结束后 lua 收不到提交反馈。
---@param desc string 本次提交的描述，事后可通过后台查看某些积分字段的修改记录
---@param events? table 响应事件 { ok?, error?, timeout? }
function ClientCloudCommitter:commit(desc, events) end

---设置普通积分。【客户端】
---积分使用字符串作为索引(key)，索引最长180。普通积分可以是任意类型
---（字符串、数字、表都可以，但通常用表），均会在 c++ 底层序列化成二进制，长度不得超过 64K。
---将积分设置为 nil 可以删除该积分。
---注意：玩家离开游戏后依然可以设置他的积分，但最好不要这样做（新老游戏局同索引积分会冲突）。
---@param player Player|integer|nil 玩家。nil 表示客户端自己的 userid；integer 表示 userid
---（注意必须是大厅接口返回的 id；传 number 会被强转成 integer，强转失败当 0 用）
---@param key string 索引
---@param value string|integer|table|nil 积分的值
---@return boolean ok 是否成功，目前失败的唯一可能就是 table 序列化后超过 64K
function ClientCloudCommitter:score_set(player, key, value) end

---设置数字积分。【客户端】
---数字积分必须是整数（int64 范围）。
---@param player Player|integer|nil 玩家
---@param key string 索引
---@param value integer 积分的值
function ClientCloudCommitter:score_seti(player, key, value) end

---累加数字积分。【客户端】
---如果玩家的这项积分之前没有被设置过，那么假设之前是 0。
---@param player Player|integer|nil 玩家
---@param key string 索引
---@param value integer 累加的值
function ClientCloudCommitter:score_addi(player, key, value) end

---设置字符串积分。【客户端】
---@param player Player|integer|nil 玩家
---@param key string 索引
---@param value string 积分的值
function ClientCloudCommitter:score_sets(player, key, value) end

---加钱。【客户端】
---@param player Player|integer|nil 玩家
---@param money_name string 货币的名字
---@param value integer 加多少钱
function ClientCloudCommitter:money_add(player, money_name, value) end

---扣钱。【客户端】
---@param player Player|integer|nil 玩家
---@param money_name string 货币的名字
---@param value integer 扣多少钱
function ClientCloudCommitter:money_cost(player, money_name, value) end

---列表新增项。【客户端】
---@param player Player|integer|nil 玩家
---@param key string 列表的key
---@param value string|integer|table|nil 统计的值
function ClientCloudCommitter:list_add(player, key, value) end

---列表修改项。【客户端】
---@param player Player|integer|nil 玩家
---@param key string 列表的key
---@param list_id integer list项的唯一标识id
---@param value string|integer|table|nil 目标value
function ClientCloudCommitter:list_modify(player, key, list_id, value) end

---列表删除项。【客户端】
---@param player Player|integer|nil 玩家
---@param key string 列表的key
---@param list_id integer list项的唯一标识id。每一项的id独立互不干扰，删除某项不会影响别的项的id
function ClientCloudCommitter:list_delete(player, key, list_id) end

---添加物品。【客户端】
---user_id 和 item_id 相同，或者 user_id/key/expire_type/expire_time 相同都会被认为是同一物品。
---@param player Player|integer 玩家
---@param key string 标识某一类物品
---@param item_name string 物品名
---@param count integer 物品数量
---@param value table 物品额外信息
---@param expire_type integer 过期类型：0-永久，1-指定日期过期，2-指定时间过期
---@param expire_time? string|integer 过期时间。永久类型不需要填；指定时间入库时换算成指定日期；
---永久类型的过期时间一定为 9999-12-31 23:59:59
function ClientCloudCommitter:item_add(player, key, item_name, count, value, expire_type, expire_time) end

---使用物品。【客户端】
---@param player Player|integer 玩家
---@param item_id integer 物品id
---@param count integer 物品数量
function ClientCloudCommitter:item_use(player, item_id, count) end

---获得一个提交对象。【客户端】
---由c++实现的api。异步接口。
---@return ClientCloudCommitter committer 提交对象
function sce.s.get_commit() end

---初始化（读取）某玩家的积分。【客户端】
---由c++实现的api。异步接口，得收到回调后才能去访问积分的值。
---理论上可以不读取积分直接对积分进行写。
---ok 回调参数：score (普通积分表), iscore (数字积分表), sscore (字符串积分表)。
---并没有缓存，如无必要请避免反复调用。
---大厅服和匹配服的 Lua 脚本里可以获取到用户的部分积分，用于大厅和匹配的一些逻辑。
---@param score_name string|Player|integer|nil (可选)地图积分名（查其它地图的积分，得有权限）；
---如果第一个参数是字符串，则表示是地图积分名；否则为玩家
---@param player Player|integer|nil|table 玩家（传 nil 时服务端与客户端的处理方式不同）；或为响应事件表
---@param events table|... 响应事件 { ok?, error?, timeout? }
---@param ... string 任意个 key，要获取玩家的哪些 key；一个都不指定表示取该玩家的所有积分
function sce.s.score_init(score_name, player, events, ...) end

---初始化（读取）某玩家的所有货币的余额。【客户端】
---由c++实现的api。货币初始化需要一段时间，请不要立即使用它。
---理论上可以不读取货币余额，直接对该用户的货币进行增减。
---ok 回调参数：moneys (table)。没有缓存，如无必要请避免反复调用。
---@param player Player|integer|nil 玩家
---@param events table 响应事件 { ok?, error?, timeout? }
function sce.s.money_init(player, events) end

---名字服务：搜索包含指定字符串的所有名字。【客户端】
---由c++实现的api。支持每地图每大区范围唯一起名（没有大区概念前默认在1区）；
---不存在才允许插入键值对，否则失败。暂不支持拼音首字母的搜索。
---ok 回调参数：names (table) 数组，每项含 name (string) 和 value (string) 字段。
---names 表按 name 比 name_substr 多的字符个数排序，越接近越排前面；暂时写死只返回15个。
---每次调用都会去数据库搜索。
---@param key string 名字的索引
---@param name_substr string 名字的子串
---@param events table 响应事件 { ok?, error?, timeout? }
function sce.s.name_search(key, name_substr, events) end

---列表查询。【客户端】
---由c++实现的api。返回的数据按时间的逆序排序，即晚插入的排前面。
---ok 回调参数：result (table) 数组，每项含 user_id (integer), key (string),
---  value (string), list_id (integer), time (string) 字段。
---  注意 list_id 会是个比较大的数，不能通过加减来得到别的 id。
---@param map_name string|Player|integer|nil 要查询的地图名；或玩家
---@param player Player|integer|nil|string 玩家；或列表的key
---@param key string|table 列表的key；或回调
---@param limit integer|table|string (可选) 返回最多 limit 条记录，不填返回所有；或回调
---@param callback table|string 查询回调 { ok?, error?, timeout? }，写法与其他查询类 api 类似
---@param timetype? string (可选) 传 'stamp' 则返回的 time 是以秒为单位的时间戳，
---否则默认是类似 2020-04-22 11:01:24 的时间（不管是时间戳还是时间，都是字符串类型）
function sce.s.list_query(map_name, player, key, limit, callback, timetype) end

---查询用户所拥有的所有或者某一 key 类型的物品。【客户端】
---由c++实现的api。现阶段用来做玩家背包。
---ok 回调参数：result (table) 数组，每项含 user_id (integer), key (string),
---  item_name (string), expire_type (integer), expire_time (string),
---  count (integer), value (table), item_id (integer) 字段。
---@param player Player|integer 玩家
---@param callback table 查询回调 { ok?, error?, timeout? }
---@param key? string 可选参数，表示查询某一类物品
function sce.s.query_item(player, callback, key) end
