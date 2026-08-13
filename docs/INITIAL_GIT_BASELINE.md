# 首次 Git 基线说明

## 为什么首个 commit 已经是 dev.5.1

本项目最初只是验证 A3120 Magic Trackpad 在 Windows 11 下的 Precision Touchpad
能力，并未按正式软件项目立项。

随着以下能力逐步闭合：

- USB-C；
- Bluetooth；
- Haptic；
- 电量；
- C++ 状态探针；
- Driver Store 检测；
- 安全安装 gate；
- Inno Setup 安装器；

项目已经从实验变成可长期维护的软件，因此在
`v0.1.0-dev.5.1` 真机验收后正式执行：

```text
git init
git branch -M main
```

## 历史处理原则

不创建虚假的 dev.1 ～ dev.5 Git commit。

正式 Git 历史从当前稳定基线开始。

早期真实演进记录在：

```text
docs/DEVELOPMENT_HISTORY.md
```

## 不进入 Git 的内容

以下属于构建产物或本地二进制 staging：

```text
build/
out/
.vs/
third_party/MagicTrackpad2ForWindows-v2.0/
```

均必须保持 ignored。

上游二进制载荷由固定官方 ZIP + SHA256 重新生成。

## 旧 SHA256SUMS.txt

仓库根目录最初存在的 `SHA256SUMS.txt` 来自最早
`v0.1 status probe starter` 压缩包。

后续已经经历多个增量阶段，因此该清单不再代表当前源码。

首次正式 Git baseline 前应删除该旧文件。

以后只有在：

- 生成源码快照；
- 生成发布包；
- 生成交接包；

时动态创建与当次 artifact 对应的 SHA256 manifest。

Git 仓库本身不维护一个容易失效的根目录源码 SHA 清单。

## 建议首个提交

```text
feat: 建立妙控板 Windows 安装器首个稳定基线
```

建议正文明确说明：

- 当前基线 `v0.1.0-dev.5.1`；
- A3120 USB/Bluetooth 真机已验收；
- 安装器 current -> NO-OP 已验收；
- 干净 Windows 首次安装仍待 VM 验收。
