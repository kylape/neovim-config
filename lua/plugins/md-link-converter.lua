return {
  {
    "md-link-converter",
    dir = vim.fn.stdpath("config") .. "/lua/md-link-converter",
    config = function()
      require("md-link-converter").setup()
    end,
  },
}