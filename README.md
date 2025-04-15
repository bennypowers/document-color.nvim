# document-color.nvim 🌈
A colorizer plugin for language servers supporting the `textDocument/documentColor` method.

![document-color.nvim demo](https://user-images.githubusercontent.com/40532058/184640748-8e71ad1e-c300-4040-b4f2-8a5bba3e9588.gif)

## Installation & Usage
Lazy.nvim:
```lua
return { 'bennypowers/document-color.nvim',
  opts = {
    -- Default options
    mode = 'inlay', -- 'inlay' | 'background' | 'foreground' | 'single'
  }
}
```

<details>
<summary>What is "single" mode?</summary>
<br>

For people who don't like large bright chunks of their buffer un-colorschemed, `single` column mode is a compromise until anti-conceal.

!["single" mode](https://user-images.githubusercontent.com/40532058/184829642-e6f83acc-dece-4ee0-b17f-86e119a4f966.png)
---

</details>

<details>
<summary>What does foreground mode look like?</summary>
<br>

![image](https://user-images.githubusercontent.com/40532058/184633209-32427b6b-0f08-468b-ae6f-977950b96000.png)
---

</details>

For a typical LSP config,
```lua
on_attach = function(client, bufnr)
  require'document-color'.on_attach(client, bufnr)
end
...
end


## Credits
- [mrshmllow](https://github.com/mrshmllow/document-color.nvim) for publishing the original version of this plugin
- [kabouzeid](https://github.com/kabouzeid) and his great dotfiles. Inspired by his reddit post, chunks of this plugin are from his dotfiles. ❤️
- https://github.com/norcalli/nvim-colorizer.lua
