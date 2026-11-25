# Cursor Plugins

这个仓库是一个 Cursor 插件市场。在 Cursor 的 Customize 里用 **Add Marketplace → Import from GitHub** 贴上本仓库地址后，Cursor 会读取根目录的 `.cursor-plugin/marketplace.json`，并按其中的 `plugins` 列表安装插件。

当前有两个插件：`ponytail` 和 `superpowers`。

## 目录

```text
.cursor-plugin/marketplace.json          # 市场清单
plugins/ponytail/.cursor-plugin/plugin.json
plugins/ponytail/skills/                 # 上游原文
plugins/ponytail/hooks/                  # 上游原文
plugins/ponytail/.cursor/rules/          # 上游原文，不作为插件规则加载
plugins/ponytail/LICENSE                 # 上游 MIT
plugins/superpowers/.cursor-plugin/      # 上游 Cursor 清单
plugins/superpowers/skills/              # 上游原文
plugins/superpowers/hooks/               # 上游原文
plugins/superpowers/LICENSE              # 上游 MIT
.github/workflows/sync-ponytail.yml
.github/workflows/sync-superpowers.yml
```

每个插件放在 `plugins/<name>/`，并且自己有一份 `.cursor-plugin/plugin.json`。`metadata.pluginRoot` 是 `plugins`，所以清单里的 `source` 只写目录名。

## ponytail

技能、钩子脚本、Cursor 规则文件和 `LICENSE` 从 [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) 原样复制。版权是 DietrichGebert，协议是 MIT，原文在 `plugins/ponytail/LICENSE`。这些文件不要在本仓库里改。对应的上游提交记在 `plugins/ponytail/UPSTREAM.json`。

本仓库自己写的只有市场清单、插件清单，以及 `.cursor-plugin/hooks.json`。上游的 `hooks/cursor-hooks.json` 里命令还是安装器才会替换的 `PONYTAIL_DIR` 占位符，插件运行时改成相对路径调用同一批上游脚本：

- `node ./hooks/ponytail-activate.js`
- `node ./hooks/ponytail-mode-tracker.js`

上游把「项目里的 always-on 规则」和「会话钩子」分成两种 Cursor 装法。规则一旦生效就不能按 lite / full / ultra / off 切换。这个插件走钩子，所以 `.cursor/rules/ponytail.mdc` 只随上游保存，不放进插件的 `rules/`，清单里也不声明 `rules`。

上游仓库根目录的 `plugin.json` 只有 `{"name":"ponytail"}`，没有 Agent Plugins 要求的 `$schema`。带上它会让符合该规范的客户端拒绝整个插件，所以不同步这个文件。Cursor 的 Import from GitHub 使用的是 `.cursor-plugin/plugin.json`。

## superpowers

Cursor 插件清单、技能、钩子和 `LICENSE` 从 [obra/superpowers](https://github.com/obra/superpowers) 原样复制。版权是 Jesse Vincent，协议是 MIT，原文在 `plugins/superpowers/LICENSE`。对应的上游提交记在 `plugins/superpowers/UPSTREAM.json`。当前同步的是 7.0.2，提交 `22f0b463e7a5e579904dd6211a520321035526f7`。

只带 Cursor 插件用到的 `.cursor-plugin/`、`skills/`、`hooks/` 和 `LICENSE`。上游仓库里的测试、文档和其他客户端目录不在这个插件里。会话钩子仍然调用上游的 `./hooks/run-hook.cmd session-start`。

如果官方市场里的 Superpowers 也装着，Cursor 会两份一起加载。留一份即可。

## 同步上游

Cursor 导入市场时只读取这一个仓库里的文件。`marketplace.json` 的 `source` 是目录路径，不能写成 `DietrichGebert/ponytail`。因此上游内容必须进本仓库，不能靠 submodule：导入方不会递归检出 submodule，插件目录会是空的。

也不把本仓库做成上游的 fork。Fork 的 “Sync fork” 同步的是整个 ponytail 项目，而这个仓库的根是多插件市场，后面还会放别的插件。

跟踪上游的方式是两个 GitHub Action。每周一，或在 Actions 里手动运行 **Sync ponytail** 和 **Sync superpowers**。有差异时各自开一个拉取请求，合并后 Cursor 的自动刷新才会拿到新文件。上游文件按原字节复制，只更新对应的 `UPSTREAM.json`。ponytail 还会把插件清单里的版本号改成上游 `package.json` 的版本。

## 在 Cursor 里添加

1. 打开 Customize。
2. 点 **Add Marketplace**，选 **Import from GitHub**。
3. 填入本仓库的 GitHub 地址。
4. 在列表里安装 **Ponytail** 和 **Superpowers**。
5. 执行 **Developer: Reload Window**。

私有仓库需要在导入时授权 Cursor GitHub App 读取该仓库。这个仓库默认公开，因为 ponytail 本身已是公开的 MIT 项目。
