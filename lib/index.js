/**
 * Sidor_Character — Host 半（静态 Cordis 插件空壳）
 *
 * 人设卡独立附属插件的宿主侧服务面。当前占位阶段无 host RPC：
 * 后续依赖宿主的能力（读取会话人设、读写工作区配置文件等）若无法在
 * 客户端完成，将按 Sidor 系列的静态降级约定由客户端走「agent 代执行」
 * 路径完成（见 docs/DEVELOPER_PROMPT.md）。
 */
export function apply() {
  // 预留：静态 host 服务面。
}
