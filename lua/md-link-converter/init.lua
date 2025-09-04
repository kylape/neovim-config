-- md-link-converter.lua
-- Neovim plugin to convert inline markdown links to reference-style links

local M = {}

-- Convert inline links to reference-style links in the current buffer
function M.convert_links()
  -- Get all lines from the buffer and join them
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  
  -- Pattern to match inline links: [text](url) - handles multiline
  local inline_link_pattern = "%[([^%]]+)%]%(([^%)]+)%)"
  
  -- Track unique URLs and assign reference numbers
  local url_to_ref = {}
  local ref_counter = 1
  local has_changes = false
  
  -- Find and replace all inline links
  local converted_content = string.gsub(content, inline_link_pattern, function(text, url)
    has_changes = true
    
    -- Clean up text and URL (remove newlines and extra whitespace)
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    url = string.gsub(url, "%s+", "")
    
    -- Assign reference number if URL is new
    if not url_to_ref[url] then
      url_to_ref[url] = ref_counter
      ref_counter = ref_counter + 1
    end
    
    local ref_num = url_to_ref[url]
    return string.format("[%s][%d]", text, ref_num)
  end)
  
  -- Split back into lines
  local converted_lines = {}
  for line in string.gmatch(converted_content .. '\n', '([^\n]*)\n') do
    table.insert(converted_lines, line)
  end
  
  -- Add reference definitions at the bottom if there were changes
  if has_changes and next(url_to_ref) then
    -- Add blank line before references if last line isn't empty
    if #converted_lines > 0 and converted_lines[#converted_lines] ~= "" then
      table.insert(converted_lines, "")
    end
    
    -- Sort URLs by reference number and add reference definitions
    local sorted_refs = {}
    for url, ref_num in pairs(url_to_ref) do
      table.insert(sorted_refs, {url = url, ref_num = ref_num})
    end
    
    table.sort(sorted_refs, function(a, b) return a.ref_num < b.ref_num end)
    
    for _, ref in ipairs(sorted_refs) do
      table.insert(converted_lines, string.format("[%d]: %s", ref.ref_num, ref.url))
    end
    
    -- Replace buffer contents
    vim.api.nvim_buf_set_lines(0, 0, -1, false, converted_lines)
    
    -- Show success message
    local link_count = #sorted_refs
    vim.notify(string.format("Converted %d inline link%s to reference%s", 
      link_count, 
      link_count == 1 and "" or "s",
      link_count == 1 and "" or "s"
    ))
  else
    vim.notify("No inline links found to convert")
  end
end

-- Convert links in visual selection
function M.convert_links_visual()
  -- Get visual selection range
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2] - 1  -- Convert to 0-based indexing
  local end_line = end_pos[2]
  
  -- Get selected lines and join them
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local content = table.concat(lines, '\n')
  
  -- Pattern to match inline links: [text](url)
  local inline_link_pattern = "%[([^%]]+)%]%(([^%)]+)%)"
  
  -- Track unique URLs and assign reference numbers
  local url_to_ref = {}
  local ref_counter = 1
  local has_changes = false
  
  -- Find and replace all inline links
  local converted_content = string.gsub(content, inline_link_pattern, function(text, url)
    has_changes = true
    
    -- Clean up text and URL (remove newlines and extra whitespace)
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    url = string.gsub(url, "%s+", "")
    
    -- Assign reference number if URL is new
    if not url_to_ref[url] then
      url_to_ref[url] = ref_counter
      ref_counter = ref_counter + 1
    end
    
    local ref_num = url_to_ref[url]
    return string.format("[%s][%d]", text, ref_num)
  end)
  
  -- Split back into lines
  local converted_lines = {}
  for line in string.gmatch(converted_content .. '\n', '([^\n]*)\n') do
    table.insert(converted_lines, line)
  end
  
  if has_changes and next(url_to_ref) then
    -- Replace selected lines
    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, converted_lines)
    
    -- Get all buffer lines to append references
    local all_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    
    -- Add blank line before references if last line isn't empty
    if #all_lines > 0 and all_lines[#all_lines] ~= "" then
      table.insert(all_lines, "")
    end
    
    -- Sort URLs by reference number and add reference definitions
    local sorted_refs = {}
    for url, ref_num in pairs(url_to_ref) do
      table.insert(sorted_refs, {url = url, ref_num = ref_num})
    end
    
    table.sort(sorted_refs, function(a, b) return a.ref_num < b.ref_num end)
    
    for _, ref in ipairs(sorted_refs) do
      table.insert(all_lines, string.format("[%d]: %s", ref.ref_num, ref.url))
    end
    
    -- Update buffer with references added
    vim.api.nvim_buf_set_lines(0, 0, -1, false, all_lines)
    
    -- Show success message
    local link_count = #sorted_refs
    vim.notify(string.format("Converted %d inline link%s to reference%s in selection", 
      link_count, 
      link_count == 1 and "" or "s",
      link_count == 1 and "" or "s"
    ))
  else
    vim.notify("No inline links found in selection")
  end
end

-- Setup function for the plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Create user commands
  vim.api.nvim_create_user_command('ConvertMdLinks', M.convert_links, {
    desc = 'Convert inline markdown links to reference-style links'
  })
  
  vim.api.nvim_create_user_command('ConvertMdLinksVisual', M.convert_links_visual, {
    range = true,
    desc = 'Convert inline markdown links to reference-style links in visual selection'
  })
  
  -- Set up default keymaps if enabled
  if opts.keymaps ~= false then
    vim.keymap.set('n', '<leader>ml', M.convert_links, { 
      desc = 'Convert markdown links',
      silent = true 
    })
    vim.keymap.set('v', '<leader>ml', M.convert_links_visual, { 
      desc = 'Convert markdown links in selection',
      silent = true 
    })
  end
end

return M