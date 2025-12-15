<!--
 * @Author: Z2-WIN\xmm wujixmm@gmail.com
 * @Date: 2025-12-06 16:21:07
 * @LastEditors: Z2-WIN\xmm wujixmm@gmail.com
 * @LastEditTime: 2025-12-15 17:00:13
 * @FilePath: \studioProjects\ex1\README.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
# ex1

框架改动计划：
- [x] 安全与配置：缺少多环境安全管理（Secrets、API Key 等），需要完善 .env 管理、CI/CD 变量注入、证书/签名配置。
- [x] 鉴权与状态：登录流程初步有 token 管理，但要补齐错误码处理、Token 续期失败的兜底、异常上报、未登录态的全局路由守卫。
- [x] 错误与稳定性：ErrorHandler 目前较简单，需接入崩溃/异常监控，统一的业务错误提示与重试策略。
- [x] 网络与模型：已加 DioResponseData 封装，但要确保所有接口模型都有 fromJson，统一处理空字段/类型错配，必要时增加强校验。
- [ ] UI/UX 完成度：页面多为示例/演示（Gallery、Form Demo 等），缺少实际业务流程、组件规范、无障碍/多语言/深色模式策略。
- [ ] 性能与体积：暂无启动优化、图片/缓存策略、懒加载、列表性能调优；发布前需开启混淆、瘦身与性能 Profiling。
- [ ] 测试与质量：测试覆盖度几乎为空（仅 widget_test 示例）；需要单元/组件/集成测试和基本的 CI 流程。
- [ ] 合规与发布：隐私协议、权限申请文案、崩溃/埋点合规等需补充；Android/iOS 发布配置（签名、Bundle ID、上架素材）待完善。