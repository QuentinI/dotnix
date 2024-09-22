{ config, pkgs, inputs, system, ... }:

{
  programs.helix = {
    enable = true;
    package = inputs.helix.packages."${system}".helix;
    settings = {
      theme = "base16_hm";
      editor = {
        line-number = "relative";
        auto-save = true;
        bufferline = "multiple";
        color-modes = true;
        statusline = {
          left = [ "mode" "version-control" "spacer" "spinner" "file-name" "file-modification-indicator" ];
          center = [ ];
          right = [ "diagnostics" "workspace-diagnostics" "selections" "position" "file-encoding" ];
        };
        lsp = {
          display-inlay-hints = true;
        };
        cursor-shape.insert = "bar";
        whitespace.render.tab = "all";
        whitespace.characters.tab = "→";
        indent-guides.render = true;
        soft-wrap.enable = true;
      };
      keys = {
        normal = {
          "C-j" = ":buffer-next";
          "C-k" = ":buffer-previous";
        };
      };
    };
    languages = {
      rust = {
        name = "rust";
        config = {
          inlayHints.bindingModeHints.enable = true;
          inlayHints.closingBraceHints.minLines = 10;
          inlayHints.closureReturnTypeHints.enable = "with_block";
          inlayHints.expressionAdjustmentHints.enable = true;
          inlayHints.expressionAdjustmentHints.hideOutsideUnsafe = true;
          inlayHints.discriminantHints.enable = "fieldless";
          inlayHints.lifetimeElisionHints.enable = "skip_trivial";
        };
      };
    };
    themes = with config.theme.base16.colors; {
      base16_hm = {
        "attributes" = "#${base09.hex.rgb}";
        "comment" = {
          fg = "#${base03.hex.rgb}";
        };
        "constant" = "#${base09.hex.rgb}";
        "constant.character.escape" = "#${base0C.hex.rgb}";
        "constant.numeric" = "#${base09.hex.rgb}";
        "constructor" = "#${base0D.hex.rgb}";
        "debug" = "#${base03.hex.rgb}";
        "diagnostic" = {
          modifiers = [ "underlined" ];
        };
        "diff.delta" = "#${base09.hex.rgb}";
        "diff.minus" = "#${base08.hex.rgb}";
        "diff.plus" = "#${base0B.hex.rgb}";
        "error" = "#${base08.hex.rgb}";
        "function" = "#${base0D.hex.rgb}";
        "hint" = "#${base03.hex.rgb}";
        "info" = "#${base0D.hex.rgb}";
        "keyword" = "#${base0E.hex.rgb}";
        "label" = "#${base0E.hex.rgb}";
        "namespace" = "#${base0E.hex.rgb}";
        "operator" = "#${base05.hex.rgb}";
        "special" = "#${base0D.hex.rgb}";
        "string" = "#${base0B.hex.rgb}";
        "type" = "#${base0A.hex.rgb}";
        "variable" = "#${base08.hex.rgb}";
        "variable.other.member" = "#${base0B.hex.rgb}";
        "warning" = "#${base09.hex.rgb}";
        "markup.bold" = {
          fg = "#${base0A.hex.rgb}";
          modifiers = [ "bold" ];
        };
        "markup.heading" = "#${base0D.hex.rgb}";
        "markup.italic" = {
          fg = "#${base0E.hex.rgb}";
          modifiers = [ "italic" ];
        };
        "markup.link.text" = "#${base08.hex.rgb}";
        "markup.link.url" = {
          fg = "#${base09.hex.rgb}";
          modifiers = [ "underlined" ];
        };
        "markup.list" = "#${base08.hex.rgb}";
        "markup.quote" = "#${base0C.hex.rgb}";
        "markup.raw" = "#${base0B.hex.rgb}";
        "markup.strikethrough" = {
          modifiers = [ "crossed_out" ];
        };
        "diagnostic.hint" = {
          underline = { style = "curl"; };
        };
        "diagnostic.info" = {
          underline = { style = "curl"; };
        };
        "diagnostic.warning" = {
          underline = { style = "curl"; };
        };
        "diagnostic.error" = {
          underline = { style = "curl"; };
        };
        "ui.bufferline" = {
          fg = "#${base04.hex.rgb}";
          bg = "#${base00.hex.rgb}";
        };
        "ui.bufferline.active" = {
          fg = "#${base00.hex.rgb}";
          bg = "#${base03.hex.rgb}";
          modifiers = [ "bold" ];
        };
        "ui.menu.scroll" = {
          fg = "#${base03.hex.rgb}";
          bg = "base01";
        };
        "ui.selection.primary" = {
          bg = "#${base02.hex.rgb}";
        };
        "ui.cursor.select" = {
          fg = "#${base0A.hex.rgb}";
          modifiers = [ "underlined" ];
        };
        "ui.cursor.insert" = {
          fg = "#${base0A.hex.rgb}";
          modifiers = [ "underlined" ];
        };
        "ui.background" = {
          bg = "#${base00.hex.rgb}";
        };
        "ui.cursor" = {
          fg = "#${base04.hex.rgb}";
          modifiers = [ "reversed" ];
        };
        "ui.cursor.match" = {
          fg = "#${base0A.hex.rgb}";
          modifiers = [ "underlined" ];
        };
        "ui.cursorline.primary" = {
          fg = "#${base05.hex.rgb}";
          bg = "base01";
        };
        "ui.gutter" = {
          bg = "#${base00.hex.rgb}";
        };
        "ui.help" = {
          fg = "#${base06.hex.rgb}";
          bg = "base01";
        };
        "ui.linenr" = {
          fg = "#${base03.hex.rgb}";
          bg = "base00";
        };
        "ui.linenr.selected" = {
          fg = "#${base04.hex.rgb}";
          bg = "base01";
          modifiers = [ "bold" ];
        };
        "ui.menu" = {
          fg = "#${base05.hex.rgb}";
          bg = "base01";
        };
        "ui.menu.selected" = {
          fg = "#${base01.hex.rgb}";
          bg = "base04";
        };
        "ui.popup" = {
          bg = "#${base01.hex.rgb}";
        };
        "ui.selection" = {
          bg = "#${base02.hex.rgb}";
        };
        "ui.statusline" = {
          fg = "#${base04.hex.rgb}";
          bg = "#${base01.hex.rgb}";
        };
        "ui.statusline.inactive" = {
          bg = "#${base01.hex.rgb}";
          fg = "#${base03.hex.rgb}";
        };
        "ui.statusline.insert" = {
          fg = "#${base00.hex.rgb}";
          bg = "#${base0B.hex.rgb}";
        };
        "ui.statusline.normal" = {
          fg = "#${base00.hex.rgb}";
          bg = "#${base03.hex.rgb}";
        };
        "ui.statusline.select" = {
          fg = "#${base00.hex.rgb}";
          bg = "#${base0F.hex.rgb}";
        };
        "ui.text" = "#${base05.hex.rgb}";
        "ui.text.focus" = "#${base05.hex.rgb}";
        "ui.virtual.ruler" = {
          bg = "#${base01.hex.rgb}";
        };
        "ui.virtual.indent-guide" = {
          fg = "#${base03.hex.rgb}";
        };
        "ui.virtual.inlay-hint" = {
          fg = "#${base03.hex.rgb}";
          modifiers = [ "dim" "italic" ];
        };
        "ui.virtual.whitespace" = {
          fg = "#${base01.hex.rgb}";
        };
        "ui.window" = {
          bg = "#${base01.hex.rgb}";
        };
      };
    };
  };
}
