import 'package:git_hooks/git_hooks.dart';
import 'dart:io';

void main(List arguments) {
  // ignore: omit_local_variable_types
  Map<Git, UserBackFun> params = {
    Git.commitMsg: commitMsg,
    // Git.preCommit: preCommit
  };
  GitHooks.call(arguments, params);
}

// 校验提交信息格式
Future<bool> commitMsg() async{
  // 获取提交信息文件路径（Git会将提交信息暂存到该文件）
  final msgFile = Platform.environment['HUSKY_GIT_PARAMS'] ?? '';
  if (msgFile.isEmpty) {
    print('❌ 未找到提交信息文件');
    return false;
  }

  // 读取提交信息
  final commitMessage = File(msgFile).readAsStringSync().trim();
  if (commitMessage.isEmpty) {
    print('❌ 提交信息不能为空');
    return false;
  }

  // 定义校验规则（Conventional Commits 简化版）
  // 格式：type(可选scope): 描述内容
  // type可选值：feat/fix/docs/style/refactor/test/chore
  final pattern = RegExp(
    r'^(feat|fix|docs|style|refactor|test|chore)(\([a-z0-9_-]+\))?: .{1,50}$',
    caseSensitive: false,
  );

  if (!pattern.hasMatch(commitMessage)) {
    print('❌ 提交信息格式不符合规范！');
    print('正确格式示例：');
    print('  feat: 新增用户登录功能');
    print('  fix(home): 修复首页加载崩溃问题');
    print('  docs: 更新API文档');
    print('类型说明：feat(新功能)、fix(修复)、docs(文档)、style(格式)、refactor(重构)、test(测试)、chore(构建)');
    return false; // 阻止提交
  }

  print('✅ 提交信息格式正确');
  return true; // 允许提交
}

Future<bool> preCommit() async {
  // try {
  //   ProcessResult result = await Process.run('dartanalyzer', ['bin']);
  //   print(result.stdout);
  //   if (result.exitCode != 0) return false;
  // } catch (e) {
  //   return false;
  // }
  return true;
}
