{
  # AI 代码补全（Copilot 式 ghost text）。后端 OpenCode Go 订阅：
  # 端点 https://opencode.ai/zen/go/v1/chat/completions，key 由 sops 导出为
  # OPENCODE_GO_API_KEY（见 sops.nix）。密钥修改/模型切换见 README 的 Minuet 小节。
  plugins.minuet = {
    enable = true;
    settings = {
      provider = "openai_compatible";
      # OpenCode Go 官方示例值：降低请求频率，避免限额与首 token 延迟叠加
      throttle = 1500;
      debounce = 600;
      # space-bunny 经网关思考后 content 在 2.4-5.6s 到达;README 说明
      # 流式下超时提前会直接拿不到建议,给足余量
      request_timeout = 8;
      # ghost text 一条建议即可;减少模型输出候选的数量也压缩思考长度
      n_completions = 1;
      notify = "warn";

      provider_options.openai_compatible = {
        # minuet 读环境变量名，值由 sops 导出
        api_key = "OPENCODE_GO_API_KEY";
        end_point = "https://opencode.ai/zen/go/v1/chat/completions";
        # 实测选型:Go 网关把主力聊天模型(GLM/DeepSeek/Qwen 系)全部路由到
        # 强制思考(reasoning_content 吃满 token 且禁思考参数被网关拒收),
        # 唯 space-bunny 增量补全形态正确(~3s、stop、content 可用)。
        model = "space-bunny";
        name = "OpenCode Go";
        stream = true;
        # OpenCode Go 要求 client 自带 user-agent + 稳定会话头。
        # v0.9.0 的 curl_extra_args 不支持函数(README 超前于实现，直接 ipairs
        # 崩溃)，因此用 transform 注入；每 nvim 实例 session id 见下方。
        transform.__raw = ''
          {
            function(t)
              t.headers['User-Agent'] = 'minuet-nixvim/1.0'
              t.headers['x-opencode-session'] = vim.g.minuet_session_id or 'nixvim'
              return t
            end,
          }
        '';
        optional = {
          # 网关模型带隐性思考,留足空间避免思考溢出吃掉补全
          max_tokens = 512;
          top_p = 0.9;
        };
      };

      virtualtext = {
        # 与 lsp.nix / metals.nix 的语言集一致：自动触发；其余文件 <A-]> 手动
        auto_trigger_ft = [
          "nix"
          "rust"
          "python"
          "c"
          "cpp"
          "typescript"
          "typescriptreact"
          "javascript"
          "javascriptreact"
          "lua"
          "sh"
          "bash"
          "json"
          "yaml"
          "toml"
          "scala"
          "sbt"
        ];
        keymap = {
          accept = "<A-A>"; # 接受整条建议
          accept_line = "<A-a>"; # 逐行接受
          accept_n_lines = "<A-z>"; # 接受 n 行（提示输入数字）
          next = "<A-]>"; # 下一条；无建议时手动触发
          prev = "<A-[>";
          dismiss = "<A-e>";
        };
      };
    };
  };

  # 每个 Neovim 实例一个稳定会话 ID，用于 x-opencode-session 头
  extraConfigLua = ''
    do
      math.randomseed(vim.loop.hrtime())
      local t = {}
      for _ = 1, 16 do
        t[#t + 1] = string.format("%02x", math.random(0, 255))
      end
      vim.g.minuet_session_id = table.concat(t)
    end
  '';
}
