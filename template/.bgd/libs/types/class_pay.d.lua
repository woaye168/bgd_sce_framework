---@meta

-- ============================================================================
-- SCE 官方文档：服务端 Lua API —— 其它 / 支付（Pay）
-- ----------------------------------------------------------------------------
-- 来源文档：
--   https://doc.sce.xd.com/技术文档/服务端Lua API/其它/支付
--
-- 除 iOS 外，其他平台支付相关逻辑都在服务端执行，客户端不需要写支付相关的
-- lua 代码。iOS 支付需要先和 AppStore 交互，客户端需唤起 AppStore 支付界面，
-- 拿到收据后发给服务器验证。
--
-- 用法（服务端）：
---```lua
---local pay = include 'base.pay'
---local co = include 'base.co'
---co.async(function()
---    local my_pay = pay.new { player = player, amount = amount, ... }
---    if my_pay:start() then
---        -- 充值成功
---    else
---        -- 充值失败
---    end
---end)
---```
-- 注意：充值相关操作必须在协程中运行（用 co.async 包裹）。充值成功之后，会
-- 自动帮指定的玩家添加积分，脚本不需要额外执行添加积分的代码，否则会导致
-- 重复加积分；脚本只需要重新查询积分，然后刷新界面即可。
-- ============================================================================

---支付库（通过 `local pay = include 'base.pay'` 获得）。【服务端】
---@class PayLib
local pay = {}

---创建一个充值对象，可以指定一些充值参数。【服务端】
---@param conf PayConf 充值参数
---@return Pay pay 充值对象
function pay.new(conf) end

---充值参数。【服务端】
---@class PayConf
---@field sandbox? boolean 可选，是否为沙盒环境，默认为 false，代表是正式环境
---@field map string 地图名
---@field player Player 玩家对象
---@field amount number 充值金额，单位人民币元，只能精确到小数点后两位
---@field client string 充值玩家的客户端类型，可以用 platform.get(player) 来获取
---@field type? string 积分类型，默认为 `钻石`
---@field rate? number 人民币和积分的兑换比例，默认 1人民币=100钻石，rate 为 100
---@field service? string 充值服务类型，可选：`AliPay`（支付宝）、`ApplePay`（iOS支付）
---@field receipt? string 收据，客户端发过来的，只有 iOS 客户端需要传这个，其他客户端不用管
---@field user_id number 玩家 user_id

---充值对象。【服务端】
---@class Pay
local Pay = {}

---请求充值。必须在协程中调用（用 co.async 包裹）。
---iOS 平台需在创建支付对象时把 receipt 字段填为客户端发送过来的收据，
---调用本方法进行验证，和其他平台的支付逻辑相同。【服务端】
---@return boolean ok 是否充值成功
function Pay:start() end

-- ============================================================================
-- iOS 客户端支付相关（仅 iOS 平台的客户端 lua 需要）
-- ============================================================================

---唤起 AppStore 支付界面。AppStoreProductId 从表里读出来（如
---`com.base.createeasy.ceentry.diamond600`），一个充值金额对应一个
---AppStoreProductId。【客户端，仅iOS】
---@param product_id string AppStore 商品 id
function common.appstore_buy_diamond(product_id) end

---AppStore 返回支付结果（iOS 客户端实现此回调）。
---支付流程：用户请求支付 -> 唤起 AppStore 支付界面 -> 支付成功，从 AppStore
---拿到支付收据 -> 把收据发给服务器验证。【客户端，仅iOS】
---@param result any 支付结果
---@param error_code integer 错误码
---@param error_desc string 错误描述
---@param receipt_base64 string AppStore 返回的收据，需要发给服务器做验证
---@param product_id string 商品 id
---@param transaction_id string 交易 id
---@param foreground boolean 是否在前台
function base.event.on_appstore_iap_purchase_response(result, error_code, error_desc, receipt_base64, product_id, transaction_id, foreground) end
