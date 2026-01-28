const self = path self

# Edit this completions.
export def "config user-completions" []: nothing -> nothing {
  run-external $env.config.buffer_editor ($self)
}

# https://github.com/zyedidia/eget
export extern eget [
  target?: string # target repository to download from | 要下载的目标仓库
  --tag (-t): string # tagged release to use instead of latest | 使用指定标签版本而非最新版
  --pre-release # include pre-releases when fetching the latest version | 获取最新版本时包含预发布版本
  --source # download the source code for the target repo instead of a release | 下载目标仓库的源代码而非发布版本
  --to: string # move to given location after extracting | 提取后移动到指定位置
  --system (-s): string # target system to download for (use "all" for all choices) | 目标系统 (使用 "all" 表示所有选项)
  --file (-f): string # glob to select files for extraction | 用于选择提取文件的通配符
  --all # extract all candidate files | 提取所有候选文件
  --quiet (-q) # only print essential output | 仅打印必要输出
  --download-only (-d) # stop after downloading the asset (no extraction) | 下载资源后停止 (不提取)
  --upgrade-only # only download if release is more recent than current version | 仅当发布版本比当前版本更新时才下载
  --asset (-a): any # download a specific asset containing the given string (can be specified multiple times) | 下载包含指定字符串的特定资源 (可多次指定)
  --sha256 # show the SHA-256 hash of the downloaded asset | 显示下载资源的 SHA-256 哈希值
  --verify-sha256: string # verify the downloaded asset checksum against the one provided | 验证下载资源的校验和
  --rate # show GitHub API rate limiting information | 显示 GitHub API 速率限制信息
  --remove (-r) # remove the given file from $EGET_BIN or the current directory | 从 $EGET_BIN 或当前目录删除指定文件
  --version (-v) # show version information | 显示版本信息
  --help (-h) # show this help message | 显示帮助信息
  --download-all (-D) # download all projects defined in the config file | 下载配置文件中定义的所有项目
  --disable-ssl (-k) # disable SSL verification for download requests | 禁用下载请求的 SSL 验证
]

# everything cli | Everything 命令行工具
export extern es [
  search?: string
  --regex (-r): string # search using regular expressions | 使用正则表达式搜索
  --case (-i) # match case | 区分大小写
  --whole-word (-w) # match whole words | 匹配整个单词
  --match-path (-p) # match full path | 匹配完整路径
  --diacritics (-a) # match diacritical marks | 匹配变音符号
  --prefix # match start of words | 匹配单词开头
  --suffix # match end of words | 匹配单词结尾
  --ignore-punctuation # ignore punctuation in filenames | 忽略文件名中的标点符号
  --ignore-whitespace # ignore whitespace in filenames | 忽略文件名中的空白字符
  --count (-n): int # maximum number of results | 最大结果数量

  --path: string # search within path | 在指定路径内搜索
  --parent-path: string # search within parent path | 在父路径内搜索
  --parent: string # search for files with the specified parent path | 搜索具有指定父路径的文件

  --sort: string # sort by name|path|size|extension|date-created|date-modified|date-accessed|attributes|filelist-filename|run-count|date-recently-changed|date-run|<property-name> | 排序方式: 名称|路径|大小|扩展名|创建日期|修改日期|访问日期|属性|文件列表名称|运行次数|最近更改日期|运行日期|<属性名>
  --sort-path (-s) # sort by full path | 按完整路径排序

  --name # show name column | 显示名称列
  --path-column # show path column | 显示路径列
  --full-path-and-name # show full path and name column | 显示完整路径和名称列
  --extension # show extension column | 显示扩展名列
  --size # show size column | 显示大小列
  --date-created # show date created column | 显示创建日期列
  --date-modified # show date modified column | 显示修改日期列
  --date-accessed # show date accessed column | 显示访问日期列
  --attributes # show attributes column | 显示属性列
  --filelist-filename # show file list filename column | 显示文件列表文件名列
  --run-count # show run count column | 显示运行次数列
  --date-run # show date run column | 显示运行日期列
  --date-recently-changed # show recently changed column | 显示最近更改列
  --highlight # highlight results | 高亮显示结果
  --viewport-offset: int # show results starting from offset | 从偏移量开始显示结果
  --viewport-count: int # limit number of results shown | 限制显示的结果数量

  --csv # output CSV | 输出 CSV 格式
  --efu # output EFU | 输出 EFU 格式
  --json # output JSON | 输出 JSON 格式
  --m3u # output M3U | 输出 M3U 格式
  --m3u8 # output M3U8 | 输出 M3U8 格式
  --tsv # output TSV | 输出 TSV 格式
  --txt # output TXT | 输出 TXT 格式

  --size-format: int # 0=auto,1=Bytes,2=KB,3=MB | 大小格式: 0=自动,1=字节,2=KB,3=MB
  --date-format: int # 0=auto,1=ISO-8601,2=FILETIME,3=ISO-8601(UTC),4=User Locale,5=ISO-8601(full),6=ISO-8601(UTC full) | 日期格式: 0=自动,1=ISO-8601,2=文件时间,3=ISO-8601(UTC),4=用户区域,5=ISO-8601(完整),6=ISO-8601(UTC完整)

  --export-csv: string # export to CSV file | 导出到 CSV 文件
  --export-efu: string # export to EFU file | 导出到 EFU 文件
  --export-json: string # export to JSON file | 导出到 JSON 文件
  --export-m3u: string # export to M3U file | 导出到 M3U 文件
  --export-m3u8: string # export to M3U8 file | 导出到 M3U8 文件
  --export-tsv: string # export to TSV file | 导出到 TSV 文件
  --export-txt: string # export to TXT file | 导出到 TXT 文件
  --no-header # omit column header in export | 导出时省略列标题
  --no-folder-append-path-separator # don't append trailing path separator to folder paths | 不在文件夹路径末尾添加路径分隔符
  --utf8-bom # include UTF-8 BOM | 包含 UTF-8 BOM

  --instance: string # connect to Everything instance by name | 按名称连接到 Everything 实例
  --pause # pause after each page of output | 每页输出后暂停
  --timeout: int # timeout in milliseconds waiting for Everything database | 等待 Everything 数据库的超时时间 (毫秒)
  --no-result-error # set error level if no results are found | 未找到结果时设置错误级别
  --version # display ES version | 显示 ES 版本
  --help (-h) # display help | 显示帮助
]

# java completions | Java 补全
def "nu-complete java" []: nothing -> record {
  use script/complete-tools.nu complete-file
  complete-file java
}

export extern java [command?: string@"nu-complete java"]

def "nu-complete bz-command" []: nothing -> list<record> {
  [
    {value: "a" description: "Add files to archive | 添加文件到压缩包"}
    {value: "x" description: "Extract files with paths | 解压并保留路径"}
    {value: "t" description: "Test archive integrity | 测试压缩包完整性"}
    {value: "d" description: "Delete files from archive | 从压缩包删除文件"}
    {value: "c" description: "Create new archive (overwrite) | 新建/覆盖压缩包"}
    {value: "rn" description: "Rename entries in archive | 重命名压缩包内文件"}
    {value: "l" description: "List files in archive (bz only) | 列出压缩包内容"}
  ]
}

def "nu-complete bz-switch" []: nothing -> list<record> {
  [
    {value: "-l:5" description: "Compression level 0-9 (default 5) | 压缩级别"}
    {value: "-r" description: "Recurse subdirectories | 递归子目录"}
    {value: "-r-" description: "Disable recursion | 关闭递归"}
    {value: "-aoa" description: "Overwrite existing files | 覆盖已存在文件"}
    {value: "-aos" description: "Skip existing files | 跳过已存在文件"}
    {value: "-aou" description: "Auto-rename on conflict | 冲突时自动重命名"}
    {value: "-sfx:stub" description: "Create SFX with stub path | 使用指定 SFX 模板"}
    {value: "-zopfli" description: "Use Zopfli encoder | 使用 Zopfli 编码"}
    {value: "-p:password" description: "Set archive password | 设置压缩包密码"}
    {value: "-o:dest" description: "Destination folder (extract) | 目标目录 (解压)"}
    {value: "-storeroot:yes" description: "Store root as top-level folder | 存储根目录"}
    {value: "-storeroot:no" description: "Do not store root folder | 不存储根目录"}
    {value: "-y" description: "Assume Yes on prompts | 自动确认"}
    {value: "-ex:pattern" description: "Exclude patterns when compressing | 压缩时排除"}
    {value: "-root:dir" description: "Set archive root folder | 指定归档根目录"}
    {value: "-fmt:zip" description: "Archive format zip|zipx|exe|tar|tgz|lzh|iso|7z|gz|xz | 选择格式"}
    {value: "-v:100MB" description: "Volume size | 分卷大小"}
    {value: "-cmt:comment" description: "Set zip comment | 设定注释"}
    {value: "-cmtfile:path" description: "Comment from file | 注释文件路径"}
    {value: "-t:4" description: "CPU threads | 线程数"}
    {value: "-cp:65001" description: "Code page (e.g., UTF-8 65001) | 代码页"}
    {value: "-target:auto" description: "Extract Here (Smart) | 智能解压到当前"}
    {value: "-target:name" description: "Extract to archive-name folder | 解压到同名目录"}
    {value: "-target:dlg" description: "Choose destination via dialog | 对话框选择目标"}
    {value: "-date" description: "Insert timestamp in path | 路径包含时间"}
    {value: "-email" description: "Compress and email | 压缩后发送邮件"}
    {value: "-list:v" description: "Verbose list (command l) | 详细列表"}
    {value: "-list:s" description: "Short list (command l) | 简洁列表"}
    {value: "-consolemode:ansi" description: "Save output as ANSI | 输出 ANSI"}
    {value: "-consolemode:utf8" description: "Save output as UTF-8 | 输出 UTF-8"}
  ]
}

def "nu-complete zip" []: nothing -> record {
  use script/complete-tools.nu complete-file
  complete-file "{zip,7z,apk}"
}

export extern bz [
  command: string@"nu-complete bz-command" # bz 命令
  path: path@"nu-complete zip" # 文件或目录路径
  ...args: string@"nu-complete bz-switch"
]

def "nu-complete sudo-command" []: nothing -> list<record> {
  [
    {
      value: "run"
      description: "Run command as administrator | 以管理员身份运行命令"
    }
    {
      value: "config"
      description: "Show current sudo configuration | 显示当前 sudo 配置"
    }
    {
      value: "help"
      description: "Show help for sudo | 显示 sudo 帮助"
    }
  ]
}

def "nu-complete exec" []: nothing -> record {
  use script/complete-tools.nu complete-file
  complete-file "{exe,bat,cmd,ps1}"
}

export extern sudo [
  command?: string@"nu-complete sudo-command"
  ...args: oneof<string, path>@"nu-complete exec"
  --preserve-env (-E) # pass current environment variables to command | 将当前环境变量传递至命令
  --new-window (-N) # run in new window | 在新窗口中运行
  --disable-input # run in current terminal with input disabled | 在当前终端中运行但禁用输入
  --inline # run in current terminal | 在当前终端中运行
  --chdir (-D): directory # change working directory before running | 运行前更改工作目录
  --help (-h) # show help message | 显示帮助信息
  --version (-V) # show version information | 显示版本信息
]
def "nu-complete ya pkg" [] {
  ya pkg list | parse "\t{name} ({hash})" | get name
}
# delete yazi package | 删除 yazi 包
export extern "ya pkg delete" [
  pkg: string@"nu-complete ya pkg" # package name to delete | 要删除的包名
]
# list yazi packages | 列出 yazi 包
export extern "ya pkg list" [
  --help (-h) # show help message | 显示帮助信息
]
# upgrade yazi package | 升级 yazi 包
export extern "ya pkg upgrade" [
  pkg?: string@"nu-complete ya pkg" # package name to upgrade | 要升级的包名
  --help (-h) # show help message | 显示帮助信息
]
# add yazi package | 添加 yazi 包
export extern "ya pkg add" [
  pkg: string # package name to add | 要添加的包名
]

def "nu-complete chezmoi unmanaged" []: nothing -> list<string> {
  chezmoi unmanaged | lines
}
export extern "chezmoi add" [
  # Primary flags
  --autotemplate (-a) # Generate the template when adding files as templates
  --create # Add files that should exist, irrespective of their contents
  --encrypt # Encrypt files
  --exact # Add directories exactly
  --exclude (-x): string # Exclude entry types (comma-separated) (default none)
  --follow (-f) # Add symlink targets instead of symlinks
  --help (-h) # help for add
  --include (-i): string # Include entry types (comma-separated) (default all)
  --new # Create new file if target does not exist
  --prompt (-p) # Prompt before adding each entry
  --quiet (-q) # Suppress warnings
  --recursive (-r) # Recurse into subdirectories (default true)
  --secrets
  -s: string # Scan for secrets when adding unencrypted files (error|ignore|warning) (default warning)
  -T
  --template # Add files as templates
  --template-symlinks # Add symlinks with target in source or home dirs as templates

  # Global flags (selected)
  --age-recipient: string # Override age recipient
  --age-recipient-file: string # Override age recipient file
  --cache (-c): path # Set cache directory
  --color: string # Colorize output (bool|auto)
  --config: path # Set config file
  --config-format: string # Set config file format (none|json|toml|yaml)
  --debug (-d) # Include debug information in output
  --destination: path # Set destination directory
  --dry-run # Do not make any modifications to the destination directory
  --force (-f) # Make all changes without prompting
  --interactive (-i) # Prompt for all changes
  --keep-going # Keep going as far as possible after an error
  --less-interactive # Prompt for changed or pre-existing targets
  --mode (-m): string # Mode (file|symlink)
  --no-pager # Do not use the pager
  --no-tty # Do not attempt to get a TTY for prompts
  --output (-o): path # Write output to path instead of stdout
  --override-data: string # Override data
  --override-data-file: path # Override data with file
  --persistent-state: path # Set persistent state file
  --progress: string # Display progress bars (bool|auto)
  --refresh-externals: string # Refresh external cache (always|auto|never[=always])
  --source (-s): path # Set source directory
  --source-path # Specify targets by source path
  --use-builtin-age: string # Use builtin age (bool|auto)
  --use-builtin-diff # Use builtin diff
  --use-builtin-git: string # Use builtin git (bool|auto)
  --verbose (-v) # Make output more verbose
  --working-tree: path # Set working tree directory

  ...file: path
]
export alias chad = chezmoi add
def "nu-complete chezmoi managed" []: nothing -> list<string> {
  chezmoi managed | lines
}
export extern "chezmoi apply" [
  --exclude (-x): string # Exclude entry types (default none)
  --include (-i): string # Include entry types (default all)
  --init # Recreate config file from template
  --parent-dirs (-P) # Apply all parent directories
  --recursive (-r) # Recurse into subdirectories (default true)

  ...target: path@"nu-complete chezmoi managed" # Target to apply (default all)
]
export alias chap = chezmoi apply
