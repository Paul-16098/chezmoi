# 個人配置文件(Dotfiles)

使用 [chezmoi](https://www.chezmoi.io/) 管理的綜合性配置文件倉庫，用於維護跨系統的一致開發環境配置。

## 項目概述

本倉庫包含各種開發工具和應用程序的個人配置文件(dotfiles)，通過 chezmoi 進行管理。配置針對 Windows 開發環境進行了優化，同時考慮了跨平臺兼容性。

## 技術棧

### 主要工具

- **配置文件管理器**：[chezmoi](https://www.chezmoi.io/) - 帶模板功能的安全配置管理器
- **Shell**：[Nushell](https://www.nushell.sh/) - 支持結構化數據的現代 Shell
- **提示符**：[Starship](https://starship.rs/) - 跨 Shell 提示符
- **文件管理器**：[Yazi](https://yazi-rs.github.io/) - 終端文件管理器
- **版本控制**：Git(帶 GPG 簽名)
- **Shell 歷史**：[Atuin](https://atuin.sh/) - 智能 Shell 歷史記錄

### 開發工具

- **Rust/Cargo**：自定義配置，支持鏡像源
- **VS Code Insiders**：集成為 diff 和 merge 工具
- **SSH**：安全的 Shell 配置
- **GPG**：敏感文件加密
- **KeePassXC**：密碼管理集成
- **sccache**：Rust 編譯緩存
- **WakaTime**：編程活動追蹤

## 項目架構

```tree
chezmoi/
├── AppData/Roaming/          # Windows AppData 配置
│   ├── nushell/              # Nushell Shell 配置
│   │   ├── config.nu         # 主配置文件
│   │   ├── env.nu.tmpl       # 環境變量(模板化)
│   │   ├── hooks.nu          # Shell 鉤子
│   │   ├── keybindings.nu    # 自定義快捷鍵
│   │   └── script/           # 輔助腳本
│   └── yazi/                 # Yazi 文件管理器配置
│       └── config/           # Yazi 配置文件
├── dot_cargo/                # Rust/Cargo 配置
│   ├── config.toml           # Cargo 設置(包含鏡像源)
│   └── binstall.toml         # cargo-binstall 配置
├── dot_config/               # 標準配置目錄
│   ├── starship.toml         # Starship 提示符配置
│   ├── atuin/                # Atuin Shell 歷史
│   ├── gh/                   # GitHub CLI 配置
│   ├── nextest/              # Cargo nextest 配置
│   └── uv/                   # Python uv 工具配置
├── dot_ssh/                  # SSH 配置
│   └── config                # SSH 客戶端配置
├── .chezmoi.toml.tmpl        # Chezmoi 配置
└── dot_gitconfig             # Git 全局配置
```

## 主要特性

### 安全與隱私

- **GPG 加密**：敏感文件靜態加密
- **GPG 簽名**：Git 提交和標籤使用 GPG 簽名
- **KeePassXC 集成**：通過 KeePassXC 數據庫管理密碼
- **SSH 配置**：安全的 Shell 訪問管理

### Shell 增強

- **Nushell 配置**：支持結構化數據管道的現代 Shell
- **Starship 提示符**：快速、可自定義的提示符，支持 Git 集成
- **Atuin 歷史**：可搜索、可同步的 Shell 歷史(SQLite 後端)
- **自定義別名**：以生產力為導向的命令別名
- **自動補全**：為各種工具提供增強的補全功能

### 開發優化

- **Rust 開發**：
  - 鏡像源配置以加快 crate 下載(清華、重郵鏡像)
  - sccache 集成以加快編譯速度
  - cargo-binstall 用於二進制 crate 安裝
- **Git 工作流**：
  - 通過 chezmoi 自動提交和推送
  - VS Code Insiders 作為 diff/merge 工具
- **Python 開發**：uv 工具集成以實現快速包管理

## 快速開始

### 前置要求

#### 必需

- [chezmoi](https://www.chezmoi.io/install/) - 配置文件管理器
- [Git](https://git-scm.com/) - 版本控制

#### 推薦

- [Nushell](https://www.nushell.sh/) - 現代 Shell
- [Starship](https://starship.rs/) - 跨 Shell 提示符
- [Yazi](https://github.com/sxyazi/yazi) - 終端文件管理器
- [Atuin](https://atuin.sh/) - Shell 歷史管理器
- [VS Code Insiders](https://code.visualstudio.com/insiders/) - 代碼編輯器
- [KeePassXC](https://keepassxc.org/) - 密碼管理器
- [Rust 工具鏈](https://rustup.rs/) - 用於 Rust 開發
- [GitHub CLI](https://cli.github.com/) - GitHub 集成

### 安裝步驟

1. **使用此倉庫初始化 chezmoi**：

   ```bash
   chezmoi init Paul-16098/Dotfiles
   ```

2. **在應用之前查看更改**：

   ```bash
   chezmoi diff
   ```

3. **應用配置文件**：

   ```bash
   chezmoi apply
   ```

### 配置

#### Nushell 環境

編輯 `AppData/Roaming/nushell/env.nu.tmpl` 以配置特定環境變量。

## 項目結構

### 配置分類

#### Shell 配置

- **Nushell**：完整的 Shell 配置，包含自定義函數、別名和鉤子
- **Starship**：自定義提示符，帶時間顯示和 Git 指標
- **快捷鍵綁定**：自定義鍵盤快捷鍵以提高生產力

#### 開發工具

- **Cargo**：優化的 Rust 構建設置，支持鏡像源
- **Git**：全局 Git 配置，帶 GPG 簽名
- **SSH**：安全的 Shell 客戶端配置
- **VS Code**：集成為 diff/merge 工具

#### 應用配置

- **Yazi**：帶 Lua 擴展的文件管理器
- **Atuin**：帶 SQLite 後端的 Shell 歷史
- **GitHub CLI**：憑證助手集成
- **WakaTime**：編程活動追蹤

## 開發工作流

### 修改配置

1. **編輯源倉庫中的文件**：

   ```bash
   chezmoi edit ~/.config/starship.toml
   ```

2. **查看更改**：

   ```bash
   chezmoi diff
   ```

3. **應用更改**：

   ```bash
   chezmoi apply
   ```

4. **自動提交**通過 `.chezmoi.toml.tmpl` 啟用：

   ```toml
   [git]
       autoAdd = true
       autoCommit = true
   ```

### 更新配置文件

```bash
# 拉取最新更改
chezmoi update

# 或手動操作
cd $(chezmoi source-path)
git pull
chezmoi apply
```

## 測試

### 手動測試

在應用更改之前：

```bash
# 預覽更改
chezmoi diff

# 應用到臨時目錄
chezmoi apply --dry-run --verbose
```

## 自定義

### 供您自己使用

1. **Fork 此倉庫**
2. **更新個人信息**：
   - GPG 簽名密鑰
   - KeePassXC 數據庫路徑
   - SSH 密鑰和配置
   - WakaTime API 密鑰
3. **自定義配置**：
   - Nushell 別名和函數
   - Starship 提示符主題
   - Yazi 快捷鍵綁定
4. **從配置中移除** 未使用的工具

### 添加新配置

```bash
# 將新文件添加到 chezmoi
chezmoi add ~/.config/newtool/config.toml

# 添加加密文件
chezmoi add --encrypt ~/.secret-config

# 添加模板文件
chezmoi add --template ~/.config/environment-specific.conf
```

## 故障排除

### 常見問題

**GPG 加密錯誤**：

```bash
# 檢查 GPG 密鑰
gpg --list-keys

# 測試加密
echo "test" | gpg --encrypt --recipient YOUR_KEY_ID | gpg --decrypt
```

**chezmoi 衝突**：

```bash
# 強制覆蓋
chezmoi apply --force

# 重置到源狀態
chezmoi init --apply --force
```

---

**免責聲明**：這是一個個人配置文件倉庫。配置是為特定工作流程量身定製的，可能需要針對您的環境進行自定義。在應用到您的系統之前，請務必檢查配置。
